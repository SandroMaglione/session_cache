import 'package:flutter_test/flutter_test.dart';
import 'package:session_cache/src/uuid_cache.dart';

void main() {
  group('UuidCache', () {
    test(
        'should return the same instance when instantiated multiple times (singleton)',
        () async {
      final uuidCache1 = UuidCache();
      final uuidCache2 = UuidCache();
      expect(uuidCache1, uuidCache2);
    });

    test('should return the same uuid when called multiple times (singleton)',
        () async {
      final uuidCache1 = UuidCache();
      final uuidCache2 = UuidCache();
      expect(uuidCache1.uuid, uuidCache2.uuid);
    });

    test('should return a different uuid after reset() has been called',
        () async {
      final uuidCache = UuidCache();
      final uuid1 = uuidCache.uuid;
      uuidCache.reset();
      final uuid2 = uuidCache.uuid;
      expect(uuid1 != uuid2, true);
    });
  });
}
