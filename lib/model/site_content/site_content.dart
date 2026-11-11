import 'package:flutter/material.dart';

/// Sections of the single-page site, in the order they appear on the page.
enum SiteSection {
  home('Home'),
  about('About Us'),
  astrologer('Astrologer'),
  services('Services'),
  whyUs('Why Choose Us'),
  booking('Book a Consultation'),
  testimonials('Testimonials'),
  faq('FAQ'),
  contact('Contact Us');

  const SiteSection(this.label);
  final String label;
}

class InfoItem {
  const InfoItem({
    required this.title,
    required this.description,
    required this.icon,
    this.bookingLabel,
    this.note,
  });

  final String title;
  final String description;
  final IconData icon;

  /// Service-type value used in the booking form for "Book this service".
  final String? bookingLabel;

  /// Optional disclaimer shown under the description.
  final String? note;
}

class TopicItem {
  const TopicItem(this.text, this.icon);
  final String text;
  final IconData icon;
}

class FaqItem {
  const FaqItem(this.question, this.answer);
  final String question;
  final String answer;
}

class Testimonial {
  const Testimonial({required this.quote, required this.name, this.detail});

  final String quote;
  final String name;

  /// For example the city or the service received.
  final String? detail;
}

/// All text on the website, taken from the
/// "Guru Kripa Astro Science – Website Content" brief.
class SiteContent {
  static const String brandName = 'Guru Kripa Astro Science';

  // ---------------------------------------------------------------- HERO
  static const String heroEyebrow = 'GURU KRIPA ASTRO SCIENCE';
  static const String heroHeadlineStart =
      'Astrological Guidance & Spiritual Remedial Solutions for Greater ';
  static const String heroHeadlineAccent1 = 'Clarity';
  static const String heroHeadlineMiddle = ' and ';
  static const String heroHeadlineAccent2 = 'Inner Harmony';
  static const String heroBody =
      "Explore life's important questions through personalized astrological "
      'consultation, combining the analytical precision of KP Astrology with '
      'the traditional wisdom of Advanced Vedic Astrology. We also offer '
      'dedicated guidance in Medical Astrology, Numerology, Gemmology, Life '
      'Coaching, and specialized Spiritual Poojas for Negative Energy '
      'Extraction & Cleansing.';
  static const String heroSubText =
      'Whether you are looking for clarity in your career, relationships, '
      'family life, finances, or personal direction—or seeking spiritual '
      'relief from subtle energetic obstacles—every consultation and session '
      'is approached with deep care, attention, and respect.';

  static const List<TopicItem> heroHighlights = [
    TopicItem('Online sessions worldwide', Icons.public),
    TopicItem('In-person appointments', Icons.event_seat_outlined),
    TopicItem('Strictly confidential', Icons.lock_outline),
  ];

  // ------------------------------------------------------------- WELCOME
  static const String welcomeTitle = 'Welcome to Guru Kripa Astro Science';
  static const List<String> welcomeParagraphs = [
    "Every person's life journey is unique. At Guru Kripa Astro Science, our "
        'goal is to understand your questions and provide a thoughtful, '
        'analytical, and spiritually grounded consultation. We focus on '
        'listening to your concerns, analyzing chart data, and explaining '
        'practical observations in clear language.',
    'In addition to predictive consultations, we conduct traditional '
        'Spiritual Poojas and targeted negative energy extraction procedures '
        'to remove subtle blockages, clear atmospheric negativity, and restore '
        'balance to your life and household.',
    'Our consultations and spiritual services are accessible globally through '
        'online sessions and remote energetic guidance. Contact us to inquire '
        'about appointments and procedural details.',
  ];

  static const List<String> coreServices = [
    'KP Astrology',
    'Advanced Vedic Astrology',
    'Medical Astrology',
    'Spiritual Poojas & Energy Extraction',
    'Numerology',
    'Gemmology',
    'Life Coaching',
    'Prashna / Horary Consultation',
    'Birth-Time Rectification',
  ];

  static const List<String> areasWeHelp = [
    'Career and professional direction',
    'Business, commercial growth, and financial decisions',
    'Love, marriage, and relationship compatibility',
    'Family peace, domestic harmony, and environmental energy',
    'Removal of negative energy, aura cleansing, and spiritual remedies',
    'Education, learning, and major life decisions',
    'Personal growth, mental focus, and life direction',
  ];

