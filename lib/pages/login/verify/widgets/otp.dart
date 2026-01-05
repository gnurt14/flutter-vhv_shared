import 'package:flutter/material.dart';
import 'package:vhv_widgets/vhv_widgets.dart';


class LoginVerifyOTP extends StatefulWidget {
  const LoginVerifyOTP({super.key,
    this.onResend,
    required this.onChanged,
    this.errorText,
    this.value
  });
  final Function()? onResend;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final String? value;

  @override
  State<LoginVerifyOTP> createState() => _LoginVerifyOTPState();
}

class _LoginVerifyOTPState extends State<LoginVerifyOTP> {
  late TextEditingController otpController;
  @override
  void initState() {
    otpController = TextEditingController();
    super.initState();
  }
  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(paddingBase),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Mã xác thực'.lang(), textAlign: TextAlign.center, style: AppTextStyles.titleLarge?.setFontWeight(FontWeight.w600),),
              h20,
              FormOTPField(
                hasError: !empty(widget.errorText),
                onChanged: (val){
                  widget.onChanged(val);
                },
                builder: (code) {
                  if (!empty(code) && code != widget.value) {
                    widget.onChanged(code ?? '');
                    safeCallback((){
                      otpController.text = code ?? '';
                    });
                  }
                },
                controller: otpController,
              ),
              if(widget.onResend != null)TextButton(
                  onPressed: widget.onResend,
                  style: TextButton.styleFrom(
                      textStyle: const TextStyle(
                          fontSize: 16
                      )
                  ),
                  child:  Text('Nhận mã xác thực'.lang())
              ).marginOnly(
                  top: 5
              )
            ]
        ),
      ),
    );
  }
}
