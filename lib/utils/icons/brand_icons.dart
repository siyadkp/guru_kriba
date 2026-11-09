import 'package:flutter/widgets.dart';

/// Brand logos used on the site.
///
/// The WhatsApp glyph comes from Font Awesome Free (fontawesome.com,
/// SIL Open Font License 1.1), subset to that single icon so the font is
/// ~1.5 KB instead of loading the full icon fonts (~500 KB) at startup.
/// Font file: assets/fonts/BrandIcons.otf (declared in pubspec.yaml).
class BrandIcons {
  static const IconData whatsapp = IconData(0xf232, fontFamily: 'BrandIcons');
}