  // ------------------------------------------------------------ ABOUT US
  static const String aboutTitle = 'About Guru Kripa Astro Science';
  static const List<String> aboutParagraphs = [
    'Guru Kripa Astro Science is a personalized astrology and spiritual '
        'consultation initiative dedicated to helping individuals resolve '
        'complex life questions through established analytical traditions and '
        'structured energetic remedies.',
    'Our practice brings together KP Astrology and Advanced Vedic Astrology, '
        'complemented by Medical Astrology, Numerology, Gemmology, and '
        'specialized Spiritual Poojas for negative energy removal. We believe a '
        "meaningful consultation begins with understanding the complete context "
        "of an individual's life. Each session provides a transparent "
        'explanation of the astrological indicators and practical solutions.',
    'We make consultations accessible, respectful, and transparent. Clients '
        'can arrange online appointments and receive step-by-step guidance on '
        'birth details or spiritual requirements prior to their session.',
  ];

  static const List<InfoItem> methodology = [
    InfoItem(
      title: 'Understand Context',
      description:
          "Listen carefully to the client's core questions and background "
          'context.',
      icon: Icons.hearing_outlined,
    ),
    InfoItem(
      title: 'Analytical Verification',
      description:
          'Examine precise birth charts, KP sub-lord placements, or '
          'situational planetary factors.',
      icon: Icons.query_stats,
    ),
    InfoItem(
      title: 'Cross-Disciplinary Review',
      description:
          'Synthesize predictive systems (KP, Vedic, Numerology) for accurate '
          'assessment.',
      icon: Icons.hub_outlined,
    ),
    InfoItem(
      title: 'Transparent Explanation',
      description:
          'Present clear, logical conclusions without jargon or exaggerated '
          'claims.',
      icon: Icons.forum_outlined,
    ),
    InfoItem(
      title: 'Holistic Remedial Guidance',
      description:
          'Recommend practical advice, gemstone guidance, or spiritual '
          'poojas/cleansing rituals where appropriate.',
      icon: Icons.spa_outlined,
    ),
  ];

  // ---------------------------------------------------------- ASTROLOGER
  static const String astrologerName = 'Vishnu\u00A0C.S';
  static const String astrologerRole = 'Astrologer & Spiritual Consultant';
  static const List<String> astrologerParagraphs = [
    'Vishnu\u00A0C.S is an astrologer and spiritual consultant whose practice '
        'combines analytical rigor with authentic traditional remedies. His '
        'core work spans KP Astrology, Advanced Vedic Astrology, KP-based '
        'Birth-Time Rectification, Medical Astrology, Numerology, Gemmology, '
        'Life Coaching, and traditional Spiritual Remedial Rituals.',
    'His consultation style prioritizes exhaustive chart verification and '
        'empirical analysis. In addition to personal predictive readings, '
        'Vishnu\u00A0C.S guides clients through spiritual remedies and poojas '
        'designed to clear negative planetary influences, extract heavy '
        'environmental energies, and foster spiritual alignment.',
    'Each consultation is approached individually, ensuring that methods, '
        'diagnostic details, and remedial recommendations fit the '
        "client's specific needs.",
  ];
  static const List<String> astrologerExpertise = [
    'KP Astrology',
    'Advanced Vedic Astrology',
    'KP Birth-Time Rectification',
    'Medical Astrology',
    'Numerology',
    'Gemmology',
    'Life Coaching',
    'Spiritual Remedial Rituals',
  ];

  // ------------------------------------------------------------ SERVICES
  static const List<InfoItem> services = [
    InfoItem(
      title: 'KP Astrology (Krishnamurti Paddhati)',
      description:
          'A structured, sub-lord-based system for precise timing and event '
          'analysis. Consultations analyze house groupings and star lords to '
          'answer specific life questions regarding career, marriage, finance, '
          'property, and business endeavors.',
      icon: Icons.track_changes,
      bookingLabel: 'KP Astrology Consultation',
    ),
    InfoItem(
      title: 'Advanced Vedic Astrology',
      description:
          'Examines the birth chart using classical Vedic principles, planetary '
          'placements, house aspects, dasha periods, and divisional charts. '
          'Provides comprehensive insights into core personality, life '
          'patterns, key cycles, and timing considerations.',
      icon: Icons.auto_awesome_outlined,
      bookingLabel: 'Advanced Vedic Astrology',
    ),
    InfoItem(
      title: 'Medical Astrology',
      description:
          'Explores traditional planetary associations connected with vitality '
          'and physical wellbeing. Offered as a belief-based supplementary '
          'insight alongside personal healthcare.',
      note:
          'Medical Astrology is not a clinical medical diagnosis or medical '
          'treatment replacement.',
      icon: Icons.health_and_safety_outlined,
      bookingLabel: 'Medical Astrology',
    ),
    InfoItem(
      title: 'Numerology',
      description:
          'Analyzes symbolic numerical patterns derived from date of birth and '
          'full names to evaluate personal tendencies, name vibrations, and '
          'favorable business branding options.',
      icon: Icons.pin_outlined,
      bookingLabel: 'Numerology',
    ),
    InfoItem(
      title: 'Gemmology & Gemstone Guidance',
      description:
          'Professional evaluation of gemstones and their energetic '
          'properties. Recommendations are made based on precise horoscope '
          'analysis and sub-lord strength to ensure proper alignment.',
      icon: Icons.diamond_outlined,
      bookingLabel: 'Gemmology & Gemstone Guidance',
    ),
    InfoItem(
      title: 'Life Coaching',
      description:
          'Focused conversations aimed at goal-setting, personal growth, '
          'overcoming mental blocks, and practical decision-making. Helps '
          'align personal goals with astrological insights for practical '
          'execution.',
      icon: Icons.self_improvement,
      bookingLabel: 'Life Coaching',
    ),
    InfoItem(
      title: 'Prashna / Horary Astrology',
      description:
          'A question-focused method that constructs a chart for the exact '
          'time a query is posed. Ideal for urgent or single questions when '
          'complete birth charts are unavailable.',
      icon: Icons.help_center_outlined,
      bookingLabel: 'Prashna / Horary Consultation',
    ),
    InfoItem(
      title: 'Birth-Time Rectification',
      description:
          'A rigorous KP-based process that cross-references precise '
          'historical life events with astrological sub-lord timing to rectify '
          'and confirm exact birth times.',
      icon: Icons.schedule,
      bookingLabel: 'Birth-Time Rectification',
    ),
  ];

