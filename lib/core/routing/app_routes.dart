abstract final class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String settings = '/settings';
  static const String about = '/settings/about';
  static const String privacy = '/settings/privacy';

  static const String resumeEditPattern = '/resume/:id/edit';
  static const String resumePreviewPattern = '/resume/:id/preview';

  static String resumeEdit(String id) => '/resume/$id/edit';

  static String resumePreview(String id) => '/resume/$id/preview';
}
