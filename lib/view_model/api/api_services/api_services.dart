import 'dart:async';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:guru_kripa/model/access_restriction_reason/access_restriction_reason.dart';
import 'package:guru_kripa/utils/upload_file/upload_file.dart';
import 'package:guru_kripa/view_model/api/api_url_config/api_url_config.dart';
import 'package:path_provider/path_provider.dart';

/// Same display-ready-message contract as the plain [Exception] every
/// other error here throws (`toString()` still reads "Exception:
/// $message", so every existing `catch (e)` call site that strips that
/// prefix keeps working unchanged) — [reason] is the addition, mirroring
/// the backend's own `errors.reason` convention (OTP_INVALID/OTP_EXPIRED,
/// SUBSCRIPTION_REQUIRED, ...) for the few call sites that need to branch
/// on *which* error this was rather than just show its message.
class ApiException implements Exception {
  const ApiException(this.message, {this.reason});

  final String message;
  final String? reason;

  @override
  String toString() => 'Exception: $message';
}

class ApiService {
  static late Dio _dio;
  static late CookieJar _cookieJar;

  // Dio's own connectTimeout/receiveTimeout (30s each, set below) should
  // already bound every request — but receiveTimeout only resets on each
  // byte actually received, so a connection that stalls after partial
  // data (or a stuck token-refresh queued ahead of it in
  // [_authRefreshInterceptor], which has no timeout of its own) can still
  // hang past that. This hard ceiling is the backstop: whatever the
  // reason, no call through this service can wedge a notifier's
  // `isLoading` forever with neither a response nor an error — past this,
  // it always throws.
  static const _kHardTimeout = Duration(seconds: 40);

  static Future<T> _withHardTimeout<T>(
    Future<T> Function() call, {
    required String method,
    required String url,
  }) {
    return call().timeout(
      _kHardTimeout,
      onTimeout: () {
        _log(
          '\n🚨 API TIMEOUT\n➡️ METHOD : $method\n➡️ URL : $url\n━━━━━━━━━━━━━━━━━━━━━━\n',
        );
        throw Exception(
          'The server took too long to respond. Please check your connection and try again.',
        );
      },
    );
  }

  // A click that triggers several notifiers reloading at once used to fire
  // 6-9 separate debugPrint calls per request (request + response, each
  // logged line-by-line) — under an attached debugger each debugPrint is a
  // real round trip over the VM service protocol, so a burst of a dozen
  // requests could mean 100+ of them back to back, visibly stalling the
  // UI thread on the very click that triggered the reload. One combined
  // call per event, skipped entirely outside debug builds, keeps the same
  // visibility without that cost.
  static void _log(String message) {
    if (kDebugMode) debugPrint(message);
  }

  // Wired up once by AuthNotifier via [configureAuthRefresh] — lets this
  // generic HTTP layer silently renew an expired access token on a 401
  // without knowing anything about Hive/token storage itself.
  static Future<bool> Function()? _attemptRefresh;

  static void configureAuthRefresh({
    required Future<bool> Function() attemptRefresh,
  }) {
    _attemptRefresh = attemptRefresh;
  }

  // Wired up once by EntitlementNotifier (mirroring [configureAuthRefresh]'s
  // own pattern) — lets this generic HTTP layer trigger the app-wide
  // access-restriction prompt on a blocked write action without knowing
  // anything about Provider/Navigator itself. Carries the specific
  // reason (see AccessRestrictionReasons) so one popup can show
  // different copy/actions for "no license" vs "expired" vs "feature
  // not on this plan", etc.
  static void Function(String reason)? _onAccessRestricted;

  static void configureSubscriptionGate({
    required void Function(String reason) onBlocked,
  }) {
    _onAccessRestricted = onBlocked;
  }

  // =========================
  // 🚀 INITIALIZE API SERVICE
  // =========================
  static Future<void> init() async {
    try {
      if (kIsWeb) {
        _cookieJar = CookieJar();
      } else {
        final Directory appDocDir = await getApplicationDocumentsDirectory();

        final String path = '${appDocDir.path}/.cookies/';

        await Directory(path).create(recursive: true);

        _cookieJar = PersistCookieJar(storage: FileStorage(path));
      }

      _dio = Dio(
        BaseOptions(
          baseUrl: ApiUrlConfig.baseurl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          responseType: ResponseType.json,
        ),
      );

      _dio.interceptors.add(CookieManager(_cookieJar));
      _dio.interceptors.add(_authRefreshInterceptor());

      _log("✅ ApiService Initialized");
    } catch (e) {
      _log("❌ ApiService Init Failed: $e");
      rethrow;
    }
  }

