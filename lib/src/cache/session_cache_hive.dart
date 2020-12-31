import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:session_cache/src/cached_value.dart';
import 'package:session_cache/src/session_cache.dart';
import 'package:session_cache/src/uuid_cache.dart';

/// Implementation of [SessionCache] using [Hive]
///
/// See https://docs.hivedb.dev/#/
class SessionCacheHive implements SessionCache {
  static const cacheKey = "SESSION_CACHE_HIVE_KEY";

  final HiveInterface _hive;
  final UuidCache _uuidCache;

  const SessionCacheHive(this._hive, this._uuidCache);

  @override
  Future<Either<F, T>> fromCache<F, T>(
    String key, {
    @required Future<Either<F, T>> Function(String key) onMiss,
    @required Object Function(T obj) toJson,
    @required T Function(Object obj) fromJson,
  }) async {
    await _openBox();
    final cachedString = _hive.box<String>(cacheKey).get(key);

    if (cachedString == null) {
      return _cacheStore(key, onMiss, toJson);
    } else {
      try {
        final cachedValue = CachedValue<T>.fromJson(
          json.decode(cachedString) as Map<String, dynamic>,
          fromJson,
        );

        if (cachedValue.uuid != _uuidCache.uuid) {
          return _cacheStore(key, onMiss, toJson);
        } else {
          return right(cachedValue.value);
        }
      } catch (_) {
        return _cacheStore(key, onMiss, toJson);
      }
    }
  }

  @override
  Future<void> resetKey(String key) async {
    await _openBox();
    _hive.box<String>(cacheKey).delete(key);
    return unit;
  }

  @override
  Future<void> resetSession() async => _uuidCache.reset();

  Future<Either<F, T>> _cacheStore<F, T>(
    String key,
    Future<Either<F, T>> Function(String key) onMiss,
    Object Function(T obj) toJson,
  ) async =>
      (await onMiss(key)).bind(
        (cached) {
          _hive.box<String>(cacheKey).put(
                key,
                json.encode(
                  CachedValue(
                    uuid: _uuidCache.uuid,
                    value: cached,
                  ).toJson(toJson),
                ),
              );
          return right(cached);
        },
      );

  Future<void> _openBox() async => _hive.openBox<String>(cacheKey);
}
