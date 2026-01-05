import 'package:flutter/material.dart';
import 'package:vhv_storage/vhv_storage.dart';

class SettingBox extends StatelessWidget {
  const SettingBox({super.key, required this.builder, required this.name, this.tableName});
  final Widget Function(dynamic data) builder;
  final String name;
  final String? tableName;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BoxEvent>(
      stream: Setting(tableName??'Config').watch(name),
      builder: (BuildContext context, AsyncSnapshot<BoxEvent> snapshot) {
        if(snapshot.hasData) {
          return builder((snapshot.data?.value));
        }
        return builder(Setting(tableName??'Config').get(name));
      },
    );
  }
}