  // =========================
  // 🔄 SILENT TOKEN REFRESH ON 401
  // =========================
  // On any 401 (except auth endpoints themselves, which would otherwise
  // recurse), tries one silent refresh via the callback AuthNotifier
  // registered, then retries the original request with the new token.
  //
  // Multipart (FormData) requests are explicitly excluded here — Dio's
  // FormData is single-use (its file streams are consumed on send), so
  // blindly resending `error.requestOptions` for a file upload either
  // throws or silently sends an empty body. [multipart] below handles its
  // own refresh-and-retry by rebuilding a fresh FormData instead.
  //
  // A plain (non-queued) interceptor deliberately — a `QueuedInterceptor`
  // was tried first, but it advances to the next queued 401 only once the
  // current one's handler calls next/resolve/reject, i.e. only after that
  // request's *entire* refresh-then-retry cycle finishes. With several
  // requests 401ing around the same moment (an access token expiring
  // mid-session usually fails a handful at once), that serializes them
  // into one full cycle after another — by the time request 2 is even
  // looked at, request 1's refresh has already completed and been
  // cleared, so there's never a moment where two requests are actually
  // both waiting on it. `_refreshInProgress` below is what actually
  // de-duplicates the refresh call instead: since a plain interceptor
  // invokes every concurrent 401's `onError` right away, all of them can
  // genuinely observe the same in-flight Future and share it, rather than
  // each doing its own redundant round trip to the refresh endpoint (and
  // Hive write) one after another.
  static Future<bool>? _refreshInProgress;

  // Actually performs one refresh attempt, bounded so a wedged Hive box
  // or a dropped connection dio's own timeout somehow missed can't hang
  // this forever.
  static Future<bool> _runRefresh() async {
    try {
      return await _attemptRefresh!().timeout(
        _kHardTimeout,
        onTimeout: () => false,
      );
    } catch (_) {
      return false;
    }
  }

