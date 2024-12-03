library wire_cache;

import "package:memcached/memcached.dart";

abstract class WireCacheStorageProvider {
  final Duration defaultTTL;

  WireCacheStorageProvider({this.defaultTTL = const Duration(days: 1)});

  Future<String?> $read(String key);

  Future<void> $write(String key, String value);

  Future<void> init();

  int get _stamp => getCachedSync(
      id: "WCStamp.$hashCode",
      duration: const Duration(minutes: 1),
      getter: () => DateTime.timestamp().millisecondsSinceEpoch ~/ 1000 ~/ 60);

  int _stampTTL(Duration? ttl) => _stamp + (ttl ?? defaultTTL).inMinutes;

  Future<void> put(String key, String value, {Duration? ttl}) =>
      $write(key, "${_stampTTL(ttl)}:$value");

  Future<int?> getTTL(String key) =>
      $read(key).then((v) => int.tryParse(v?.split(":").firstOrNull ?? ""));

  Future<bool> hasExpired(String key) =>
      getTTL(key).then((v) => v == null || v < _stamp);

  Future<String?> get(String key);

  Future<String> compute(String key, String Function() ifAbsent);

  Future<void> delete(String key);

  Future<void> clear();
}
