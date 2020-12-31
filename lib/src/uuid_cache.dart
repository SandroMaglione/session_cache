import 'package:uuid/uuid.dart';

/// Singleton containing unique uuid for [SessionCache]
class UuidCache {
  String _uuid;
  static final UuidCache _instance = UuidCache._internal();
  factory UuidCache() => _instance;

  UuidCache._internal() {
    reset();
  }

  /// Unique key for the current cache session
  String get uuid => _uuid;

  /// Reset current cache session
  void reset() => _uuid = Uuid().v1();
}
