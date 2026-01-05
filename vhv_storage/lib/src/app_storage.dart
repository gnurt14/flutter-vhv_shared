import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/adapters.dart';
export 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';
import 'package:vhv_shared/vhv_shared.dart';

class AppStorage {
  final Directory? directory;
  AppStorage([this.directory]);
  Map<String, Box> boxes = {};

  Future<Box<T>> _openBoxWithCompact<T>(
  String boxName, {
    int compactThresholdBytes = 52428800,
  }) async {
    final box = await Hive.openBox<T>(boxName);

    try {
      final path = box.path;
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          final fileSize = await file.length();
          if (fileSize > compactThresholdBytes) {
            await box.compact();
          }
        }
      }
    } catch (e) {
      debugPrint('HiveHelper: compact failed: $e');
    }

    return box;
  }
  Future init(List<String> tableNames) async {
    await Hive.initFlutter();
    if (tableNames.isNotEmpty) {
      for (var i = 0; i < tableNames.length; i++) {
        boxes[tableNames[i]] = await _openBoxWithCompact(tableNames[i]);
      }
    }
  }

  Future<Box> open(String tableName) async {
    if(boxes.containsKey(tableName)){
      return boxes[tableName]!;
    }

    final box = await _openBoxWithCompact(tableName);
    await box.compact();
    boxes[tableName] = box;
    return box;
  }

  Box? getBox(String boxName) {
    if (boxes.containsKey(boxName)) {
      return boxes[boxName];
    }
    return null;
  }

  bool containsKey(String tableName, dynamic key) {
    return getBox(tableName)!.containsKey(key);
  }



  Future put(String tableName, String id, dynamic data) async {
    final box = getBox(tableName);
    if(box != null) {
      if (box.containsKey(id)) {
        await box.delete(id);
      }
      return await box.put(id, data);
    }
  }

  Future putAll(String tableName, Map entries) async {
    return await getBox(tableName)!.putAll(entries);
  }

  Future push(String tableName, dynamic data) async {
    return await getBox(tableName)!.add(data);
  }

  Future pushAll(String tableName, Iterable<dynamic> entries) async {
    return await getBox(tableName)!.addAll(entries);
  }

  dynamic getAt(String tableName, int index) {
    return getBox(tableName)?.getAt(index);
  }

  dynamic get(String tableName, dynamic key) {
    return getBox(tableName)?.get(key);
  }

  Future delete(String tableName, String id) async {
    return await getBox(tableName)?.delete(id);
  }

  Stream<BoxEvent>? watch(String tableName, String id){
    return getBox(tableName)?.watch(key: id);
  }

  Future deleteAtIndex(String tableName, int index) async {
    return await getBox(tableName)?.deleteAt(index);
  }

  Future<int?> clear(String tableName)async{
    return await getBox(tableName)?.clear();
  }
  Future<void> deleteFromDisk(String tableName)async{
    return await getBox(tableName)?.deleteFromDisk();
  }

  ValueListenable<Box> listenable(String tableName) {
    return getBox(tableName)!.listenable();
  }

  dynamic items(String tableName){
    return getBox(tableName)?.listenable().value;
  }

  List getValues(String tableName){
    return getBox(tableName)?.listenable().value.values.toList() ?? [];
  }

  List getKeys(String tableName){
    return getBox(tableName)?.listenable().value.keys.toList() ?? [];
  }

  bool isNotEmpty(String tableName) {
    if(getBox(tableName) != null) {
      return getBox(tableName)!.isNotEmpty;
    }
    return false;
  }

  bool isEmpty(String tableName) {
    if(getBox(tableName) != null) {
      return getBox(tableName)!.isEmpty;
    }
    return true;
  }

  bool isOpen(String tableName) {
    if(getBox(tableName) != null) {
      return getBox(tableName)!.isOpen;
    }
    return false;
  }

  Future<void> compact(String tableName)async{
    await getBox(tableName)?.compact();
  }
}

class Setting {
  String tableName;
  static late AppStorage appStorage;
  Setting([this.tableName = 'Config']);
  static Future init(List<String> tableNames){
    return appStorage.init(tableNames);
  }
  static Future<Box> open(String tableName){
    return appStorage.open(tableName);
  }

  bool containsKey(String key) {
    return appStorage.containsKey(tableName, key);
  }

  Future put(String key, dynamic value) async {
    return appStorage.put(tableName, key, value);
  }

  Future putAll(Map entries) async {
    return appStorage.putAll(tableName, entries);
  }

  Future push(dynamic data) async {
    return appStorage.push(tableName, data);
  }

  Future pushAll(Iterable<dynamic> entries) async {
    return appStorage.pushAll(tableName, entries);
  }

  dynamic getAt(int index) {
    return appStorage.getAt(tableName, index);
  }
  Map<String, T> items<T>(){
    return checkType<Map<String, T>>(appStorage.items(tableName)) ?? <String, T>{};
  }
  List getKeys() {
    return appStorage.getKeys(tableName);
  }

  List getValues() {
    return appStorage.getValues(tableName);
  }

  T? get<T>(String key) {
    final value = appStorage.get(tableName, key);
    return value is T ? value : null;
  }

  Future delete(String key) async {
    return appStorage.delete(tableName, key);
  }

  Future deleteAtIndex(int index) async {
    return appStorage.deleteAtIndex(tableName, index);
  }

  Stream<BoxEvent>? watch(String id){
    return appStorage.watch(tableName, id);
  }

  Future<int?> clear(){
    return appStorage.clear(tableName);
  }

  Future<void> deleteFromDisk(){
    return appStorage.deleteFromDisk(tableName);
  }

  dynamic operator [](String key) {
    return appStorage.get(tableName, key);
  }

  ValueListenable<Box> listenable() {
    return appStorage.listenable(tableName);
  }

  bool get isNotEmpty => appStorage.isNotEmpty(tableName);
  bool get isEmpty => appStorage.isEmpty(tableName);
  bool get isOpen => appStorage.isOpen(tableName);

  Future<void> printTotalSizeOnDisk() async {
    var dir = await getApplicationDocumentsDirectory();
    if (!await dir.exists()) return;
    await for (var file in dir.list(recursive: true)) {
      if (file is File && file.path.endsWith('.hive')) {
        final length = await file.length();
        debugPrint('${file.path.substring(file.path.lastIndexOf('/') + 1)}: ${(length / 1024) / 1024} MB');
      }
    }
  }

  Future<void> compact(){
    return appStorage.compact(tableName);
  }
}
