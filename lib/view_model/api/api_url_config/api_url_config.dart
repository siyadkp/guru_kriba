import 'package:guru_kripa/view_model/api/app_config/app_config.dart';

class ApiUrlConfig {
  static String get baseurl => _baseUrl;

  // TEST — Cloudways app "erp" (cvscscsfmv). The original backend;
  // every debug build (flutter run, no --release) talks to this one.
  static const String _testBaseUrl =
      'https://phplaravel-1650272-6619356.cloudwaysapps.com/api/v1';

  // LIVE — Cloudways app "erp_live_backend" (unfwkrnvgc). The real
  // production backend; only a --release build talks to this one.
  static const String _liveBaseUrl =
      'https://phpstack-1650272-6697031.cloudwaysapps.com/api/v1';

  // Explicit --dart-define=API_ENV=test|live overrides the debug/release
  // default below — needed because build MODE (debug/release) and which
  // BACKEND to talk to are two separate concerns: a --release build is
  // still wanted for anything actually hosted/handed to a real user
  // (fast, tree-shaken, production-quality JS — a plain --debug web
  // build is roughly 3-4x larger, since it skips all of that, and was
  // never meant to be deployed anywhere, only run locally), even when
  // that hosted copy is deliberately meant to point at the TEST
  // backend (e.g. a test-hosting deploy for browser-based QA). Without
  // this override, the only way to reach the test backend was a full
  // --debug build, which is correct for `flutter run` locally but
  // wrong for anything actually served from a real host.
  static const String _apiEnvOverride = String.fromEnvironment('API_ENV');

  // Which of the two a running app actually hits is never trusted on
  // its own — EnvironmentNotifier asks the connected backend's own
  // GET /environment (see below) what it actually is, and only that
  // answer ever shows the TEST badge. This split just decides which
  // server gets asked in the first place.
  static final String _baseUrl = switch (_apiEnvOverride) {
    'test' => _testBaseUrl,
    'live' => _liveBaseUrl,
    _ => buldMode == BuildMode.release ? _liveBaseUrl : _testBaseUrl,
  };

  // ===================== ENVIRONMENT ENDPOINT =====================
  // Public, unauthenticated — see core/routes.js (backend). Whichever
  // real backend _baseUrl above actually points at (TEST or LIVE), this
  // asks THAT one what it is; the badge must never be inferred from the
  // URL text itself (see EnvironmentNotifier's own doc comment).
  static String environment() => '$_baseUrl/environment/';

  // ========================= AUTH ENDPOINTS =========================
  static String otpRequest() => '$_baseUrl/auth/otp/request/';
  static String otpVerify() => '$_baseUrl/auth/otp/verify/';
  static String logout() => '$_baseUrl/auth/logout/';
  static String tokenRefresh() => '$_baseUrl/auth/token/refresh/';

  // ===================== BUSINESS PROFILE ENDPOINTS =====================
  static String businessProfile() => '$_baseUrl/business-profile/';

  // ========================= PARTY ENDPOINTS =========================
  static String parties() => '$_baseUrl/parties/';
  static String partyUpdate(String uuid) => '$_baseUrl/parties/$uuid/';
  static String partyImportBatches() => '$_baseUrl/party-import-batches/';
  static String partyImportBatchRevert(String uuid) =>
      '$_baseUrl/party-import-batches/$uuid/revert/';
  static String partyStatementLink(String uuid) =>
      '$_baseUrl/parties/$uuid/statement-link/';

  // ========================= ITEM ENDPOINTS =========================
  static String items() => '$_baseUrl/items/';
  static String itemUpdate(String uuid) => '$_baseUrl/items/$uuid/';
  static String itemTransactions(String uuid) =>
      '$_baseUrl/items/$uuid/transactions';

  // ==================== UNIT / CATEGORY ENDPOINTS ====================
  static String units() => '$_baseUrl/units/';
  static String unitUpdate(String uuid) => '$_baseUrl/units/$uuid/';
  static String categories() => '$_baseUrl/categories/';
  static String categoryUpdate(String uuid) => '$_baseUrl/categories/$uuid/';
  static String partyGroups() => '$_baseUrl/party-groups/';
  static String godowns() => '$_baseUrl/godowns/';

  // ==================== STOCK ADJUSTMENT ENDPOINTS ====================
  static String stockAdjustments() => '$_baseUrl/stock-adjustments/';

  // ========================= PURCHASE ENDPOINTS =========================
  static String purchases() => '$_baseUrl/purchases/';
  static String purchaseDetail(String uuid) => '$_baseUrl/purchases/$uuid/';
  static String purchaseReturns() => '$_baseUrl/purchase-returns/';
  static String purchaseReturnDetail(String uuid) =>
      '$_baseUrl/purchase-returns/$uuid/';

