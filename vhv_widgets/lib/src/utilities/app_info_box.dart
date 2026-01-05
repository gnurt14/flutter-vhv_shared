import 'package:flutter/material.dart';
import 'package:vhv_state/vhv_state.dart';

class AppInfoBox extends ConfigBox {
  const AppInfoBox({super.key, required super.builder});
}

class ConfigBox extends StatelessWidget {
  const ConfigBox({super.key, required this.builder});
  final Widget Function(Map params) builder;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ConfigBloc, ConfigState, Map?>(
      selector: (state) => state.data,
      builder: (context, Map? data){
        return builder(data ?? {});
      },
    );
  }
}
