part of '../../form.dart';

typedef CustomWidgetFunction = Widget Function(Widget child, Map attr);
class FormTextArea extends StatefulWidget {
  final String? value;
  final String? errorText;
  final String? labelText;
  final Widget? labelWidget;
  final String? description;
  final ValueChanged? onChanged;
  final ValueChanged? onDone;
  final bool enabled;
  final bool? showBottomToolbar;
  final BoxDecoration? decoration;
  final Function(String url)? onLinkTap;
  final Function(String url)? onImageTap;
  final double height;
  final String? customToolbar;
  final Map<String, CustomWidgetFunction>? customWidget;
  final EdgeInsets? padding;
  final Function(VoidCallback onTap)? formCreated;
  final int? maxLine;
  final int? minLine;
  final FocusNode? focusNode;
  final bool required;

  const FormTextArea({super.key, this.value, this.decoration, this.errorText, this.labelText, this.showBottomToolbar,
    this.description, this.onChanged, this.enabled=true, this.height=200,
    this.customToolbar, this.onDone, this.customWidget, this.onLinkTap,
    this.onImageTap,this.padding, this.labelWidget, this.formCreated, this.maxLine, this.minLine, this.focusNode, this.required = false});
  @override
  State<FormTextArea> createState() => _FormTextAreaState();
}

class _FormTextAreaState extends State<FormTextArea> {
  String result = '';
  Timer? _timer;
  bool _showEdit = false;
  double heightKeyboard = 0;
  bool isReady = false;
  void _handleFocusChange() {
    if (widget.focusNode?.hasFocus == true && mounted) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.linear,
      );
    }
  }
  @override
  void didUpdateWidget(covariant FormTextArea oldWidget) {
    if(oldWidget.value != widget.value && widget.value != result){
      result = widget.value??'';
    }
    if(widget.enabled == false && _showEdit == true){
      appNavigator.pop();
    }
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.removeListener(_handleFocusChange);
      widget.focusNode?.addListener(_handleFocusChange);
    }
    super.didUpdateWidget(oldWidget);
  }
  @override
  void initState() {
    if(!empty(widget.value))result = widget.value!;
    if(widget.formCreated != null){
      widget.formCreated!(_onEdit);
    }
    widget.focusNode?.addListener(_handleFocusChange);
    super.initState();
  }
  Future<void> _checkVal([String? val])async{
    if(val != null){
      if (val != result) {
        _convertVal(val);
        if (widget.onChanged != null)widget.onChanged!(result);
      }
    }
  }
  void _convertVal(String? val){
    if (!empty(val)) {
      result = val!.replaceAll('src="${AppInfo.mediaDomain}/upload', 'src="/upload');
    } else {
      result = '';
    }
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_handleFocusChange);
    _timer?.cancel();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            InputDecoratorBase(
              focusNode: widget.focusNode,
              enabled: widget.enabled,
              decoration: InputDecorationBase(
                errorText: widget.errorText,
                fillColor: widget.errorText != null ? context.theme.colorScheme.errorContainer : null,
                filled: widget.errorText != null,
                labelText: empty(result) ? null : widget.labelText,
                contentPadding: widget.padding,
                label: widget.labelWidget,
                required: widget.required
              ),
              isEmpty: empty(result),
              child: Container(
                constraints: BoxConstraints(
                    minHeight: widget.height
                ),
                child: !empty(result)?HtmlView('<div style="font-size: 16px;">$result</div>',
                    // onLinkTap: widget.onLinkTap,
                    // onImageTap: widget.onImageTap,
                    // customRender: (widget.customWidget != null)?widget.customWidget!.map<String, CustomRenderFix>((k, v){
                    //   return MapEntry(k, (RenderContext? context, Widget child, attr, element){
                    //     return v(child, attr);
                    //   });
                    // }):null
                ): null
              ),
            ),
            if(empty(result))Positioned(
              top: 0,
              right: 0,
              left: 0,
              bottom: 0,
              child: IgnorePointer(
                ignoring: true,
                child: FormTextField(
                  decoration: InputDecorationBase(
                    labelText: widget.labelText,
                    contentPadding: widget.padding,
                    isDense: true,
                    isCollapsed: false,
                    enabledBorder: InputBorder.none,
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    required: widget.required,
                    labelStyle: widget.errorText != null ? TextStyle(
                      color: Theme.of(context).colorScheme.error
                    ) : null
                  ),
                  minLines: 1,
                  maxLines: 4,
                  onChanged: (val){},
                ),
              ),
            ),
            if(widget.enabled)Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: InkWell(
                onTap: widget.enabled?_onEdit:null,
                child: const SizedBox(
                  height: double.infinity,
                  width: double.infinity,
                ),
              )
            ),
          ],
        ),
      ],
    );
  }

  void _onDone() {
    if(widget.onDone != null) {
      widget.onDone!(result);
    }
  }
  void _onEdit()async{
    FocusScope.of(context).requestFocus(FocusNode());
    _showEdit = true;
    showLoading();
    // if(empty(Get.context!.isTablet)){
    //   await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    //   await Future.delayed(Duration(seconds: 1));
    // }
    await appNavigator.showFullDialog(
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.labelText??'',
                style: TextStyle(
                fontSize: 17,
                color: Theme.of(context).appBarTheme.foregroundColor
            ),),
            automaticallyImplyLeading: false,
            // systemOverlayStyle: SystemUiOverlayStyle(
            //   statusBarBrightness: Brightness.light,
            //   statusBarIconBrightness: Brightness.light,
            //   statusBarColor: Colors.transparent,
            // ),
            actions: [
              // IconButton(
              //   onPressed: (){
              //     FocusScope.of(context).unfocus();
              //     appNavigator.pop();
              //   },
              //   icon: Text(lang('Xong'), style: TextStyle(
              //     fontSize: 17,
              //     ),
              //   ),
              // )
              Center(
                child: InkWell(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text('Xong'.lang(), style: TextStyle(
                      fontSize: 17,
                      color: Theme.of(context).appBarTheme.foregroundColor
                      ),
                    ),
                  ),
                  onTap: (){
                    FocusScope.of(context).unfocus();
                    appNavigator.pop();
                    FocusScope.of(context).unfocus();
                  },
                ),
              )
            ],
          ),
          body: Container(
            color: Theme.of(context).cardColor,
            child: HtmlEditor(
              hint: widget.description??'',
              value: result.replaceAll('src="/upload', 'src="${AppInfo.mediaDomain}/upload'),
              returnContent:(val){
                _checkVal(val);
              },
              onReady: (){
                disableLoading();
                isReady = true;
              },
            ),
          ),
        )
    );
    disableLoading();
    // if(empty(Get.context!.isTablet)) {
    //   await SystemChrome.setPreferredOrientations(appOrientations);
    // }
    _showEdit = false;
    _onDone();
  }
}
