import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vhv_shared/vhv_shared.dart';

class NoRouter extends StatelessWidget {
  const NoRouter(this.state, {super.key});
  final GoRouterState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        context: context,
        title: const Text('404'),
      ),
      body: Center(
          child: Text('No route defined for ${state.uri.path}')),
    );
  }
}
