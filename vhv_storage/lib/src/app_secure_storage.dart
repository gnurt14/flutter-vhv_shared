import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppSecureStorage{
  AppSecureStorage._();
  static AppSecureStorage? _instance;
  factory AppSecureStorage(){
    _instance ??= AppSecureStorage._();
    return _instance!;
  }
  IOSOptions _getIOSOptions([String? accountName]) => IOSOptions(
    accountName: accountName,
  );

  AndroidOptions _getAndroidOptions([String? accountName]) => AndroidOptions(
    encryptedSharedPreferences: true,
    sharedPreferencesName: accountName,
    // preferencesKeyPrefix: 'Test'
  );
  final _storage = const FlutterSecureStorage();

  Future<String?> get(String key, {String? accountName}){
    return _storage.read(
      key: key,
      aOptions: _getAndroidOptions(accountName),
      iOptions: _getIOSOptions(accountName),
    );
  }
  Future<void> put(String key, String? value, {String? accountName}){
    return _storage.write(
      key: key,
      value: value,
      aOptions: _getAndroidOptions(accountName),
      iOptions: _getIOSOptions(accountName),
    );
  }
  Future<Map<String, String>> getAll({String? accountName}) => _storage.readAll(
    aOptions: _getAndroidOptions(accountName),
    iOptions: _getIOSOptions(accountName),
  );

  Future<void> delete(String key,
      {String? accountName}) => _storage.delete(key: key,
    aOptions: _getAndroidOptions(accountName),
    iOptions: _getIOSOptions(accountName),
  );
  Future<void> deleteAll({String? accountName}) => _storage.deleteAll(
    aOptions: _getAndroidOptions(accountName),
    iOptions: _getIOSOptions(accountName),
  );
}