part of '../../form.dart';

enum FormCaptchaType { column, inlinePrefix, inLineSuffix, outLinePrefix }

class FormCaptcha extends FormWrapper<String> {
  final Function()? onTap;
  final Widget? prefixIcon;
  final VoidCallback? onEditingComplete;
  final bool reloadInInit;
  final int length;
  final Function(VoidCallback)? buildReloadCaptcha;
  final bool deleteInReload;
  final Widget Function(String value, ValueChanged onChanged)? inputBuilder;
  final FormCaptchaType type;
  const FormCaptcha(
      {super.key,
      super.onChanged,
      super.decoration,
      super.autofocus,
      super.labelText,
      super.hintText,
      super.errorText,
      super.focusNode,
      this.onTap,
      this.onEditingComplete,
      this.reloadInInit = false,
      this.prefixIcon,
      this.buildReloadCaptcha,
      super.value,
      this.deleteInReload = false,
      this.inputBuilder,
      this.length = 3,
      this.type = FormCaptchaType.column});

  bool get hasCustomCaptcha => (factories['customCaptcha'] != null &&
      factories['customCaptcha'] is FormCaptchaCustom);

  @override
  State<FormCaptcha> createState() => _FormCaptchaState();
}

class _FormCaptchaState extends State<FormCaptcha> {
  bool _loading = true;
  late Widget _image;
  String value = '';
  bool get isOneLine => isInLine || isOutLine;
  bool get isInLine =>
      widget.type == FormCaptchaType.inlinePrefix ||
      widget.type == FormCaptchaType.inLineSuffix;
  bool get isOutLine => widget.type == FormCaptchaType.outLinePrefix;
  bool get isPrefix => widget.type == FormCaptchaType.inlinePrefix;
  bool get isSuffix => widget.type == FormCaptchaType.inLineSuffix;
  double get widthImage {
    if (isOneLine && widget.length < 5) {
      return 110;
    }
    return 150;
  }

  double get heightImage {
    if (isInLine) return 45;
    if (isOutLine) return 48;
    return 50;
  }

  @override
  void initState() {
    if (!widget.hasCustomCaptcha) {
      value = widget.value ?? '';
      _image = SizedBox(
        width: widthImage,
        height: heightImage,
      );
      _loadCaptcha(true);
      if (widget.buildReloadCaptcha != null) {
        widget.buildReloadCaptcha!(_loadCaptcha);
      }
    }
    super.initState();
  }

