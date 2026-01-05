part of '../extension.dart';
extension VHVSharedObjectExtension on Object{
  T? isType<T>([T? defaultValue]){
    if(this is T){
      return this as T;
    }
    return defaultValue;
  }
}