import '../../core/theme/app_colors.dart';
import '../../core/utils/ids.dart';
import '../models/certification.dart';
import '../models/education.dart';
import '../models/enums.dart';
import '../models/experience.dart';
import '../models/personal_info.dart';
import '../models/project.dart';
import '../models/resume.dart';
import '../models/resume_language_item.dart';
import '../models/resume_link.dart';
import '../models/skill.dart';
import '../models/template_settings.dart';

/// Builds the «نمونه رزومه» seeded on first launch.
///
/// It is flagged `isSample` so the home screen can badge it, and it is created
/// exactly once — deleting it is permanent, and it never mixes with or
/// overwrites the user's own resumes.
abstract final class SampleResume {
  static Resume build({required ResumeLanguage language}) {
    return language == ResumeLanguage.english ? _english() : _persian();
  }

  static Resume _persian() {
    final now = DateTime.now();
    return Resume(
      id: newId(),
      title: 'نمونه رزومه',
      language: ResumeLanguage.persian,
      isSample: true,
      createdAt: now,
      updatedAt: now,
      personalInfo: const PersonalInfo(
        firstName: 'مهدی',
        lastName: 'محمدی',
        jobTitle: 'توسعه‌دهنده ارشد نرم‌افزار',
        mobile: '۰۹۱۲۳۴۵۶۷۸۹',
        email: 'mehdi.mohammadi@example.com',
        city: 'تهران',
        country: 'ایران',
      ),
      professionalSummary:
          'توسعه‌دهنده نرم‌افزار با بیش از ۸ سال تجربه در طراحی و پیاده‌سازی '
          'اپلیکیشن‌های موبایل و سامانه‌های تحت وب. علاقه‌مند به معماری تمیز، '
          'کیفیت کد و تجربه کاربری روان. تجربه رهبری تیم‌های چندنفره و تحویل '
          'موفق پروژه‌های سازمانی.',
      experiences: <Experience>[
        Experience(
          id: newId(),
          jobTitle: 'توسعه‌دهنده ارشد نرم‌افزار',
          company: 'شرکت نمونه',
          city: 'تهران',
          startDate: DateTime(2021, 7),
          isCurrent: true,
          description:
              'طراحی و توسعه اپلیکیشن‌های موبایل با Flutter و سرویس‌های '
              'بک‌اند با ASP.NET Core.',
          achievements:
              'کاهش ۴۰ درصدی زمان بارگذاری اپلیکیشن\n'
              'راه‌اندازی فرایند انتشار خودکار (CI/CD)\n'
              'آموزش و راهبری سه توسعه‌دهنده تازه‌وارد',
        ),
        Experience(
          id: newId(),
          jobTitle: 'برنامه‌نویس موبایل',
          company: 'استودیو آریا',
          city: 'تهران',
          startDate: DateTime(2018, 4),
          endDate: DateTime(2021, 6),
          description:
              'پیاده‌سازی بیش از ۱۰ اپلیکیشن فروشگاهی و خدماتی برای مشتریان داخلی.',
        ),
      ],
      educations: <Education>[
        Education(
          id: newId(),
          degree: 'کارشناسی ارشد',
          fieldOfStudy: 'مهندسی نرم‌افزار',
          institution: 'دانشگاه تهران',
          city: 'تهران',
          startDate: DateTime(2015, 9),
          endDate: DateTime(2018, 2),
        ),
        Education(
          id: newId(),
          degree: 'کارشناسی',
          fieldOfStudy: 'مهندسی کامپیوتر',
          institution: 'دانشگاه صنعتی امیرکبیر',
          city: 'تهران',
          startDate: DateTime(2011, 9),
          endDate: DateTime(2015, 6),
        ),
      ],
      skills: <Skill>[
        Skill(id: newId(), name: 'Flutter', level: SkillLevel.expert),
        Skill(id: newId(), name: 'Dart', level: SkillLevel.expert),
        Skill(id: newId(), name: 'ASP.NET Core', level: SkillLevel.advanced),
        Skill(id: newId(), name: 'SQL Server', level: SkillLevel.advanced),
        Skill(id: newId(), name: 'Git', level: SkillLevel.advanced),
        Skill(id: newId(), name: 'UI Design', level: SkillLevel.intermediate),
      ],
      languages: <ResumeLanguageItem>[
        ResumeLanguageItem(
          id: newId(),
          name: 'فارسی',
          level: LanguageLevel.native,
        ),
        ResumeLanguageItem(
          id: newId(),
          name: 'انگلیسی',
          level: LanguageLevel.professional,
        ),
      ],
      projects: <Project>[
        Project(
          id: newId(),
          name: 'سامانه مدیریت فروشگاه',
          role: 'توسعه‌دهنده اصلی',
          description:
              'سامانه یکپارچه مدیریت موجودی، فروش و گزارش‌گیری برای فروشگاه‌های زنجیره‌ای.',
          technologies: 'Flutter، ASP.NET Core، SQL Server',
        ),
        Project(
          id: newId(),
          name: 'اپلیکیشن رزرو نوبت',
          role: 'توسعه‌دهنده موبایل',
          description:
              'اپلیکیشن رزرو آنلاین نوبت برای مراکز درمانی با پشتیبانی از اعلان‌ها.',
          technologies: 'Flutter، Firebase',
        ),
      ],
      certifications: <Certification>[
        Certification(
          id: newId(),
          name: 'دوره پیشرفته معماری نرم‌افزار',
          organization: 'آکادمی نمونه',
          issueDate: DateTime(2022, 5),
        ),
      ],
      links: <ResumeLink>[
        ResumeLink(
          id: newId(),
          type: LinkType.linkedin,
          title: 'لینکدین',
          url: 'https://linkedin.com/in/example',
        ),
        ResumeLink(
          id: newId(),
          type: LinkType.github,
          title: 'گیت‌هاب',
          url: 'https://github.com/example',
        ),
      ],
      templateSettings: TemplateSettings(
        templateId: TemplateId.modern,
        accentColorValue: ResumeAccents.navy.value,
      ),
    );
  }

