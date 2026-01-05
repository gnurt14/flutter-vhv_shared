import 'dart:typed_data';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:meta/meta.dart';
import 'package:vhv_storage/vhv_storage.dart';


/// Persist [Cookies] in the host file storage.
class WebCookieStorage implements Storage {
  WebCookieStorage() : shouldCreateDirectory = true;

  @visibleForTesting
  WebCookieStorage.test({this.shouldCreateDirectory = false});

  /// to obtain available directories.


  @visibleForTesting
  final bool shouldCreateDirectory;


  String? Function(Uint8List list)? readPreHandler;
  List<int> Function(String value)? writePreHandler;

  @override
  Future<void> init(bool persistSession, bool ignoreExpires) async {
    await _makeCookieDir();
  }

  @override
  Future<void> delete(String key) async {
    await AppSecureStorage().delete(key, accountName: 'webCookies');
  }

  // TODO(EVERYONE): Remove keys since it's useless in the next major version.
  @override
  Future<void> deleteAll(List<String> keys) async {
    await AppSecureStorage().deleteAll(accountName: 'webCookies');
  }

  @override
  Future<String?> read(String key) async {
    return await AppSecureStorage().get(key, accountName: 'webCookies');
  }

  @override
  Future<void> write(String key, String value) async {
    await AppSecureStorage().put(key, value, accountName: 'webCookies');
  }

  Future<void> _makeCookieDir() async {

  }
}
