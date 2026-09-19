import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Single id generator so every model creates ids the same way.
String newId() => _uuid.v4();
