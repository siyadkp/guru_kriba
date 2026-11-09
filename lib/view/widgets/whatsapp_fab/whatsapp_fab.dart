import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:guru_kripa/utils/colors/app_colors.dart';
import 'package:guru_kripa/utils/launcher/contact_launcher.dart';
import 'package:guru_kripa/utils/theme/app_text.dart';
import 'package:guru_kripa/view/widgets/viewport/viewport.dart';

/// Floating WhatsApp button with a pulsing ring. On hover (desktop) a
/// "Chat on WhatsApp" label slides out to the left.
class WhatsAppFab extends StatefulWidget {
  const WhatsAppFab({super.key});

  @override
  State<WhatsAppFab> createState() => _WhatsAppFabState();
}

class _WhatsAppFabState extends State<WhatsAppFab> {
  /// Pulse progress 0–1. The ring animates for 1.6 s, then rests for
  /// 1.6 s — while resting nothing changes, so no frames are drawn.
  final _pulse = ValueNotifier<double>(1);
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    FrameClock.instance.addListener(_tick);
  }

  void _tick() {
    const cycle = 3200, active = 1600;
    final ms = FrameClock.instance.elapsed.inMilliseconds % cycle;
    _pulse.value = ms < active ? ms / active : 1;
  }

  @override
  void dispose() {
    FrameClock.instance.removeListener(_tick);
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    final ok = await ContactLauncher.openWhatsApp();
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open WhatsApp on this device.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Slightly smaller on phones so it covers less text.
    final size = MediaQuery.sizeOf(context).width < 700 ? 52.0 : 60.0;
    return Semantics(
      button: true,
      label: 'Chat on WhatsApp',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: _open,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                child: _hovered
                    ? Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.charcoal,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          'Chat on WhatsApp',
                          style: AppText.body(
                            13,
                            color: Colors.white,
                            weight: FontWeight.w600,
                            height: 1.2,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              SizedBox.square(
                dimension: size,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (context, _) {
                        final t = Curves.easeOut.transform(_pulse.value);
                        return Transform.scale(
                          scale: 1 + t * 0.7,
                          child: Container(
                            width: size,
                            height: size,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.whatsapp.withValues(
                                alpha: 0.45 * (1 - t),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    AnimatedScale(
                      scale: _hovered ? 1.08 : 1,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.whatsapp,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.charcoal.withValues(alpha: 0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: FaIcon(
                          FontAwesomeIcons.whatsapp,
                          color: Colors.white,
                          size: size * 0.5,
                        ),
                      ),
                    ),
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
