part of '../../form.dart';

class FormVideoUpload extends StatefulWidget {
  final String? labelText;
  final String? errorText;
  final Widget? training;
  final bool enabled;
  final ValueChanged? onDone;
  final InputDecoration? decoration;

  const FormVideoUpload({super.key, this.labelText, this.errorText, this.training,
    this.enabled = true, this.decoration, this.onDone});
  @override
  State<FormVideoUpload> createState() => _FormVideoUploadState();
}

class _FormVideoUploadState extends State<FormVideoUpload> {
  final picker = ImagePicker();
  InputDecoration? _inputDecoration;
  String? _labelText;
  String? _errorText;
  ValueNotifier<double>? _process;
  @override
  void initState() {
    _errorText = widget.errorText;
    _labelText = widget.labelText ??  "Chọn video tải lên".lang();
    _process = ValueNotifier<double>(0.0);
    _inputDecoration = (widget.decoration ??
        InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          errorText: widget.errorText,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            borderSide: BorderSide(color: Colors.red, width: 1),
          ),
          errorStyle: const TextStyle(color: Colors.red),
        ));
    super.initState();

  }
  Future<void> _selectVideo()async{
    final video = await picker.pickVideo(source: ImageSource.gallery);
    setState(() {
      _labelText = video!.path.substring(video.path.lastIndexOf('/') + 1);
    });
  }
  @override
  Widget build(BuildContext context) {
    return _uploadFile();
  }
  Widget _uploadFile() {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        InkWell(
          onTap: () async {
            final res = await AppPermissions().requestVideo();
            if(res) {
              await _selectVideo();
            }
          },
          child: TextFormField(
            controller: TextEditingController()..text = _labelText??'',
            enabled: false,
            maxLines: 1,
            decoration: _inputDecoration!.copyWith(
                errorText: _errorText,
                suffixIcon: ValueListenableBuilder<double>(
                    valueListenable: _process!,
                    builder: (_, process, child) {
                      if (process > 0) {
                        if (process < 1) {
                          return SizedBox(
                              width: 50,
                              child: Center(
                                  child: Text('${(process * 100).ceil()}%')));
                        } else {
                          return const SizedBox();
                        }
                      }
                      return const IconButton(
                        onPressed: null,
                        icon: Icon(Icons.file_upload),
                      );
                    })),
          ),
        ),
        ValueListenableBuilder<double>(
            valueListenable: _process!,
            builder: (_, process, child) {
              if(process == 1) {
                return IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    _labelText = widget.labelText ?? 'Chọn file tải lên'.lang();
                  },
                );
              }
              return const SizedBox();
            })
      ],
    );
  }
}
