import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

/// Interface to extend for custom [SessionCache] implementations
abstract class SessionCache {
  const SessionCache();

  /// Get value of [T] from cache associated with given [key].
  /// 
  /// If the value is found and valid for the current session in the cache,
  /// then return it (fast).
  /// 
  /// Otherwise, if the value is missing or invalid for the current
  /// session, call [onMiss] to make a remote request for [T] (slow).
  /// When the value has been fetched, store it in the cache using the
  /// given [key] and current session id (see [UuidCache]).
  /// 
  /// Returns [Either] the value of [T] if the request is successful, or 
  /// a value of type [F] when the request failed.
  /// 
  /// [toJson] and [fromJson] required to convert custom object to [String]
  /// to store it in cache.
  Future<Either<F, T>> fromCache<F, T>(
    String key, {
    @required Future<Either<F, T>> Function(String key) onMiss,
    @required Object Function(T obj) toJson,
    @required T Function(Object obj) fromJson,
  });

  /// Reset cache for given [key]
  Future<void> resetKey(String key);

  /// Reset current session and invalid all cache
  Future<void> resetSession();
}
