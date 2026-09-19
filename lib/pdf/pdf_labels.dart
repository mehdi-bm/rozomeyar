import '../domain/models/enums.dart';
import 'pdf_text.dart';

/// Headings and labels printed *inside* the resume.
///
/// These deliberately do not come from `AppLocalizations`: the resume language
/// is chosen per resume and is independent of the app UI language, so a Persian
/// UI must still be able to produce a fully English document.
class PdfLabels {
  const PdfLabels({
    required this.summary,
    required this.experience,
    required this.education,
    required this.skills,
    required this.languages,
    required this.projects,
    required this.certifications,
    required this.links,
    required this.contact,
    required this.present,
    required this.dateOfBirth,
    required this.address,
    required this.maritalStatus,
    required this.single,
    required this.married,
    required this.technologies,
    required this.achievements,
    required this.listSeparator,
    required this.skillLevels,
    required this.languageLevels,
  });

  final String summary;
  final String experience;
  final String education;
  final String skills;
  final String languages;
  final String projects;
  final String certifications;
  final String links;
  final String contact;
  final String present;
  final String dateOfBirth;
  final String address;
  final String maritalStatus;
  final String single;
  final String married;
  final String technologies;
  final String achievements;

  /// Persian uses «،» between list items, English uses a comma.
  final String listSeparator;

  final Map<SkillLevel, String> skillLevels;
  final Map<LanguageLevel, String> languageLevels;

  /// Headings are drawn with the same font as user text, so they need the same
  /// treatment — several of them («مهارت‌ها», «زبان‌ها», «حرفه‌ای») contain a
  /// نیم‌فاصله. Sanitised copies are built once and cached.
  static final Map<ResumeLanguage, PdfLabels> _cache =
      <ResumeLanguage, PdfLabels>{};

  factory PdfLabels.of(ResumeLanguage language) {
    return _cache.putIfAbsent(language, () {
      final raw = switch (language) {
        ResumeLanguage.persian => _persian,
        ResumeLanguage.arabic => _arabic,
        ResumeLanguage.english => _english,
      };
      return raw._map(pdfSafe);
    });
  }

  PdfLabels _map(String Function(String value) transform) {
    return PdfLabels(
      summary: transform(summary),
      experience: transform(experience),
      education: transform(education),
      skills: transform(skills),
      languages: transform(languages),
      projects: transform(projects),
      certifications: transform(certifications),
      links: transform(links),
      contact: transform(contact),
      present: transform(present),
      dateOfBirth: transform(dateOfBirth),
      address: transform(address),
      maritalStatus: transform(maritalStatus),
      single: transform(single),
      married: transform(married),
      technologies: transform(technologies),
      achievements: transform(achievements),
      listSeparator: listSeparator,
      skillLevels: skillLevels.map(
        (key, value) => MapEntry(key, transform(value)),
      ),
      languageLevels: languageLevels.map(
        (key, value) => MapEntry(key, transform(value)),
      ),
    );
  }

  String maritalStatusLabel(MaritalStatus status) =>
      status == MaritalStatus.single ? single : married;

  static const PdfLabels _persian = PdfLabels(
    summary: 'درباره من',
    experience: 'سوابق کاری',
    education: 'تحصیلات',
    skills: 'مهارت‌ها',
    languages: 'زبان‌ها',
    projects: 'پروژه‌ها',
    certifications: 'دوره‌ها و گواهینامه‌ها',
    links: 'لینک‌ها',
    contact: 'اطلاعات تماس',
    present: 'تاکنون',
    dateOfBirth: 'تاریخ تولد',
    address: 'آدرس',
    maritalStatus: 'وضعیت تأهل',
    single: 'مجرد',
    married: 'متأهل',
    technologies: 'تکنولوژی‌ها',
    achievements: 'دستاوردها',
    listSeparator: '، ',
    skillLevels: <SkillLevel, String>{
      SkillLevel.beginner: 'مقدماتی',
      SkillLevel.intermediate: 'متوسط',
      SkillLevel.advanced: 'پیشرفته',
      SkillLevel.expert: 'حرفه‌ای',
    },
    languageLevels: <LanguageLevel, String>{
      LanguageLevel.basic: 'مقدماتی',
      LanguageLevel.intermediate: 'متوسط',
      LanguageLevel.professional: 'پیشرفته',
      LanguageLevel.fluent: 'مسلط',
      LanguageLevel.native: 'زبان مادری',
    },
  );

  static const PdfLabels _arabic = PdfLabels(
    summary: 'نبذة عني',
    experience: 'الخبرات العملية',
    education: 'المؤهلات العلمية',
    skills: 'المهارات',
    languages: 'اللغات',
    projects: 'المشاريع',
    certifications: 'الدورات والشهادات',
    links: 'الروابط',
    contact: 'معلومات الاتصال',
    present: 'حتى الآن',
    dateOfBirth: 'تاريخ الميلاد',
    address: 'العنوان',
    maritalStatus: 'الحالة الاجتماعية',
    single: 'أعزب',
    married: 'متزوج',
    technologies: 'التقنيات',
    achievements: 'الإنجازات',
    listSeparator: '، ',
    skillLevels: <SkillLevel, String>{
      SkillLevel.beginner: 'مبتدئ',
      SkillLevel.intermediate: 'متوسط',
      SkillLevel.advanced: 'متقدم',
      SkillLevel.expert: 'خبير',
    },
    languageLevels: <LanguageLevel, String>{
      LanguageLevel.basic: 'مبتدئ',
      LanguageLevel.intermediate: 'متوسط',
      LanguageLevel.professional: 'متقدم',
      LanguageLevel.fluent: 'طلاقة',
      LanguageLevel.native: 'اللغة الأم',
    },
  );

  static const PdfLabels _english = PdfLabels(
    summary: 'About me',
    experience: 'Work experience',
    education: 'Education',
    skills: 'Skills',
    languages: 'Languages',
    projects: 'Projects',
    certifications: 'Courses & certifications',
    links: 'Links',
    contact: 'Contact',
    present: 'Present',
    dateOfBirth: 'Date of birth',
    address: 'Address',
    maritalStatus: 'Marital status',
    single: 'Single',
    married: 'Married',
    technologies: 'Technologies',
    achievements: 'Achievements',
    listSeparator: ', ',
    skillLevels: <SkillLevel, String>{
      SkillLevel.beginner: 'Beginner',
      SkillLevel.intermediate: 'Intermediate',
      SkillLevel.advanced: 'Advanced',
      SkillLevel.expert: 'Expert',
    },
    languageLevels: <LanguageLevel, String>{
      LanguageLevel.basic: 'Basic',
      LanguageLevel.intermediate: 'Intermediate',
      LanguageLevel.professional: 'Professional',
      LanguageLevel.fluent: 'Fluent',
      LanguageLevel.native: 'Native',
    },
  );
}
