part of '../extension.dart';

extension VHVSharedMapExtension on Map<dynamic, dynamic> {
  Map<String, T> filterKeys<T extends Object>(List<String> keys) {
    return Map<String, T>.fromEntries(
      this.keys.where((key) => keys.contains(key.toString())).map(
            (key) => MapEntry<String, T>(key.toString(), this[key]),
      ),
    );
  }
  Map<String, T> removeKeys<T>(List<String> keys) {
    print('this.keys: ${this.keys}');
    print('this.keys: ${this.keys.where((key) => !keys.contains(key.toString()))}');
    return Map<String, T>.fromEntries(
      this.keys.where((key) => !keys.contains(key.toString())).map(
            (key) => MapEntry<String, T>(key.toString(), this[key]),
      ),
    );
  }
}