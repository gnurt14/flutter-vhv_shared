import 'package:flutter/material.dart';
import 'package:vhv_state/vhv_state.dart';

class AccountBox extends StatelessWidget {
  const AccountBox({super.key, required this.builder});
  final Widget Function(Map params) builder;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AccountBloc, AccountState, Map>(
      selector: (state) => state.data,
      builder: (context, Map data){
        return builder(data);
      },
    );
  }
}