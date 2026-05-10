import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final localEncryptionServiceProvider = Provider<LocalEncryptionService>((ref) {
  return const LocalEncryptionService();
});

class LocalEncryptionService {
  const LocalEncryptionService({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  static const _keyName = 'lexis_hive_encryption_key';

  final FlutterSecureStorage _storage;

  Future<bool> hasKey() async => (await _storage.read(key: _keyName)) != null;

  Future<void> ensureKey() async {
    if (await hasKey()) return;
    final random = Random.secure();
    final key = List<int>.generate(32, (_) => random.nextInt(256));
    await _storage.write(key: _keyName, value: base64UrlEncode(key));
  }
}
