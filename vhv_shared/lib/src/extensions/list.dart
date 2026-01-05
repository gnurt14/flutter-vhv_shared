part of '../extension.dart';

extension VHVSharedListExtension<T> on List<T> {
  List<T> insertBetween(T insertItem) {
    if (length < 2) return List<T>.from(this);
    final result = <T>[];
    for (int i = 0; i < length; i++) {
      result.add(this[i]);
      if (i < length - 1) {
        result.add(insertItem);
      }
    }
    return result;
  }
  List<T> takeLast(int n) {
    if (n <= 0) return [];
    if (n >= length) return List<T>.from(this);
    return sublist(length - n);
  }
}