import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:vhv_shared/vhv_shared.dart';
import 'sms_autofill_builder.dart';

class FormOTPField extends StatefulWidget {
  const FormOTPField({super.key, this.hasSendOTP = false,
    required this.builder,required this.controller, required this.onChanged,
    this.autoFocus = false, this.shape, this.borderWidth, this.borderRadius,
    this.hasError = false, this.focusNode, this.onCompleted, this.useBasic = false, this.otpLength,
  this.mainAxisAlignment, this.otpHeight, this.otpWidth, this.paddingOTP});
  final bool hasSendOTP;
  final Function(String? code) builder;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool autoFocus;
  final PinCodeFieldShape? shape;
  final double? borderWidth;
  final BorderRadius? borderRadius;
  final bool hasError;
  final FocusNode? focusNode;
  final ValueChanged<String>? onCompleted;
  final bool useBasic;
  final int? otpLength;
  final MainAxisAlignment? mainAxisAlignment;
  final double? otpWidth;
  final double? otpHeight;
  final EdgeInsets? paddingOTP;
  @override
  State<FormOTPField> createState() => _FormOTPFieldState();
}

class _FormOTPFieldState extends State<FormOTPField> {
  late ValueKey key;
  String otp = '';
  @override
  void initState() {
    key = ValueKey('FormOTPField-${time()}');
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    double width = widget.otpWidth?? 45;
    double height = widget.otpHeight?? 60;
    if(context.width < 400 && widget.otpWidth == null && widget.otpHeight==null){
      width = 35;
      height = 35;
    }
    Widget input = PinCodeTextField(
      length: widget.otpLength ??6,
      appContext: context,
      obscureText: false,
      cursorColor: Theme
          .of(context)
          .textTheme
          .bodyLarge
          ?.color,
      animationType: AnimationType.fade,
      controller: widget.controller,
      autoDisposeControllers: false,
      autoDismissKeyboard: true,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      keyboardType: TextInputType.number,
      textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500
      ),
      pinTheme: PinTheme(
        fieldOuterPadding: widget.paddingOTP,
        shape: widget.shape ?? PinCodeFieldShape.box,
        fieldHeight: height,
        fieldWidth: width,
        borderWidth: widget.borderWidth ?? 2,
        borderRadius: widget.borderRadius??BorderRadius.circular(5),
        disabledBorderWidth: 1,

        inactiveColor: widget.hasError ? Theme.of(context).colorScheme.error : darken(Theme.of(context).scaffoldBackgroundColor, 0.01),
        inactiveFillColor: Theme.of(context).cardColor,

        activeColor: darken(Theme.of(context).scaffoldBackgroundColor, 0.01),
        activeFillColor: darken(Theme.of(context).scaffoldBackgroundColor, 0.01),

        selectedColor: darken(Theme.of(context).scaffoldBackgroundColor, 0.01),
        selectedFillColor: Theme.of(context).cardColor,
        selectedBorderWidth: 1,
      ),
      animationDuration: const Duration(milliseconds: 300),
      enableActiveFill: true,
      onCompleted: widget.onCompleted,
      onChanged: widget.onChanged,
      autoFocus: widget.autoFocus,
    );
    return Center(
      child: Container(
        constraints: const BoxConstraints(
            maxWidth: 400
        ),
        height: widget.useBasic?null:height,
        child: ((Platform.isAndroid && widget.hasSendOTP)?SMSAutofillBuilder(
            key: key,
            builder: (code) {
              if(!empty(code) && code != otp){
                otp = code??'';
                Future.delayed(const Duration(milliseconds: 500),(){
                  safeRun((){setState(() {
                    key = ValueKey('FormOTPField-${time()}');
                  });});
                });
              }
              if(!empty(code) || !empty(otp)) {
                widget.builder(!empty(code)?code:otp);
              }
              return input;
            }
        ):input),
      ),
    );
  }
}
