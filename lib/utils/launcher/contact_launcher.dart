import 'package:flutter/foundation.dart';
import 'package:guru_kripa/utils/constants/app_contact.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens WhatsApp, the phone dialler and the mail client.
/// Every method returns false instead of throwing when nothing can handle
/// the link, so callers can show a friendly message.
class ContactLauncher {
  static Uri whatsappUri([String? message]) {
    final text = message ?? AppContact.defaultWhatsAppMessage;
    return Uri.parse(
      'https://wa.me/${AppContact.whatsappNumber}'
      '?text=${Uri.encodeComponent(text)}',
    );
  }

  static Future<bool> openWhatsApp([String? message]) =>
      _open(whatsappUri(message), newTab: true);

  static Future<bool> call() =>
      _open(Uri(scheme: 'tel', path: AppContact.phoneDial));

  static Future<bool> email({String? subject}) => _open(
    Uri(
      scheme: 'mailto',
      path: AppContact.email,
      query: subject == null ? null : 'subject=${Uri.encodeComponent(subject)}',
    ),
  );

  static Future<bool> _open(Uri uri, {bool newTab = false}) async {
    try {
      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: newTab ? '_blank' : '_self',
      );
    } catch (e) {
      debugPrint('Could not open $uri: $e');
      return false;
    }
  }
}
