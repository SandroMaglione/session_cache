import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:session_cache/session_cache.dart';

class UuidCacheMock extends Mock implements UuidCache {}

class HiveInterfaceMock extends Mock implements HiveInterface {}

class BoxMock<T> extends Mock implements Box<T> {}

class ExampleModel {
  final int id;

  const ExampleModel(this.id);

  static ExampleModel fromJson(Map<String, dynamic> json) =>
      ExampleModel(json['id'] as int);

  Map<String, dynamic> toJson() => <String, dynamic>{'id': id};
}

void main() {
  group('SessionCacheHive', () {
    const key = "key";
    const idFromJson = 10;
    const idOnMiss = 1;

    const exampleModelFromJson = const ExampleModel(idFromJson);
    const exampleModelOnMiss = const ExampleModel(idOnMiss);

    const uuid = "uuid";
    const exampleModelJson = '{"id":$idFromJson}';
    const cached = '{"uuid":"$uuid","value":$exampleModelJson}';
    const cachedExpired = '{"uuid":"","value":$exampleModelJson}';
    const cachedInvalid = "";

    HiveInterface hiveInterface;
    Box<String> box;
    UuidCache uuidCache;
    UuidCache uuidCacheMock;

    SessionCache sessionCache;
    SessionCache sessionCacheUuid;

    setUp(() {
      Hive.initFlutter();
      hiveInterface = HiveInterfaceMock();
      box = BoxMock();
      uuidCache = UuidCache();
      uuidCacheMock = UuidCacheMock();

      sessionCache = SessionCacheHive(hiveInterface, uuidCache);
      sessionCacheUuid = SessionCacheHive(hiveInterface, uuidCacheMock);
    });

    group('fromCache', () {
      test('should return onMiss when no value stored in local cache',
          () async {
        when(hiveInterface.box<String>(any)).thenReturn(box);
        when(box.get(any)).thenReturn(null);

        final result = await sessionCache.fromCache<String, ExampleModel>(
          key,
          fromJson: (o) => ExampleModel.fromJson(o as Map<String, dynamic>),
          toJson: (v) => v.toJson(),
          onMiss: (_) async => right(exampleModelOnMiss),
        );

        expect(result, right<String, ExampleModel>(exampleModelOnMiss));
      });

      test('should return onMiss when uuid is expired', () async {
        when(uuidCacheMock.uuid).thenReturn(uuid);
        when(hiveInterface.box<String>(any)).thenReturn(box);
        when(box.get(any)).thenReturn(cachedExpired);

        final result = await sessionCacheUuid.fromCache<String, ExampleModel>(
          key,
          fromJson: (o) => ExampleModel.fromJson(o as Map<String, dynamic>),
          toJson: (v) => v.toJson(),
          onMiss: (_) async => right(exampleModelOnMiss),
        );

        expect(result, right<String, ExampleModel>(exampleModelOnMiss));
      });

      test('should return onMiss when stored value is invalid', () async {
        when(uuidCacheMock.uuid).thenReturn(uuid);
        when(hiveInterface.box<String>(any)).thenReturn(box);
        when(box.get(any)).thenReturn(cachedInvalid);

        final result = await sessionCacheUuid.fromCache<String, ExampleModel>(
          key,
          fromJson: (o) => ExampleModel.fromJson(o as Map<String, dynamic>),
          toJson: (v) => v.toJson(),
          onMiss: (_) async => right(exampleModelOnMiss),
        );

        expect(result, right<String, ExampleModel>(exampleModelOnMiss));
      });

      test('should return onHit when uuid is valid', () async {
        when(uuidCacheMock.uuid).thenReturn(uuid);
        when(hiveInterface.box<String>(any)).thenReturn(box);
        when(box.get(any)).thenReturn(cached);

        final result = await sessionCacheUuid.fromCache<String, ExampleModel>(
          key,
          fromJson: (o) => ExampleModel.fromJson(o as Map<String, dynamic>),
          toJson: (v) => v.toJson(),
          onMiss: (_) async => right(exampleModelOnMiss),
        );

        expect(result, isA<Right>());
        expect(result.getOrElse(() => null).id, exampleModelFromJson.id);
      });

      test('should put the value toJson in the cache when onMiss', () async {
        when(hiveInterface.box<String>(any)).thenReturn(box);
        when(box.get(any)).thenReturn(null);

        await sessionCache.fromCache<String, ExampleModel>(
          key,
          fromJson: (o) => ExampleModel.fromJson(o as Map<String, dynamic>),
          toJson: (v) => v.toJson(),
          onMiss: (_) async => right(exampleModelOnMiss),
        );

        verify(
          box.put(
              key,
              json.encode(
                CachedValue<ExampleModel>(
                  uuid: uuidCache.uuid,
                  value: exampleModelOnMiss,
                ).toJson((o) => o.toJson()),
              )),
        ).called(1);
      });
    });

    group('resetKey', () {
      test('should clear the cache at the given key', () async {
        when(hiveInterface.box<String>(any)).thenReturn(box);

        await sessionCacheUuid.resetKey(key);

        verify(box.delete(key)).called(1);
      });
    });
  });
}