  static const String poojaTitle =
      'Spiritual Poojas & Negative Energy Extraction';
  static const String poojaDescription =
      'Specialized spiritual services and traditional rituals designed to '
      'clear negative energies, remove subtle environmental or personal '
      'blockages, and promote peace and protection.';
  static const List<InfoItem> poojaServices = [
    InfoItem(
      title: 'Negative Energy Extraction & Cleansing',
      description:
          'Targeted ritual procedures to identify and neutralize stagnant, '
          'heavy, or harmful energies affecting personal well-being, home, or '
          'workplace environments.',
      icon: Icons.shield_outlined,
      bookingLabel: 'Negative Energy Extraction & Cleansing',
    ),
    InfoItem(
      title: 'Spiritual Poojas & Remedial Rituals',
      description:
          'Custom Vedic poojas and homams performed to address specific '
          'planetary afflictions, doshas, or obstacles in career, marriage, '
          'and health.',
      icon: Icons.local_fire_department_outlined,
      bookingLabel: 'Spiritual Pooja & Remedial Ritual',
    ),
    InfoItem(
      title: 'Aura & House Blessing Remedies',
      description:
          'Rituals and mantras focused on restoring peace, mental stability, '
          'positive aura vibration, and spiritual protection for families and '
          'individuals.',
      icon: Icons.home_outlined,
      bookingLabel: 'Aura & House Blessing',
    ),
  ];

  /// Options for the "Service Type" field of the booking form.
  static List<String> get bookingServiceTypes => [
    for (final s in services) s.bookingLabel!,
    for (final s in poojaServices) s.bookingLabel!,
    notSureService,
  ];
  static const String notSureService = 'Not sure – please guide me';

  static const List<String> consultationModes = [
    'Online (Video)',
    'Online (Audio)',
    'In-Person',
  ];

  // -------------------------------------------------------------- TOPICS
  static const List<TopicItem> consultationTopics = [
    TopicItem(
      'Career advancement, job transitions, and business decisions',
      Icons.work_outline,
    ),
    TopicItem(
      'Financial stability, investments, and wealth timing',
      Icons.account_balance_wallet_outlined,
    ),
    TopicItem(
      'Marriage, love, and relationship compatibility',
      Icons.favorite_border,
    ),
    TopicItem(
      'Family dynamics, child-related queries, and domestic peace',
      Icons.family_restroom,
    ),
    TopicItem(
      'Negative energy removal, evil eye / aura cleansing, and home protection',
      Icons.shield_moon_outlined,
    ),
    TopicItem(
      'Spiritual poojas for specific planetary doshas and obstacles',
      Icons.local_fire_department_outlined,
    ),
    TopicItem(
      'Education, higher studies, and skill focus',
      Icons.school_outlined,
    ),
    TopicItem(
      'Birth chart accuracy, Prashna queries, and general life guidance',
      Icons.explore_outlined,
    ),
  ];

