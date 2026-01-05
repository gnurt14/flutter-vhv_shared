part of '../../form.dart';

class FormAvatar extends FormWrapper<String> {
  const FormAvatar({
    super.key,
    this.width = 60.0,
    super.onChanged,
    super.enabled,
    super.value,
    super.errorText,
    ///default 5Mb
    this.sizeLimit = 5242880,
  });
  final double width;
  ///bytes
  /// 5Mb = 5 * 1024 * 1024
  final int sizeLimit;

  List<String> get ext => const ['jpg','gif','png','jpeg','bmp', 'heic'];

  @override
  State<FormAvatar> createState() => _FormAvatarState();
}

class _FormAvatarState extends State<FormAvatar> {
  bool get isEnabled => widget.enabled && widget.onChanged != null;
  @override
  Widget build(BuildContext context) {
    return FormImage(
      onChanged: widget.onChanged,
      sizeLimit: widget.sizeLimit,

      layoutBuilder: (controller){
        return InputDecoratorBase(
          decoration: InputDecoration(
            border: InputBorder.none,
            disabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            helperText:  "(Chú ý: Hỗ trợ file {fileType}) Tối đa {maxSize}".lang(namedArgs: {
              'fileType': widget.ext.map((e) => '.$e').toList().join(', '),
              'maxSize': '${toRound(byte2Mb(widget.sizeLimit), 2)}MB'
            }),
            // VHVSharedStrings().file_support_notice((widget.ext.map((e){
            //   return '.$e';
            // }).toList().join(', ')), '${toRound(byte2Mb(widget.sizeLimit), 2)}MB'),
            errorText: widget.errorText
          ),
          enabled: widget.enabled,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Stack(
              children: [
                Padding(
                  padding: (isEnabled && !empty(controller.value))
                      ? const EdgeInsets.only(
                      right: 17,
                      top: 2
                  ) : EdgeInsets.zero,
                  child: InkWell(
                    onTap: (isEnabled || !empty(controller.value)) ? ()async{
                      if(!empty(controller.value)) {
                        openFile(controller.value);
                      }else{
                        controller.selectImage();
                      }
                    } : null,
                    radius: widget.width,
                    borderRadius: BorderRadius.circular(widget.width),
                    child: Container(
                      width: widget.width,
                      height: widget.width,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(widget.width),
                          border: Border.all(
                              color: widget.errorText != null ? AppColors.error : AppColors.gray[200]!
                          )
                      ),
                      child: !empty(controller.value) ?
                      ClipRRect(
                        borderRadius: BorderRadius.circular(widget.width),
                        child: ImageViewer(controller.value),
                      )
                          : Icon(ViIcons.user_plus,
                        color: widget.errorText != null ? AppColors.error : AppColors.primary,
                      ),
                    ),
                  ),
                ),
                if(isEnabled && !empty(controller.value))Positioned(
                  top: 0,
                  right: 0,
                  child: InkWell(
                    onTap: controller.selectImage,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.white,
                              width: 0.5
                          ),
                          color: AppColors.gray100
                      ),
                      padding: const EdgeInsets.all(9),
                      child: const FittedBox(
                        child: Icon(ViIcons.image_plus),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
