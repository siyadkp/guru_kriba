/// Business contact details shown on the website and used by every
/// Call / WhatsApp / Email / Map button.
class AppContact {
  /// WhatsApp number in international format, digits only.
  static const String whatsappNumber = '919072018750';

  /// Phone number as dialled (used for "Call Now").
  static const String phoneDial = '+919072018750';

  /// Phone number as displayed on the page.
  static const String phoneDisplay = '+91 90720 18750';

  static const String email = 'vishnucs.careers@gmail.com';

  /// Office address, as shown on the page. Non-breaking spaces (\u00A0)
  /// keep each part together, so lines only break after commas.
  static const String officeLocation =
      'Gurukripa\u00A0Astro\u00A0Science, Canal\u00A0Road, Aluva, '
      'Ernakulam, Kerala\u00A0–\u00A0683102';

  /// Address used for the "open in Google Maps" link.
  static const String mapsQuery =
      'Gurukripa Astro Science, Canal Road, Aluva, Ernakulam, Kerala 683102';

  static const String consultationFormat =
      'Online Audio/Video Sessions & In-Person Appointments';

  static const String defaultWhatsAppMessage =
      'Hello Guru Kripa Astro Science, I would like to know more about your '
      'consultation and spiritual services.';
}