  // ========================= SALE ENDPOINTS =========================
  static String sales() => '$_baseUrl/sales/';
  static String saleItemTotals() => '$_baseUrl/sales/item-totals/';
  static String saleDetail(String uuid) => '$_baseUrl/sales/$uuid/';
  static String saleReturns() => '$_baseUrl/sale-returns/';
  static String saleReturnDetail(String uuid) =>
      '$_baseUrl/sale-returns/$uuid/';

  // ========================= PAYMENT / EXPENSE ENDPOINTS =========================
  static String payments() => '$_baseUrl/payments/';
  static String paymentDetail(String uuid) => '$_baseUrl/payments/$uuid/';
  static String expenses() => '$_baseUrl/expenses/';
  static String expenseDetail(String uuid) => '$_baseUrl/expenses/$uuid/';
  static String expenseItems() => '$_baseUrl/expense-items/';
  static String expenseItemDetail(String uuid) =>
      '$_baseUrl/expense-items/$uuid/';
  static String expenseCategories() => '$_baseUrl/expense-categories/';
  static String expenseCategoryDetail(String uuid) =>
      '$_baseUrl/expense-categories/$uuid/';

  // ========================= BANK ENDPOINTS =========================
  static String bankAccounts() => '$_baseUrl/bank-accounts/';
  static String bankTransactions() => '$_baseUrl/bank-transactions/';
  static String bankTransactionsForAccount(String accountUuid) =>
      '$_baseUrl/bank-transactions/?account_uuid=$accountUuid';
  static String bankTransactionDetail(String uuid) =>
      '$_baseUrl/bank-transactions/$uuid';

  // Uploaded logo/signature paths come back from the API as
  // "/uploads/...". Routed through "/api/v1/uploads/..." (not bare
  // "/uploads/..." against the host root) because Cloudways' nginx layer
  // serves that bare path directly off disk for image extensions,
  // bypassing this app's own CORS middleware entirely — invisible to a
  // native app (CORS is a browser-only concept) but silently blanks the
  // image on web, which fetches these bytes itself (NetworkImage/
  // Image.network) rather than using a plain <img> tag. See app.js's own
  // matching /api/v1/uploads mount for the server side of this.
  static String resolveUploadUrl(String path) {
    final host = _baseUrl.replaceFirst('/api/v1', '');
    final upload = path.replaceFirst('/uploads/', '/api/v1/uploads/');
    return '$host$upload';
  }

  // ==================== SUBSCRIPTION / LICENSE ENDPOINTS ====================
  static String subscriptionPlans() => '$_baseUrl/subscription/plans';
  static String subscriptionPlanDetail(String uuid) =>
      '$_baseUrl/subscription/plans/$uuid';
  static String subscriptionOrders() => '$_baseUrl/subscription/orders';
  static String subscriptionOrderDetail(String uuid) =>
      '$_baseUrl/subscription/orders/$uuid';
  static String subscriptionOrderPayment(String uuid) =>
      '$_baseUrl/subscription/orders/$uuid/payment';
  static String subscriptionPaymentVerify() =>
      '$_baseUrl/subscription/payment/verify';
  static String mySubscriptions() => '$_baseUrl/subscriptions';
  static String licenses() => '$_baseUrl/licenses';
  static String licenseDetail(String uuid) => '$_baseUrl/licenses/$uuid';
  static String licenseDeviceHistory(String uuid) =>
      '$_baseUrl/licenses/$uuid/device-history';
  static String licenseAttach(String uuid) => '$_baseUrl/licenses/$uuid/attach';
  static String licenseChangeDevice(String uuid) =>
      '$_baseUrl/licenses/$uuid/change-device';
  static String licenseVerifyOtp(String uuid) =>
      '$_baseUrl/licenses/$uuid/verify-otp';
  static String licenseDetach(String uuid) => '$_baseUrl/licenses/$uuid/detach';
  static String licenseVerifyIdentityRequest() =>
      '$_baseUrl/licenses/verify-identity/request';
  static String licenseVerifyIdentityVerify() =>
      '$_baseUrl/licenses/verify-identity/verify';
  static String licenseAttachVerified(String uuid) =>
      '$_baseUrl/licenses/$uuid/attach-verified';
  static String validateDevice() => '$_baseUrl/licenses/validate-device';
  static String entitlements() => '$_baseUrl/entitlements';

  // ==================== COMPANY ENDPOINTS ====================
  static String companies() => '$_baseUrl/companies/';
  static String companySwitch(String uuid) =>
      '$_baseUrl/companies/$uuid/switch';

  // ==================== TRANSACTION PREFIX ENDPOINTS ====================
  static String documentPrefixes() => '$_baseUrl/document-prefixes/';
  static String documentPrefixUpdate(String documentType) =>
      '$_baseUrl/document-prefixes/$documentType';
  static String documentPrefixOptionAdd(String documentType) =>
      '$_baseUrl/document-prefixes/$documentType/options';
  static String documentPrefixOptionDelete(String documentType, String uuid) =>
      '$_baseUrl/document-prefixes/$documentType/options/$uuid';
}
