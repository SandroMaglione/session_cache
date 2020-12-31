import 'package:meta/meta.dart';

/// Store value [T] and current session id
class CachedValue<T> {
  /// Id of current session
  final String uuid;

  final T value;

  const CachedValue({
    @required this.uuid,
    @required this.value,
  });

  factory CachedValue.fromJson(
    Map<String, dynamic> json,
    T Function(Object json) fromJsonT,
  ) =>
      CachedValue<T>(
        uuid: json['uuid'] as String,
        value: fromJsonT(json['value']),
      );

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      <String, dynamic>{
        'uuid': this.uuid,
        'value': toJsonT(this.value),
      };
}
