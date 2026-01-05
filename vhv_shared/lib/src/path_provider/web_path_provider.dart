import 'dart:io';

Future<Directory> getTemporaryDirectory() async {
  return Future.value(Directory('/'));
}
Future<Directory> getApplicationSupportDirectory() async {
  return Future.value(Directory('/'));
}
Future<Directory> getExternalStorageDirectory() async {
  return Future.value(Directory('/'));
}
Future<Directory> getApplicationDocumentsDirectory() async {
  return Future.value(Directory('/'));
}