  static Resume _english() {
    final now = DateTime.now();
    return Resume(
      id: newId(),
      title: 'Sample resume',
      language: ResumeLanguage.english,
      isSample: true,
      createdAt: now,
      updatedAt: now,
      personalInfo: const PersonalInfo(
        firstName: 'Mehdi',
        lastName: 'Mohammadi',
        jobTitle: 'Senior Software Developer',
        mobile: '+98 912 345 6789',
        email: 'mehdi.mohammadi@example.com',
        city: 'Tehran',
        country: 'Iran',
      ),
      professionalSummary:
          'Software developer with 8+ years of experience designing and '
          'shipping mobile apps and web platforms. Focused on clean '
          'architecture, code quality and smooth user experience.',
      experiences: <Experience>[
        Experience(
          id: newId(),
          jobTitle: 'Senior Software Developer',
          company: 'Example Co.',
          city: 'Tehran',
          startDate: DateTime(2021, 7),
          isCurrent: true,
          description:
              'Building cross-platform mobile apps with Flutter and backend '
              'services with ASP.NET Core.',
          achievements:
              'Cut app startup time by 40%\n'
              'Introduced an automated release pipeline\n'
              'Mentored three junior developers',
        ),
        Experience(
          id: newId(),
          jobTitle: 'Mobile Developer',
          company: 'Aria Studio',
          city: 'Tehran',
          startDate: DateTime(2018, 4),
          endDate: DateTime(2021, 6),
          description:
              'Delivered 10+ commerce and service applications for local clients.',
        ),
      ],
      educations: <Education>[
        Education(
          id: newId(),
          degree: "Master's degree",
          fieldOfStudy: 'Software Engineering',
          institution: 'University of Tehran',
          city: 'Tehran',
          startDate: DateTime(2015, 9),
          endDate: DateTime(2018, 2),
        ),
      ],
      skills: <Skill>[
        Skill(id: newId(), name: 'Flutter', level: SkillLevel.expert),
        Skill(id: newId(), name: 'Dart', level: SkillLevel.expert),
        Skill(id: newId(), name: 'ASP.NET Core', level: SkillLevel.advanced),
        Skill(id: newId(), name: 'SQL Server', level: SkillLevel.advanced),
      ],
      languages: <ResumeLanguageItem>[
        ResumeLanguageItem(
          id: newId(),
          name: 'Persian',
          level: LanguageLevel.native,
        ),
        ResumeLanguageItem(
          id: newId(),
          name: 'English',
          level: LanguageLevel.professional,
        ),
      ],
      projects: <Project>[
        Project(
          id: newId(),
          name: 'Retail Management Platform',
          role: 'Lead developer',
          description:
              'Inventory, sales and reporting platform for retail chains.',
          technologies: 'Flutter, ASP.NET Core, SQL Server',
        ),
      ],
      certifications: <Certification>[
        Certification(
          id: newId(),
          name: 'Advanced Software Architecture',
          organization: 'Example Academy',
          issueDate: DateTime(2022, 5),
        ),
      ],
      links: <ResumeLink>[
        ResumeLink(
          id: newId(),
          type: LinkType.linkedin,
          title: 'LinkedIn',
          url: 'https://linkedin.com/in/example',
        ),
      ],
      templateSettings: TemplateSettings(
        templateId: TemplateId.modern,
        accentColorValue: ResumeAccents.navy.value,
      ),
    );
  }
}
