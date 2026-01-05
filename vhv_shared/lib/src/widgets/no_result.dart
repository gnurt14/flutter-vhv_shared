import 'package:flutter/material.dart';
import 'package:vhv_shared/vhv_shared.dart';
class NoResult extends StatelessWidget {
  final String? msg;
  final Widget? icon;

  const NoResult({super.key, this.msg, this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Center(
        child: FittedBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if(icon != null)icon!,
              if(icon == null)Image.asset('assets/images/no_result_state.png', package: 'vhv_shared', width: 120,),
              const SizedBox(height: 10),
              Text(msg ?? '${"Không tìm thấy kết quả".lang()}!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
