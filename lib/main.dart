import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/di/app_dependencies.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Reading a handful of small JSON files is fast; doing it before the first
  // frame means the home screen never flashes an empty list.
  final dependencies = await bootstrap();
  runApp(ResumeYarApp(dependencies: dependencies));
}