  // ---------------------------------------------------------- WHY CHOOSE
  static const List<InfoItem> whyChoose = [
    InfoItem(
      title: 'Integrated Approach',
      description:
          'Combines predictive KP/Vedic astrology with practical spiritual '
          'poojas and energy cleansing.',
      icon: Icons.hub_outlined,
    ),
    InfoItem(
      title: 'Personalized Attention',
      description:
          "Every session and remedy is tailored specifically to the "
          "individual's chart and situation.",
      icon: Icons.person_search_outlined,
    ),
    InfoItem(
      title: 'Transparent Communication',
      description:
          'Observations and remedial steps are explained clearly without '
          'confusing terminology.',
      icon: Icons.chat_bubble_outline,
    ),
    InfoItem(
      title: 'Convenient Online Access',
      description:
          'Seamless remote consultations, spiritual guidance, and pooja '
          'arrangements.',
      icon: Icons.public,
    ),
    InfoItem(
      title: 'Utmost Discretion',
      description:
          'Strict confidentiality regarding all personal details, charts, and '
          'spiritual concerns.',
      icon: Icons.lock_outline,
    ),
  ];

  // ------------------------------------------------------------- BOOKING
  static const List<InfoItem> bookingSteps = [
    InfoItem(
      title: 'Reach Out',
      description:
          'Contact us via Phone or WhatsApp using the direct links on this '
          'website — or simply fill in the booking form.',
      icon: Icons.call_outlined,
    ),
    InfoItem(
      title: 'Select Service',
      description:
          'Briefly state whether you need an astrology consultation, '
          'birth-time rectification, or a spiritual pooja / energy cleansing '
          'service.',
      icon: Icons.checklist,
    ),
    InfoItem(
      title: 'Schedule & Confirm',
      description:
          'We will share available appointment slots, consultation fees, and '
          'session requirements.',
      icon: Icons.event_available_outlined,
    ),
    InfoItem(
      title: 'Prepare Details',
      description:
          'Keep your precise birth details (Date, Time, Place) or key '
          'questions ready for the session.',
      icon: Icons.edit_note,
    ),
  ];

  // -------------------------------------------------------- TESTIMONIALS
  static const String testimonialsIntro =
      'Read authentic experiences shared by clients who have received '
      'consultation and remedial services from Guru Kripa Astro Science.';

  /// Add genuine client feedback here, only with the client's permission
  /// to show their name. The section shows these cards automatically.
  static const List<Testimonial> testimonials = [];

  /// The Testimonials section (and its menu item) only appears once real
  /// client feedback has been added above.
  static bool get showTestimonials => testimonials.isNotEmpty;

  /// Sections shown on the page and in the menus.
  static List<SiteSection> get visibleSections => [
    for (final s in SiteSection.values)
      if (s != SiteSection.testimonials || showTestimonials) s,
  ];

  // ----------------------------------------------------------------- FAQ
  static const List<FaqItem> faqs = [
    FaqItem(
      'How can I book a consultation or spiritual service?',
      'Contact us via WhatsApp or Phone, or use the booking form on this page. '
          'Share your preferred service (Astrology reading, Birth-Time '
          'Rectification, or Spiritual Pooja), and we will guide you through '
          'availability and booking.',
    ),
    FaqItem(
      'Are online consultations available?',
      'Yes, consultations and preliminary spiritual guidance are available '
          'online via audio/video call.',
    ),
    FaqItem(
      'What are Spiritual Poojas and Negative Energy Extraction services?',
      'These are traditional remedial practices designed to neutralize '
          'negative aura influences, clear environmental heaviness in homes or '
          'workplaces, and mitigate planetary doshas through structured Vedic '
          'rituals.',
    ),
    FaqItem(
      'What details are needed for a reading or remedial ritual?',
      'Date of birth, exact time of birth, and place of birth are required. '
          'For energy cleansing or house blessings, location details and '
          'background context are helpful.',
    ),
    FaqItem(
      'What if I do not know my exact birth time?',
      'You can opt for KP Birth-Time Rectification or request a Prashna '
          '(Horary) consultation for single urgent queries.',
    ),
    FaqItem(
      'Does Medical Astrology or Energy Extraction replace clinical treatment?',
      'No. Medical Astrology and spiritual energy remedies offer belief-based '
          'energetic support and do not replace professional medical or '
          'psychiatric care.',
    ),
  ];

  // -------------------------------------------------------------- FOOTER
  static const String contactIntro =
      'Connect with Guru Kripa Astro Science for consultation inquiries, '
      'spiritual pooja bookings, and service details.';
  static const String footerDescription =
      'Astrological consultation and spiritual remedial guidance in KP '
      'Astrology, Advanced Vedic Astrology, Spiritual Poojas, Negative Energy '
      'Extraction, Medical Astrology, Numerology, Gemmology, and Life '
      'Coaching.';
  static const String privacyCommitment =
      'All client personal information, birth details, and consultation '
      'records are kept strictly confidential and used solely for providing '
      'requested services.';
  static const String healthDisclaimer =
      'Medical Astrology and spiritual energy remedies offer belief-based '
      'energetic support and do not replace professional medical or '
      'psychiatric care.';
}
