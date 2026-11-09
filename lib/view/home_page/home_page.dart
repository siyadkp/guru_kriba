import 'package:flutter/material.dart';
import 'package:guru_kripa/model/site_content/site_content.dart';
import 'package:guru_kripa/utils/colors/app_colors.dart';
import 'package:guru_kripa/utils/responsive/responsive.dart';
import 'package:guru_kripa/view/home_page/sections/about_section.dart';
import 'package:guru_kripa/view/home_page/sections/astrologer_section.dart';
import 'package:guru_kripa/view/home_page/sections/booking_section.dart';
import 'package:guru_kripa/view/home_page/sections/contact_section.dart';
import 'package:guru_kripa/view/home_page/sections/faq_section.dart';
import 'package:guru_kripa/view/home_page/sections/hero_section.dart';
import 'package:guru_kripa/view/home_page/sections/services_section.dart';
import 'package:guru_kripa/view/home_page/sections/site_footer.dart';
import 'package:guru_kripa/view/home_page/sections/site_header.dart';
import 'package:guru_kripa/view/home_page/sections/testimonials_section.dart';
import 'package:guru_kripa/view/home_page/sections/topics_section.dart';
import 'package:guru_kripa/view/home_page/sections/welcome_section.dart';
import 'package:guru_kripa/view/home_page/sections/why_choose_section.dart';
import 'package:guru_kripa/view/widgets/celestial/celestial.dart';
import 'package:guru_kripa/view/widgets/viewport/viewport.dart';
import 'package:guru_kripa/view/widgets/whatsapp_fab/whatsapp_fab.dart';

/// The whole website on a single scrolling page.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scroll = ScrollController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _sectionKeys = {for (final s in SiteSection.values) s: GlobalKey()};
  final _selectedService = ValueNotifier<String?>(null);
  final _welcomeKey = GlobalKey();
  final _progress = ValueNotifier<double>(0);

  bool _scrolled = false;
  bool _showBackToTop = false;
  SiteSection _active = SiteSection.home;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _selectedService.dispose();
    _progress.dispose();
    super.dispose();
  }

  void _onScroll() {
    PageScroll.ping();
    final offset = _scroll.offset;
    final max = _scroll.position.maxScrollExtent;
    _progress.value = max > 0 ? offset / max : 0;
    final scrolled = offset > 40;
    final showTop = offset > 900;
    final active = _currentSection();
    if (scrolled != _scrolled ||
        showTop != _showBackToTop ||
        active != _active) {
      setState(() {
        _scrolled = scrolled;
        _showBackToTop = showTop;
        _active = active;
      });
    }
  }

  /// The last section whose top has passed just below the header.
  SiteSection _currentSection() {
    final threshold = context.headerHeight + 140;
    var current = SiteSection.home;
    for (final s in SiteSection.values) {
      final box = _sectionKeys[s]!.currentContext?.findRenderObject();
      if (box is! RenderBox || !box.attached) continue;
      if (box.localToGlobal(Offset.zero).dy <= threshold) current = s;
    }
    // At the very bottom the last section may be too short to reach the
    // threshold.
    if (_scroll.hasClients &&
        _scroll.offset >= _scroll.position.maxScrollExtent - 4) {
      current = SiteSection.contact;
    }
    return current;
  }

  Future<void> _scrollToKey(GlobalKey key) async {
    final box = key.currentContext?.findRenderObject();
    if (box is! RenderBox || !_scroll.hasClients) return;
    final target =
        (_scroll.offset +
                box.localToGlobal(Offset.zero).dy -
                context.headerHeight +
                1)
            .clamp(0.0, _scroll.position.maxScrollExtent);
    await _scroll.animateTo(
      target,
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOutCubic,
    );
  }

  void _navigate(SiteSection section) {
    if (section == SiteSection.home) {
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeInOutCubic,
      );
      return;
    }
    _scrollToKey(_sectionKeys[section]!);
  }

  void _bookService(String serviceLabel) {
    // Reset first so choosing the same service again still notifies.
    _selectedService.value = null;
    _selectedService.value = serviceLabel;
    _navigate(SiteSection.booking);
  }

  // Each section is its own repaint layer: while scrolling, already-drawn
  // sections are just moved instead of re-recorded every frame.
  Widget _section(SiteSection s, Widget child) => KeyedSubtree(
    key: _sectionKeys[s],
    child: RepaintBoundary(child: child),
  );

  @override
  Widget build(BuildContext context) {
    void book() => _navigate(SiteSection.booking);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.offWhite,
      endDrawer: MobileNavDrawer(active: _active, onNavigate: _navigate),
      body: ViewportScope(
        controller: _scroll,
        child: CursorSparkles(
          child: Stack(
            children: [
              SingleChildScrollView(
                controller: _scroll,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _section(
                      SiteSection.home,
                      HeroSection(
                        onBook: book,
                        onExplore: () => _scrollToKey(_welcomeKey),
                      ),
                    ),
                    KeyedSubtree(
                      key: _welcomeKey,
                      child: const RepaintBoundary(child: WelcomeSection()),
                    ),
                    _section(SiteSection.about, const AboutSection()),
                    _section(
                      SiteSection.astrologer,
                      AstrologerSection(onBook: book),
                    ),
                    _section(
                      SiteSection.services,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ServicesSection(onBookService: _bookService),
                          const TopicsSection(),
                        ],
                      ),
                    ),
                    _section(SiteSection.whyUs, const WhyChooseSection()),
                    _section(
                      SiteSection.booking,
                      BookingSection(selectedService: _selectedService),
                    ),
                    _section(
                      SiteSection.testimonials,
                      const TestimonialsSection(),
                    ),
                    _section(SiteSection.faq, const FaqSection()),
                    _section(SiteSection.contact, const ContactSection()),
                    RepaintBoundary(child: SiteFooter(onNavigate: _navigate)),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SiteHeader(
                  solid: _scrolled,
                  active: _active,
                  onNavigate: _navigate,
                  onMenu: () => _scaffoldKey.currentState?.openEndDrawer(),
                  progress: _progress,
                ),
              ),
              Positioned(
                right: context.isMobile ? 16 : 28,
                bottom: context.isMobile ? 16 : 28,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Phones skip it: it would cover text, and tapping the
                    // logo already returns to the top.
                    if (!context.isMobile) ...[
                      _BackToTop(
                        visible: _showBackToTop,
                        onTap: () => _navigate(SiteSection.home),
                      ),
                      const SizedBox(height: 14),
                    ],
                    const RepaintBoundary(child: WhatsAppFab()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackToTop extends StatelessWidget {
  const _BackToTop({required this.visible, required this.onTap});

  final bool visible;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedSlide(
        offset: visible ? Offset.zero : const Offset(0, 0.6),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: Padding(
            padding: const EdgeInsets.only(right: 7),
            child: Tooltip(
              message: 'Back to top',
              child: Material(
                color: AppColors.charcoal,
                shape: const CircleBorder(),
                elevation: 6,
                shadowColor: Colors.black38,
                child: InkWell(
                  onTap: onTap,
                  customBorder: const CircleBorder(),
                  child: const SizedBox.square(
                    dimension: 46,
                    child: Icon(
                      Icons.arrow_upward,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