  Future<void> _loadCaptcha([bool init = false]) async {
    _loading = true;

    if (mounted && widget.deleteInReload) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        value = '';
        if (widget.onChanged != null) widget.onChanged!(value);
        setState(() {});
      });
    }
    if (init && widget.reloadInInit) {
      await BasicAppConnect.post(
          VHVNetwork.getAPI('Common.Captcha.getCaptcha'), {
        'width': widthImage,
        'height': 50,
        'securityToken': AppCookieManager()
            .csrfToken(VHVNetwork.getAPI('Common.Captcha.getCaptcha')),
        'length': widget.length,
        'time': '${time()}',
        if (!empty(AppInfo.id)) 'site': AppInfo.id
      });
    }
    final res = await BasicAppConnect.post(
        VHVNetwork.getAPI('Common.Captcha.getCaptcha'), {
      'width': widthImage,
      'height': heightImage,
      'securityToken': AppCookieManager()
          .csrfToken(VHVNetwork.getAPI('Common.Captcha.getCaptcha')),
      'length': widget.length,
      'time': '${time()}',
      if (!empty(AppInfo.id)) 'site': AppInfo.id
    });
    if (res != null) {
      RegExp reExp = RegExp(r'data:image/[^;]+;base64,',
          caseSensitive: false, multiLine: false);
      final base64 = res.replaceAll(reExp, '');
      _image = Image.memory(
        base64Decode(base64),
        width: widthImage,
        height: heightImage,
      );
    }
    _loading = false;
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {});
      });
    }
  }

  void onChanged(dynamic value) {
    if (widget.onChanged != null) widget.onChanged!(value);
  }

  @override
  void didChangeDependencies() {
    if (!widget.hasCustomCaptcha) {
      value = widget.value ?? '';
    }
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(FormCaptcha oldWidget) {
    if (!widget.hasCustomCaptcha) {
      value = widget.value ?? '';
      // if (widget.errorText != null && oldWidget.errorText == null) {
      //   _loadCaptcha();
      // }
    }
    super.didUpdateWidget(oldWidget);
  }

  bool get hasFixError => !empty(factories['formGroupFixError']);
  Widget get imageCaptcha => Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Stack(
              children: [
                _image,
                Positioned(
                  top: 0,
                  right: 0,
                  left: 0,
                  bottom: 0,
                  child: Visibility(
                    visible: _loading,
                    child: Container(
                        color: Colors.black.withValues(alpha: 0.5),
                        width: double.infinity,
                        height: double.infinity,
                        child: const Center(
                            child: SizedBox(
                          width: 25,
                          height: 25,
                          child: CircularProgressIndicator.adaptive(
                            strokeWidth: 2,
                            backgroundColor: Colors.white,
                          ),
                        ))),
                  ),
                )
              ],
            ),
            SizedBox(
              width: heightImage,
              height: heightImage,
              child: IconButton(
                  style: IconButton.styleFrom(
                      foregroundColor: Colors.white,
                      fixedSize: Size(heightImage, heightImage),
                      padding: EdgeInsets.zero),
                  icon: const Icon(
                    Icons.autorenew,
                    size: 24,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    _loadCaptcha();
                  }),
            )
          ],
        ),
      );
  @override
  Widget build(BuildContext context) {
    if (widget.hasCustomCaptcha) {
      return (factories['customCaptcha'] as FormCaptchaCustom)(
        onTap: widget.onTap,
        onChanged: widget.onChanged,
        errorText: widget.errorText,
        focusNode: widget.focusNode,
        prefixIcon: widget.prefixIcon,
        onEditingComplete: widget.onEditingComplete,
        reloadInInit: widget.reloadInInit,
        autofocus: widget.autofocus,
        value: value,
        buildReloadCaptcha: widget.buildReloadCaptcha,
      );
    }
    final Widget child = Builder(builder: (_) {
      if (widget.inputBuilder != null) {
        return widget.inputBuilder!(value, onChanged);
      }
      if (hasFixError) {
        return Stack(
          children: [
            FormTextField(
              focusNode: widget.focusNode,
              value: value,
              autofocus: widget.autofocus,
              decoration: widget.inputDecoration(context).copyWith(
                labelText: (widget.inputDecoration(context).label == null)
                    ? widget.labelText ?? "Mã bảo mật".lang()
                    : null,
                errorStyle: Theme.of(context)
                    .inputDecorationTheme
                    .errorStyle
                    ?.copyWith(color: Colors.transparent),
              ),
              onFieldSubmitted: onChanged,
              onTap: widget.onTap,
              onChanged: onChanged,
              maxLength: widget.length,
              enabled: !_loading,
            ),
            if (!empty(widget.errorText))
              Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: Semantics(
                  container: true,
                  liveRegion: true,
                  child: Text(
                    widget.errorText ?? '',
                    style: Theme.of(context).inputDecorationTheme.errorStyle ??
                        TextStyle(
                            fontSize: 12,
                            color: ThemeData.light().colorScheme.error),
                    textAlign: TextAlign.left,
                    maxLines:
                        Theme.of(context).inputDecorationTheme.errorMaxLines,
                  ),
                ),
              ),
          ],
        );
      }
      return FormTextField(
        focusNode: widget.focusNode,
        value: value,
        autofocus: widget.autofocus,
        decoration: widget.inputDecoration(context).copyWith(
            labelText: (widget.inputDecoration(context).label == null)
                ? widget.labelText ?? "Mã bảo mật".lang()
                : null,
            suffixIcon: isInLine && isSuffix
                ? Padding(
                    padding: const EdgeInsets.all(4).copyWith(left: 10),
                    child: imageCaptcha,
                  )
                : null,
            prefixIcon: isInLine && isPrefix
                ? Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: imageCaptcha,
                  )
                : null
            ),
        onFieldSubmitted: onChanged,
        onTap: widget.onTap,
        onChanged: onChanged,
        maxLength: widget.length,
        enabled: !_loading,
      );
    });
    if (isInLine) {
      return child;
    }
    if (isOutLine) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          imageCaptcha,
          const SizedBox(
            width: 15,
          ),
          Flexible(child: child)
        ],
      );
    }
    final List<Widget> items = [
      imageCaptcha,
      const SizedBox(
        height: 15,
      ),
      child
    ];
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items);
  }
}