  static Interceptor _authRefreshInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) async {
        final statusCode = error.response?.statusCode;
        final alreadyRetried = error.requestOptions.extra['retried'] == true;
        final isAuthEndpoint = error.requestOptions.path.contains('/auth/');
        final isMultipart = error.requestOptions.data is FormData;

        if (statusCode != 401 ||
            alreadyRetried ||
            isAuthEndpoint ||
            isMultipart ||
            _attemptRefresh == null) {
          return handler.next(error);
        }

        final startedHere = _refreshInProgress == null;
        final refreshFuture = _refreshInProgress ??= _runRefresh();
        if (startedHere) {
          unawaited(
            refreshFuture.whenComplete(() {
              if (identical(_refreshInProgress, refreshFuture)) {
                _refreshInProgress = null;
              }
            }),
          );
        }
        final refreshed = await refreshFuture;
        if (!refreshed) {
          return handler.next(error);
        }

        try {
          final retryOptions = error.requestOptions;
          retryOptions.extra['retried'] = true;
          retryOptions.headers['Authorization'] =
              _dio.options.headers['Authorization'];
          final response = await _dio.fetch(retryOptions);
          return handler.resolve(response);
        } on DioException catch (retryError) {
          return handler.next(retryError);
        }
      },
    );
  }

  // =========================
  // 🔐 AUTH HEADER
  // =========================
  // Set after OTP verification / session restore, cleared on logout.
  // Every request made through this service after that point carries the
  // bearer token automatically — screens never touch headers themselves.
  static void setAuthToken(String accessToken) {
    _dio.options.headers['Authorization'] = 'Bearer $accessToken';
  }

  static void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  // =========================
  // 🔌 RESET STALE CONNECTIONS
  // =========================
  // dart:io's HttpClient pools and reuses TCP connections, closing ones
  // that have been idle past its own idleTimeout — but that close-when-idle
  // logic runs on a timer, which doesn't fire while the app is suspended
  // (backgrounded / device asleep). After a long suspension, the client can
  // still be holding sockets the OS or an intermediate proxy silently
  // killed hours ago; the first request made on resume tries to reuse one
  // and hangs or fails instead of erroring fast.
  //
  // Swaps in a brand-new adapter so the next request opens a fresh
  // connection, and closes the old one WITHOUT `force` so anything already
  // in flight on it finishes normally instead of getting aborted. This
  // must not call `close()` on `_dio.httpClientAdapter` itself and keep
  // using it afterwards — `IOHttpClientAdapter.close()` latches an
  // internal `_closed` flag that's never cleared, so every request made
  // through that same adapter after the first call permanently throws
  // "Can't establish connection after the adapter was closed." Swapping
  // the instance is what keeps the fix from bricking the whole session
  // the moment it fires once.
  static void resetConnection() {
    final stale = _dio.httpClientAdapter;
    _dio.httpClientAdapter = HttpClientAdapter();
    stale.close();
  }

  // =========================
  // 🔁 RAW POST (rethrows the original DioException)
  // =========================
  // Used only by AuthNotifier's refresh-token flow, which needs to tell a
  // genuine server-side rejection (refresh token invalid/expired — should
  // force a logout) apart from a network-level failure (should not: the
  // refresh token itself may still be fine). Every other caller goes
  // through [post], which flattens errors into a plain [Exception] with a
  // display-ready message instead.
  static Future<dynamic> postRaw(
    String url, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _dio.post(
      url,
      data: body,
      options: Options(
        headers: {Headers.contentTypeHeader: Headers.jsonContentType},
      ),
    );
    return response.data;
  }

  // =========================
  // 🔵 GET REQUEST
  // =========================
  static Future<dynamic> get(
    String url, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
  }) async {
    return _request(method: "GET", url: url, query: query, headers: headers);
  }

  // =========================
  // 🟢 POST REQUEST
  // =========================
  static Future<dynamic> post(
    String url, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? headers,
  }) async {
    return _request(method: "POST", url: url, body: body, headers: headers);
  }

  // =========================
  // 🟠 PUT REQUEST
  // =========================
  static Future<dynamic> put(
    String url, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? headers,
  }) async {
    return _request(method: "PUT", url: url, body: body, headers: headers);
  }

  // =========================
  // 🔴 DELETE REQUEST
  // =========================
  static Future<dynamic> delete(
    String url, {
    Map<String, dynamic>? headers,
  }) async {
    return _request(method: "DELETE", url: url, headers: headers);
  }

  // =========================
  // 📷 SINGLE FILE MULTIPART
  // =========================
  static Future<dynamic> postMultipart(
    String url, {
    required Map<String, dynamic> fields,
    required String fileKey,
    required UploadFile file,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final FormData formData = FormData();

      fields.forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });

      formData.files.add(MapEntry(fileKey, await file.toMultipart()));

      _log(
        '\n━━━━━━━━━━━━━━━━━━━━━━\n'
        '📡 API MULTIPART REQUEST\n'
        '➡️ METHOD : POST\n'
        '➡️ URL : $url\n'
        '📦 FORM DATA : ${{for (final f in formData.fields) f.key: f.value}}\n'
        '📁 FILES : ${formData.files.map((f) => '${f.key}:${f.value.filename}').join(', ')}\n'
        '━━━━━━━━━━━━━━━━━━━━━━\n',
      );

      final response = await _withHardTimeout(
        () => _dio.post(
          url,
          data: formData,
          options: Options(
            headers: {
              ...?headers,
              Headers.contentTypeHeader: Headers.multipartFormDataContentType,
            },
          ),
        ),
        method: 'POST (MULTIPART)',
        url: url,
      );

      _log('✅ RESPONSE [${response.statusCode}]\n📦 DATA : ${response.data}');

      return response.data;
    } on DioException catch (e) {
      return _handleError(e, "POST (MULTIPART)", url);
    }
  }

  // =========================
  // 📷 FLEXIBLE MULTIPART
  // =========================
  // Builds a fresh FormData per attempt (see [_authRefreshInterceptor] for
  // why that matters) and does its own one-shot 401-refresh-and-retry
  // rather than relying on the generic interceptor.
  static Future<dynamic> multipart(
    String url, {
    required Map<String, dynamic> fields,
    Map<String, UploadFile>? files,
    Map<String, dynamic>? headers,
    String method = "POST",
  }) async {
    Future<FormData> buildFormData() async {
      final formData = FormData();

      fields.forEach((key, value) {
        if (value != null) {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      });

      if (files != null && files.isNotEmpty) {
        for (final entry in files.entries) {
          formData.files.add(
            MapEntry(entry.key, await entry.value.toMultipart()),
          );
        }
      }

      return formData;
    }

    Future<Response> sendOnce() async {
      final formData = await buildFormData();

      _log(
        '\n━━━━━━━━━━━━━━━━━━━━━━\n'
        '📡 API MULTIPART REQUEST\n'
        '➡️ METHOD : $method\n'
        '➡️ URL : $url\n'
        '📦 FORM DATA : ${{for (final f in formData.fields) f.key: f.value}}\n'
        '📁 FILES : ${formData.files.map((f) => '${f.key}:${f.value.filename}').join(', ')}\n'
        '━━━━━━━━━━━━━━━━━━━━━━\n',
      );

      return _withHardTimeout(
        () => _dio.request(
          url,
          data: formData,
          options: Options(
            method: method,
            headers: {
              ...?headers,
              Headers.contentTypeHeader: Headers.multipartFormDataContentType,
            },
          ),
        ),
        method: method,
        url: url,
      );
    }

    try {
      Response response;
      try {
        response = await sendOnce();
      } on DioException catch (e) {
        final attemptRefresh = _attemptRefresh;
        final canRetry =
            e.response?.statusCode == 401 &&
            attemptRefresh != null &&
            !url.contains('/auth/');
        if (!canRetry || !await attemptRefresh()) rethrow;
        response = await sendOnce();
      }

      _log('✅ RESPONSE [${response.statusCode}]\n📦 DATA : ${response.data}');

      return response.data;
    } on DioException catch (e) {
      return _handleError(e, "MULTIPART", url);
    }
  }

  // =========================
  // ⚙️ COMMON REQUEST HANDLER
  // =========================
  static Future<dynamic> _request({
    required String method,
    required String url,
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
  }) async {
    try {
      _log(
        '\n━━━━━━━━━━━━━━━━━━━━━━\n'
        '📡 API REQUEST\n'
        '➡️ METHOD : $method\n'
        '➡️ URL : $url\n'
        '➡️ HEADERS : ${headers ?? {}}\n'
        '➡️ BODY : $body\n'
        '➡️ QUERY : $query\n'
        '━━━━━━━━━━━━━━━━━━━━━━\n',
      );

      Future<Response> send() {
        switch (method) {
          case "POST":
            return _dio.post(
              url,
              data: body,
              options: Options(
                headers: {
                  ...?headers,
                  Headers.contentTypeHeader: Headers.jsonContentType,
                },
              ),
            );

          case "PUT":
            return _dio.put(
              url,
              data: body,
              options: Options(
                headers: {
                  ...?headers,
                  Headers.contentTypeHeader: Headers.jsonContentType,
                },
              ),
            );

          case "DELETE":
            return _dio.delete(url, options: Options(headers: headers));

          default:
            return _dio.get(
              url,
              queryParameters: query,
              options: Options(headers: headers),
            );
        }
      }

      final response = await _withHardTimeout(send, method: method, url: url);

      _log('✅ RESPONSE [${response.statusCode}]\n📦 DATA : ${response.data}\n');

      return response.data;
    } on DioException catch (e) {
      return _handleError(e, method, url);
    } on Exception {
      // Already a display-ready message — from _withHardTimeout's own
      // timeout, most likely — so it passes straight through instead of
      // being flattened into a generic one below.
      rethrow;
    } catch (e) {
      _log("❌ UNKNOWN ERROR : $e");
      throw Exception("Unexpected error occurred");
    }
  }

  // =========================
  // ❌ ERROR HANDLING
  // =========================
  static dynamic _handleError(DioException error, String method, String url) {
    final statusCode = error.response?.statusCode;

    final responseData = error.response?.data;

    _log(
      '\n🚨 API ERROR\n'
      '➡️ METHOD : $method\n'
      '➡️ URL : $url\n'
      '➡️ STATUS : $statusCode\n'
      // message is null for connection-level failures (DNS, TLS, refused);
      // the type and the underlying exception are what say why.
      '➡️ TYPE : ${error.type.name}\n'
      '➡️ ERROR : ${error.message ?? error.error}\n'
      '➡️ RESPONSE : $responseData\n'
      '━━━━━━━━━━━━━━━━━━━━━━\n',
    );

    String message = "Something went wrong";
    String? reason;

    if (responseData is Map && responseData['message'] != null) {
      message = responseData['message'].toString();
      final errors = responseData['errors'];
      if (errors is Map && errors['reason'] != null) {
        reason = errors['reason'].toString();
      }
    } else if (error.message != null) {
      message = error.message!;
    }

    if (reason != null && AccessRestrictionReasons.all.contains(reason)) {
      _onAccessRestricted?.call(reason);
    }

    throw ApiException(message, reason: reason);
  }
}
