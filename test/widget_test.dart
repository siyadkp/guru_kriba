import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guru_kripa/main.dart';
import 'package:guru_kripa/model/site_content/site_content.dart';
import 'package:guru_kripa/utils/constants/app_contact.dart';
import 'package:guru_kripa/view/home_page/sections/booking_section.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

/// Records launched URLs instead of opening them.
class _FakeLauncher extends UrlLauncherPlatform
    with MockPlatformInterfaceMixin {
  final launched = <String>[];

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launched.add(url);
    return true;
  }
}

/// Scrolls [finder] to the middle of the screen, clear of the sticky header,
/// and waits for its scroll-in animation (content is not tappable while it
/// is still invisible).
Future<void> _scrollIntoView(WidgetTester tester, Finder finder) async {
  Scrollable.ensureVisible(tester.element(finder), alignment: 0.5);
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 500));
  }
}

Future<void> _pumpSite(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const MyApp());
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  setUp(() {});

  for (final (name, size) in [
    ('desktop', const Size(1440, 900)),
    ('tablet', const Size(820, 1180)),
    ('mobile', const Size(390, 844)),
  ]) {
    testWidgets('renders every section without layout errors on $name', (
      tester,
    ) async {
      await _pumpSite(tester, size);

      expect(find.textContaining('Inner Harmony'), findsOneWidget);
      expect(find.text(SiteContent.welcomeTitle), findsOneWidget);
      expect(find.text(SiteContent.aboutTitle), findsOneWidget);
      expect(find.text(SiteContent.poojaTitle), findsOneWidget);
      expect(find.text('Book Your Consultation'), findsOneWidget);
      expect(find.text('Frequently Asked Questions'), findsOneWidget);
      expect(find.text('Get in Touch'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('booking form requires name, phone and service', (tester) async {
    await _pumpSite(tester, const Size(1440, 900));

    final submit = find.text('SEND BOOKING REQUEST ON WHATSAPP');
    await _scrollIntoView(tester, submit);
    await tester.tap(submit);
    await tester.pump();

    expect(find.text('Please enter your name'), findsOneWidget);
    expect(
      find.text('Please enter your phone / WhatsApp number'),
      findsOneWidget,
    );
    expect(find.text('Please choose a service'), findsOneWidget);
  });

  testWidgets('"Book this service" preselects the service in the form', (
    tester,
  ) async {
    await _pumpSite(tester, const Size(1440, 900));

    final link = find.text('Book this service').first;
    await _scrollIntoView(tester, link);
    await tester.tap(link);
    await tester.pump(const Duration(seconds: 2));

    final form = find.byType(BookingForm);
    expect(
      find.descendant(
        of: form,
        matching: find.text(SiteContent.services.first.bookingLabel!),
      ),
      findsOneWidget,
    );
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
  });

  testWidgets('a filled-in booking opens WhatsApp with the booking message', (
    tester,
  ) async {
    final launcher = _FakeLauncher();
    UrlLauncherPlatform.instance = launcher;
    await _pumpSite(tester, const Size(1440, 900));

    // Preselect the service from its card, then fill in the form.
    final link = find.text('Book this service').first;
    await _scrollIntoView(tester, link);
    await tester.tap(link);
    await tester.pump(const Duration(seconds: 2));

    final name = find.widgetWithText(TextFormField, 'Full name *');
    await _scrollIntoView(tester, name);
    await tester.enterText(name, 'Test Client');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Phone / WhatsApp *'),
      '+91 98765 43210',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Brief question / note'),
      'Career guidance',
    );

    final submit = find.text('SEND BOOKING REQUEST ON WHATSAPP');
    await _scrollIntoView(tester, submit);
    await tester.tap(submit);
    await tester.pump(const Duration(seconds: 1));

    expect(launcher.launched, hasLength(1));
    final uri = Uri.parse(launcher.launched.single);
    expect(uri.host, 'wa.me');
    expect(uri.path, '/${AppContact.whatsappNumber}');
    final text = uri.queryParameters['text']!;
    expect(text, contains('*Name:* Test Client'));
    expect(text, contains('*Phone / WhatsApp:* +91 98765 43210'));
    expect(
      text,
      contains('*Service:* ${SiteContent.services.first.bookingLabel}'),
    );
    expect(text, contains('*Consultation format:* Online (Video)'));
    expect(text, contains('Career guidance'));
    expect(text, isNot(contains('*Email:*')));
  });

  for (final (name, size) in [
    ('desktop', const Size(1440, 900)),
    ('tablet', const Size(820, 1180)),
    ('mobile', const Size(360, 740)),
  ]) {
    testWidgets('scrolls the whole page on $name without errors', (
      tester,
    ) async {
      await _pumpSite(tester, size);
      final scrollable = find.byType(Scrollable).first;
      final position = tester.state<ScrollableState>(scrollable).position;
      while (position.pixels < position.maxScrollExtent) {
        position.jumpTo(
          (position.pixels + size.height * 0.8).clamp(
            0.0,
            position.maxScrollExtent,
          ),
        );
        await tester.pump(const Duration(milliseconds: 120));
        expect(tester.takeException(), isNull);
      }
      // And all the way back up.
      position.jumpTo(0);
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
    });
  }
}
