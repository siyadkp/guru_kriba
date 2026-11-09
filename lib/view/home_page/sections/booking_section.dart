import 'package:flutter/material.dart';
import 'package:guru_kripa/view/widgets/cosmic/cosmic.dart';
import 'package:guru_kripa/utils/icons/brand_icons.dart';
import 'package:guru_kripa/model/site_content/site_content.dart';
import 'package:guru_kripa/utils/colors/app_colors.dart';
import 'package:guru_kripa/utils/launcher/contact_launcher.dart';
import 'package:guru_kripa/utils/responsive/responsive.dart';
import 'package:guru_kripa/utils/theme/app_text.dart';
import 'package:guru_kripa/view/widgets/app_button/app_button.dart';
import 'package:guru_kripa/view/widgets/reveal/reveal.dart';
import 'package:guru_kripa/view/widgets/section_header/section_header.dart';

class BookingSection extends StatelessWidget {
  const BookingSection({super.key, required this.selectedService});

  /// Set by "Book this service" buttons elsewhere on the page.
  final ValueNotifier<String?> selectedService;

  @override
  Widget build(BuildContext context) {
    final desktop = context.isDesktop;
    final steps = SiteContent.bookingSteps;

    final howTo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          eyebrow: 'Book a Consultation',
          title: 'How to Book a Consultation',
          subtitle:
              'Fill in the form and your booking request opens directly in '
              'WhatsApp — ready to send.',
          dark: true,
        ),
        const SizedBox(height: 36),
        for (var i = 0; i < steps.length; i++)
          Reveal(
            delay: Duration(milliseconds: 120 * i),
            offset: const Offset(-0.05, 0),
            child: _Step(number: i + 1, item: steps[i]),
          ),
        const SizedBox(height: 12),
        Reveal(
          delay: const Duration(milliseconds: 500),
          child: Wrap(
            spacing: 14,
            runSpacing: 12,
            children: [
              AppButton(
                label: 'Enquire on WhatsApp',
                icon: BrandIcons.whatsapp,
                variant: AppButtonVariant.whatsapp,
                compact: true,
                onPressed: ContactLauncher.openWhatsApp,
              ),
              AppButton(
                label: 'Call Now',
                icon: Icons.call_outlined,
                variant: AppButtonVariant.outlineLight,
                compact: true,
                onPressed: ContactLauncher.call,
              ),
            ],
          ),
        ),
      ],
    );

    final form = Reveal(
      delay: const Duration(milliseconds: 150),
      child: BookingForm(selectedService: selectedService),
    );

    return SectionShell(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.charcoal, AppColors.charcoalDeep],
        ),
      ),
      backdrop: Stack(
        children: [
          const Positioned.fill(child: Nebula(intensity: 0.7)),
          const Positioned.fill(child: Starfield(count: 70, seed: 17)),
          Positioned.fill(
            child: Watermark(
              right: -260,
              bottom: -260,
              child: CosmicWheel(size: 720, opacity: 0.16, animate: false),
            ),
          ),
        ],
      ),
      child: desktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: howTo),
                const SizedBox(width: 56),
                Expanded(flex: 6, child: form),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [howTo, const SizedBox(height: 48), form],
            ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.item});
  final int number;
  final InfoItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.white.withValues(alpha: 0.06),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Icon(item.icon, color: AppColors.warmAccent, size: 22),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STEP $number',
                  style: AppText.eyebrow(
                    color: Colors.white.withValues(alpha: 0.45),
                    size: 10.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.title,
                  style: AppText.heading(18, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  item.description,
                  style: AppText.body(
                    14.5,
                    color: Colors.white.withValues(alpha: 0.62),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Booking form. On submit it validates the details and opens WhatsApp
/// with a pre-filled booking message.
class BookingForm extends StatefulWidget {
  const BookingForm({super.key, required this.selectedService});
  final ValueNotifier<String?> selectedService;

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _note = TextEditingController();
  final _dateText = TextEditingController();
  final _timeText = TextEditingController();

  DateTime? _date;
  TimeOfDay? _time;
  String? _service;
  String _mode = SiteContent.consultationModes.first;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _service = widget.selectedService.value;
    widget.selectedService.addListener(_onServiceSelected);
  }

  void _onServiceSelected() {
    final value = widget.selectedService.value;
    if (value != null && SiteContent.bookingServiceTypes.contains(value)) {
      setState(() => _service = value);
    }
  }

  @override
  void dispose() {
    widget.selectedService.removeListener(_onServiceSelected);
    for (final c in [_name, _phone, _email, _note, _dateText, _timeText]) {
      c.dispose();
    }
    super.dispose();
  }

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _formatDate(DateTime d) =>
      '${_weekdays[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]} ${d.year}';

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Preferred consultation date',
    );
    if (picked != null) {
      setState(() {
        _date = picked;
        _dateText.text = _formatDate(picked);
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 10, minute: 0),
      helpText: 'Preferred consultation time',
    );
    if (picked != null && mounted) {
      setState(() {
        _time = picked;
        _timeText.text = picked.format(context);
      });
    }
  }

  String _buildMessage() {
    final lines = <String>[
      'Hello Guru Kripa Astro Science, I would like to book a consultation.',
      '',
      '*Name:* ${_name.text.trim()}',
      '*Phone / WhatsApp:* ${_phone.text.trim()}',
      if (_email.text.trim().isNotEmpty) '*Email:* ${_email.text.trim()}',
      '*Service:* $_service',
      '*Consultation format:* $_mode',
      if (_date != null) '*Preferred date:* ${_dateText.text}',
      if (_time != null) '*Preferred time:* ${_timeText.text}',
      if (_note.text.trim().isNotEmpty) ...[
        '',
        '*Question / Note:*',
        _note.text.trim(),
      ],
      '',
      'Thank you.',
    ];
    return lines.join('\n');
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _sending = true);
    final ok = await ContactLauncher.openWhatsApp(_buildMessage());
    if (!mounted) return;
    setState(() => _sending = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Opening WhatsApp… tap Send to share your booking request.'
              : 'Could not open WhatsApp. Please call us or try again.',
        ),
      ),
    );
  }

  // ------------------------------------------------------------ validators
  static String? _required(String? v, String field) =>
      (v == null || v.trim().isEmpty) ? 'Please enter your $field' : null;

  static String? _validatePhone(String? v) {
    final digits = (v ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return 'Please enter your phone / WhatsApp number';
    if (digits.length < 7 || digits.length > 15) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? _validateEmail(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return null; // optional
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
    return ok ? null : 'Please enter a valid email address';
  }

  @override
  Widget build(BuildContext context) {
    final twoCols = !context.isMobile;

    Widget pair(Widget a, Widget b) => twoCols
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: a),
              const SizedBox(width: 16),
              Expanded(child: b),
            ],
          )
        : Column(children: [a, const SizedBox(height: 16), b]);

    final name = TextFormField(
      controller: _name,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.name],
      decoration: const InputDecoration(
        labelText: 'Full name *',
        prefixIcon: Icon(Icons.person_outline),
      ),
      validator: (v) => _required(v, 'name'),
    );

    final phone = TextFormField(
      controller: _phone,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.telephoneNumber],
      decoration: const InputDecoration(
        labelText: 'Phone / WhatsApp *',
        prefixIcon: Icon(Icons.phone_outlined),
      ),
      validator: _validatePhone,
    );

    final email = TextFormField(
      controller: _email,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      decoration: const InputDecoration(
        labelText: 'Email (optional)',
        prefixIcon: Icon(Icons.mail_outline),
      ),
      validator: _validateEmail,
    );

    final service = DropdownButtonFormField<String>(
      // A new key rebuilds the field when "Book this service" preselects one.
      key: ValueKey(_service),
      initialValue: _service,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Service type *',
        prefixIcon: Icon(Icons.auto_awesome_outlined),
      ),
      borderRadius: BorderRadius.circular(14),
      dropdownColor: Colors.white,
      items: [
        for (final s in SiteContent.bookingServiceTypes)
          DropdownMenuItem(
            value: s,
            child: Text(s, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: (v) => setState(() => _service = v),
      validator: (v) => v == null ? 'Please choose a service' : null,
    );

    final date = TextFormField(
      controller: _dateText,
      readOnly: true,
      onTap: _pickDate,
      decoration: const InputDecoration(
        labelText: 'Preferred date',
        prefixIcon: Icon(Icons.event_outlined),
      ),
    );

    final time = TextFormField(
      controller: _timeText,
      readOnly: true,
      onTap: _pickTime,
      decoration: const InputDecoration(
        labelText: 'Preferred time',
        prefixIcon: Icon(Icons.schedule_outlined),
      ),
    );

    final note = TextFormField(
      controller: _note,
      minLines: 3,
      maxLines: 6,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(
        labelText: 'Brief question / note',
        hintText:
            'Share your question. For a reading, include your date, time and '
            'place of birth if you have them.',
        alignLabelWithHint: true,
      ),
    );

    return Container(
      padding: EdgeInsets.all(context.isMobile ? 22 : 38),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.warmAccent.withValues(alpha: 0.55),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 28,
            offset: const Offset(0, 30),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Book Your Consultation',
                      style: AppText.heading(context.isMobile ? 22 : 26),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.whatsapp.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      BrandIcons.whatsapp,
                      color: Color(0xFF128C4A),
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'We will reply on WhatsApp with available slots, fees and '
                'session requirements.',
                style: AppText.body(
                  14,
                  color: AppColors.mediumGray,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              pair(name, phone),
              const SizedBox(height: 16),
              pair(email, service),
              const SizedBox(height: 16),
              pair(date, time),
              const SizedBox(height: 20),
              Text(
                'Consultation format',
                style: AppText.body(
                  13,
                  color: AppColors.slate,
                  weight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final m in SiteContent.consultationModes)
                    ChoiceChip(
                      label: Text(m),
                      selected: _mode == m,
                      onSelected: (_) => setState(() => _mode = m),
                      showCheckmark: false,
                      labelStyle: AppText.body(
                        13,
                        color: _mode == m ? Colors.white : AppColors.slate,
                        weight: FontWeight.w500,
                        height: 1.2,
                      ),
                      selectedColor: AppColors.charcoal,
                      backgroundColor: AppColors.offWhite,
                      side: BorderSide(
                        color: _mode == m
                            ? AppColors.charcoal
                            : AppColors.hairline,
                      ),
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              note,
              const SizedBox(height: 26),
              AppButton(
                label: _sending
                    ? 'Opening WhatsApp…'
                    : 'Send Booking Request on WhatsApp',
                icon: BrandIcons.whatsapp,
                variant: AppButtonVariant.dark,
                expand: true,
                onPressed: _sending ? null : _submit,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 15,
                    color: AppColors.mediumGray,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your details are kept strictly confidential and used '
                      'only to arrange your consultation.',
                      style: AppText.body(
                        12.5,
                        color: AppColors.mediumGray,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
