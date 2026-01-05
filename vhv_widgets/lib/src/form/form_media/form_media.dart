import 'package:flutter/material.dart';
import 'package:vhv_state/vhv_state.dart';
import 'package:vhv_widgets/form.dart';
import 'package:vhv_widgets/vhv_widgets.dart';
import 'blocs/bloc.dart';

enum FormMediaType { avatar, image, images, file, files, video, videos, multiPicker, multiPickers}

@immutable
class FormMedia extends StatefulWidget {
  ///Image count. If length > 1 => multi select image
  final int length;

  ///bytes
  /// 5Mb = 5 * 1024 * 1024
  final int sizeLimit;
  final PickType pickType;
  final bool hasBase64;
  final bool hasUpload;
  final Map<String, String> factoryKeys;
  final List<String> ext;
  final String? helperText;
  final Widget? helper;
  final FormMediaType type;
  final RequestType requestType;
  final bool enabled;
  final dynamic value;
  final String? errorText;
  final dynamic onChanged;
  final String? labelText;
  final bool required;
  final String? hintText;
  final String? fileKey;
  final FocusNode? focusNode;
  final bool hideDeleteButton;
  final bool isPrivate;

  final Widget Function(BuildContext context, VoidCallback? onAdd)? addButton;


  static Widget icon(BuildContext context, String fileName, {double size = 24}) {
    final ext = fileName.substring(fileName.lastIndexOf('.') + 1);
    if((ext == '' && fileName.isNotEmpty) || ext == 'folder'){
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: const Color(0xfff6af29)
        ),
        alignment: Alignment.center,
        child: Icon(ViIcons.folder_open, size: size, color: Colors.white,),
      );
    }
    switch (ext) {
      case 'doc':
      case 'docx':
        return SvgViewer('assets/file-icons/file-docx-fill.svg', package: 'vhv_shared', width: size);
      case 'ppt':
      case 'pptx':
        return SvgViewer('assets/file-icons/file-pptx-fill.svg', package: 'vhv_shared', width: size);
      case 'xls':
      case 'xlsx':
        return SvgViewer('assets/file-icons/file-xlsx-fill.svg', package: 'vhv_shared', width: size);
      case 'pdf':
        return SvgViewer('assets/file-icons/file-pdf-2-fill.svg', package: 'vhv_shared', width: size);
    //'jpg','gif','png','jpeg','bmp', 'heic'
      case 'jpg':
      case 'gif':
      case 'png':
      case 'jpeg':
      case 'bmp':
      case 'heic':
        return SvgViewer(
          'assets/file-icons/image-fill.svg',
          package: 'vhv_shared',
          width: size,
        );
      case 'mp4':
      case 'mov':
      case 'mkv':
      case 'avi':
      case 'webm':
      case 'flv':
      case 'ts':
      case 'hls':
        return SvgViewer(
          'assets/file-icons/file-mp4-fill.svg',
          package: 'vhv_shared',
          width: size,
        );
      case 'mp3':
      case 'aac':
      case 'ogg':
      case 'wma':
      case 'flac':
      case 'alac':
      case 'ape':
      case 'wav':
      case 'aiff':
      case 'pcm':
        return SvgViewer(
          'assets/file-icons/file-mp3-fill.svg',
          package: 'vhv_shared',
          width: size,
        );
      case 'zip':
      case '7z':
      case 'xz':
        return SvgViewer(
          'assets/file-icons/file-rar-fill.svg',
          package: 'vhv_shared',
          width: size,
        );
      case 'rar':
      case 'tar':
      case 'cab':
      case 'iso':
        return SvgViewer(
          'assets/file-icons/file-rar-fill.svg',
          package: 'vhv_shared',
          width: size,
        );
      case 'txt':
        return SvgViewer(
          'assets/file-icons/file-txt-fill.svg',
          package: 'vhv_shared',
          width: size,
        );
      case 'csv':
        return SvgViewer(
          'assets/file-icons/file-csv-fill.svg',
          package: 'vhv_shared',
          width: size,
        );
    }
    return SvgViewer(
      'assets/file-icons/file-empty-fill.svg',
      package: 'vhv_shared',
      width: size,
    );
  }

  const FormMedia.multiPicker({
    super.key,
    this.enabled = true,
    String? this.value,
    required Function(String? value) this.onChanged,
    this.errorText,
    this.focusNode,
    this.hideDeleteButton = false,
    this.isPrivate = false,

    ///default 50Mb
    this.sizeLimit = 52428800,
    this.hasBase64 = false,
    this.hasUpload = true,
    this.factoryKeys = const {},
    this.helper,
    this.helperText,
    this.hintText,
    this.labelText,
    this.required = false,
    this.ext = const [
      'jpg',
      'gif',
      'png',
      'jpeg',
      'bmp',
      'heic',
      'webp',
      'ico',
      'pdf',
      'doc',
      'docx',
      'xls',
      'xlsx',
      'ppt',
      'pptx',
      'zip',
      '7zip',
      'rar',
    ],
    this.addButton
  })  : type = FormMediaType.multiPicker,
        length = 1,
        fileKey = '',
        requestType = RequestType.common,
        pickType = PickType.storage
  ;

  const FormMedia.multiPickers({
    super.key,
    this.enabled = true,
    this.value,
    required Function(Map<String, Map>) this.onChanged,
    this.errorText,
    this.focusNode,
    this.hideDeleteButton = false,
    this.isPrivate = false,

    ///default 50Mb
    this.sizeLimit = 52428800,
    this.hasBase64 = false,
    this.hasUpload = true,
    this.factoryKeys = const {},
    this.helper,
    this.helperText,
    this.labelText,
    this.required = false,
    this.length = 10,
    this.addButton,
    this.ext = const [
      'jpg',
      'gif',
      'png',
      'jpeg',
      'bmp',
      'heic',
      'webp',
      'ico',
      'pdf',
      'doc',
      'docx',
      'xls',
      'xlsx',
      'ppt',
      'pptx',
      'zip',
      '7zip',
      'rar',
    ],
  })  : type = FormMediaType.multiPickers,

      hintText = null,
      fileKey = 'file',
      requestType = RequestType.common,
      pickType = PickType.storage
  ;



  const FormMedia.image({
    super.key,
    this.enabled = true,
    String? this.value,
    required Function(String? value) this.onChanged,
    this.errorText,
    this.focusNode,
    this.hideDeleteButton = false,
    this.isPrivate = false,

    ///default 5Mb
    this.sizeLimit = 5242880,
    this.pickType = PickType.storage,
    this.requestType = RequestType.image,
    this.hasBase64 = false,
    this.hasUpload = true,
    this.factoryKeys = const {},
    this.helper,
    this.helperText,
    this.labelText,
    this.required = false,
    this.ext = const ['jpg', 'gif', 'png', 'jpeg', 'bmp', 'heic'],
  })  : type = FormMediaType.image,
        length = 1,
        hintText = null,
        fileKey = '', addButton = null;

  const FormMedia.images({
    super.key,
    this.enabled = true,
    this.value,
    required Function(Map<String, Map>) this.onChanged,
    this.errorText,
    this.focusNode,
    this.isPrivate = false,

    ///default 5Mb
    this.sizeLimit = 5242880,
    this.pickType = PickType.storage,
    this.requestType = RequestType.image,
    this.factoryKeys = const {},
    this.helper,
    this.helperText,
    this.length = 10,
    this.labelText,
    this.required = false,
    this.fileKey = 'image',
    this.ext = const ['jpg', 'gif', 'png', 'jpeg', 'bmp', 'heic'],
  })  : type = FormMediaType.images,
        hintText = null, hasBase64 = false, hideDeleteButton = false,
        hasUpload = true, assert(length > 1), addButton = null;

  const FormMedia.file({
    super.key,
    this.enabled = true,
    String? this.value,
    required Function(String? value) this.onChanged,
    this.errorText,
    this.focusNode,
    this.hideDeleteButton = false,
    this.isPrivate = false,

    ///default 5Mb
    this.sizeLimit = 5242880,
    this.requestType = RequestType.common,
    this.factoryKeys = const {},
    this.helper,
    this.helperText,
    this.labelText,
    this.required = false,
    this.hintText,
    this.hasUpload = true,
    this.ext = const ['jpg', 'gif', 'png', 'jpeg', 'bmp', 'heic', 'rar', 'zip', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'pdf'],
  })  : type = FormMediaType.file,
        pickType = PickType.storage,
        length = 1,
        fileKey = '', hasBase64 = false, addButton = null;

  const FormMedia.files({
    super.key,
    this.enabled = true,
    this.value,
    required Function(Map<String, Map> value) this.onChanged,
    this.errorText,
    this.focusNode,
    this.isPrivate = false,

    ///default 5Mb
    this.sizeLimit = 5242880,
    this.requestType = RequestType.common,
    this.factoryKeys = const {},
    this.helper,
    this.helperText,
    this.labelText,
    this.required = false,
    this.hintText,
    this.length = 10,
    this.fileKey = 'file',
    this.ext = const ['jpg', 'gif', 'png', 'jpeg', 'bmp', 'heic',
      'rar', 'zip', '7z',
      'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx',
      'pdf'],
  })  : type = FormMediaType.files,
        pickType = PickType.storage, hideDeleteButton = false,
        hasBase64 = false,
        hasUpload = true, assert(length > 1), addButton = null;

  const FormMedia.video({
    super.key,
    this.enabled = true,
    String? this.value,
    required Function(String? value) this.onChanged,
    this.errorText,
    this.focusNode,
    this.hideDeleteButton = false,
    this.isPrivate = false,

    ///default 30Mb
    this.sizeLimit = 31457280,
    this.requestType = RequestType.common,
    this.factoryKeys = const {},
    this.helper,
    this.helperText,
    this.labelText,
    this.required = false,
    this.hintText,


    this.ext = const ['mp4', 'mov', 'mkv', 'avi', 'webm', 'flv'],
  })  : type = FormMediaType.video,
        pickType = PickType.storage,
        length = 1,
        fileKey = '',
        hasBase64 = false,
        hasUpload = true, addButton = null;

  const FormMedia.videos({
    super.key,
    this.enabled = true,
    String? this.value,
    required Function(String? value) this.onChanged,
    this.errorText,
    this.focusNode,
    this.isPrivate = false,

    ///default 30Mb
    this.sizeLimit = 20971520,
    this.requestType = RequestType.common,
    this.factoryKeys = const {},
    this.helper,
    this.helperText,
    this.labelText,
    this.required = false,
    this.hintText,
    this.length = 10,

    this.ext = const ['mp4', 'mov', 'mkv', 'avi', 'webm', 'flv'],
  })  : type = FormMediaType.videos,
        pickType = PickType.storage,
        hideDeleteButton = false,
        fileKey = '',
        hasBase64 = false,
        hasUpload = true, assert(length > 1), addButton = null;

  const FormMedia.avatar({
    super.key,
    this.enabled = true,
    String? this.value,
    required Function(String? value) this.onChanged,
    this.errorText,
    this.focusNode,
    this.hideDeleteButton = false,
    this.isPrivate = false,

    ///default 5Mb
    this.sizeLimit = 5242880,
    this.pickType = PickType.storage,
    this.hasUpload = true,
    this.factoryKeys = const {},
    this.helper,
    this.helperText,
    this.labelText,
    this.required = false,
  })  : type = FormMediaType.avatar,
        ext = const ['jpg', 'gif', 'png', 'jpeg', 'bmp', 'heic'],
        requestType = RequestType.image,
        hintText = null,
        length = 1,
        hasBase64 = false,
        fileKey = null, addButton = null;

  @override
  State<FormMedia> createState() => _FormMediaState();
}

class _FormMediaState extends State<FormMedia> {
  bool get isMulti => widget.type == FormMediaType.images || widget.type == FormMediaType.files
      || widget.type == FormMediaType.videos || widget.type == FormMediaType.multiPickers;
  FormMediaBloc? _bloc;
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
  void didUpdateWidget(covariant FormMedia oldWidget) {
    if (_bloc != null) {
      if (_bloc!.convertToValue(widget.value).isNotEmpty != _bloc!.state.items.isNotEmpty) {
        if(_bloc!.state.items.isNotEmpty
            && _bloc!.state.items.values.firstWhereOrNull((e) => e.link == null) != null){
          super.didUpdateWidget(oldWidget);
          return;
        }
        _bloc!.setInitialValue(widget.value);
      }
    }
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.removeListener(_handleFocusChange);
      widget.focusNode?.addListener(_handleFocusChange);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    widget.focusNode?.addListener(_handleFocusChange);
    super.initState();
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_handleFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FormMediaBloc(
        length: widget.length,
        pickType: widget.pickType,
        ext: widget.ext,
        hasBase64: widget.hasBase64,
        hasUpload: widget.hasUpload,
        sizeLimit: widget.sizeLimit,
        factoryKeys: widget.factoryKeys,
        requestType: widget.requestType,
        type: widget.type,
        value: widget.value,
        fileKey: widget.fileKey ?? 'file',
        onInit: (bloc) {
          _bloc = bloc;
        },
        onChanged: (val) {
          if (isMulti) {
            widget.onChanged(val is Map ? val : {});
          } else {
            widget.onChanged(val is String ? val : '');
          }
        }
      ),
      child: _FormMediaContent(
        enabled: widget.enabled,
        helperText: widget.helperText,
        errorText: widget.errorText,
        helper: widget.helper,
        ext: widget.ext,
        labelText: widget.labelText,
        hintText: widget.hintText,
        required: widget.required,
        focusNode: widget.focusNode,
        hideDeleteButton: widget.hideDeleteButton,
        addButton: widget.addButton,
        isPrivate: widget.isPrivate,
      )
    );
  }
}

class _FormMediaContent extends StatelessWidget {
  const _FormMediaContent({
    this.enabled = true,
    this.errorText,

    ///default 5Mb
    this.helper,
    this.helperText,
    this.ext = const ['jpg', 'gif', 'png', 'jpeg', 'bmp', 'heic'],
    this.labelText,
    this.hintText,
    this.required = false,
    this.focusNode,
    this.hideDeleteButton = false,
    this.addButton,
    this.isPrivate = false
  });
  final bool enabled;
  final List<String> ext;
  final String? helperText;
  final Widget? helper;
  final String? errorText;
  final String? labelText;
  final String? hintText;
  final bool required;
  final FocusNode? focusNode;
  final bool hideDeleteButton;
  final bool isPrivate;
  final Widget Function(BuildContext context, VoidCallback? onAdd)? addButton;
  String? helperTextBase(BuildContext context) {
    if (helperText == null) {
      final bloc = context.read<FormMediaBloc>();
      return 'Hỗ trợ file {}.${bloc.sizeLimit > 0 ? ' Tối đa {}MB' : ''}'
          .lang(args: [(ext.map((e) => e).join(', ')), '${byte2Mb(bloc.sizeLimit).round()}']);
    }
    return helperText;
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<FormMediaBloc>();
    return BlocBuilder<FormMediaBloc, FormMediaState>(buildWhen: (prev, current) {
      return prev.toString() != current.toString();
    }, builder: (context, state) {
      final errorText = state.isUploading ? null : this.errorText;
      return FormGroup(labelText ?? '',
          errorText: errorText,
          helperText: helperText == '' ? null : (helperText ?? helperTextBase(context)),
          required: required,
          child:  SizedBox(
            width: double.infinity,
            child: Builder(
              builder: (_) {
                switch (bloc.type) {
                  case FormMediaType.multiPicker:
                  case FormMediaType.multiPickers:
                  bool hasImage = false;
                  bool hasFile = false;
                  for(var v in state.items.values){
                    if((v.link ?? v.path ?? '').isImageFileName){
                      hasImage = true;
                    }else{
                      hasFile = true;
                    }
                    if(hasFile && hasImage){
                      break;
                    }
                  }
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if(hasFile)files(context, state,
                        hideImage: true,
                        hideAddNew: true
                      ),
                      if(hasImage && hasFile)columnSpacing,
                      if(hasImage)image(context, state,
                        hideFile: true,
                        hideAddNew: true
                      ),
                      if(showButtonAdd(bloc) && addButton != null)addButton!(context, enabled
                          ? () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        bloc.selectFiles(context: context);
                      } : null),
                      if(showButtonAdd(bloc) && addButton == null)...[
                        if(state.items.values.isNotEmpty)columnSpacing,
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IntrinsicWidth(
                            child: box(context, state,
                              height: 44,
                              width: null,
                              borderRadius: baseBorderRadius,
                              hintText: hintText ?? lang('Chọn file'),
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 16
                              )
                            ),
                          ),
                        )
                      ]
                    ],
                  );
                  case FormMediaType.avatar:
                    final e = state.items.values.firstOrNull;
                    if (e != null) {
                      return BlocSelector<FormMediaBloc, FormMediaState, MediaItem?>(
                          key: ValueKey('Item-${e.key}'),
                          selector: (state) => state.items[e.key],
                          builder: (context, e) {
                            if (e == null) {
                              return const SizedBox.shrink();
                            }
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: box(context, state, e: e),
                            );
                          });
                    }
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: box(context, state, e: state.items.values.firstOrNull),
                    );
                  case FormMediaType.image:
                  case FormMediaType.images:
                    return image(context, state);
                  case FormMediaType.file:
                  case FormMediaType.files:
                    return files(context, state);
                  case FormMediaType.video:
                  case FormMediaType.videos:
                  return videos(context, state);
                  }
              },
            ),
          )
      );
    });
  }

  Widget image(BuildContext context, FormMediaState state,
      {bool hideFile = false, bool hideAddNew = false}){
    final bloc = context.read<FormMediaBloc>();
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        if (state.items.isNotEmpty)
          ...(hideFile ? state.items.values.where((e) => (e.link ?? e.path ?? '').isImageFileName) : state.items.values).map((e) {
            return BlocSelector<FormMediaBloc, FormMediaState, MediaItem?>(
              key: ValueKey('Item-${e.key}'),
              selector: (state) => state.items[e.key],
              builder: (context, e) {
                if (e == null) {
                  return const SizedBox.shrink();
                }
                return box(context, state,
                  width: 100,
                  height: 100,
                  borderRadius: baseBorderRadius,
                  e: e,
                  showDelete: true
                );
              });
          }),
        if (showButtonAdd(bloc) && !hideAddNew)
          box(
            context,
            state,
            width: 100,
            height: 100,
            borderRadius: baseBorderRadius,
          )
      ],
    );
  }

  Widget files(BuildContext context, FormMediaState state, {bool hideImage = false, bool hideAddNew = false}){
    final bloc = context.read<FormMediaBloc>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showButtonAdd(bloc) && !hideAddNew)Align(
          alignment: Alignment.centerLeft,
          child: IntrinsicWidth(
            child: box(context, state,
              height: 44,
              width: null,
              borderRadius: baseBorderRadius,
              hintText: hintText ?? lang('Chọn file'),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16)
            ),
          ),
        ),
        if (showButtonAdd(bloc) && state.items.values.isNotEmpty) h8,
        ...(hideImage ? state.items.values.where((e) => !(e.link ?? e.path ?? '').isImageFileName) : state.items.values).map<Widget>((e) {
            return BlocSelector<FormMediaBloc, FormMediaState, MediaItem?>(
                key: ValueKey('Item-${e.key}'),
                selector: (state) => state.items[e.key],
                builder: (context, e) {
                  if (e == null) {
                    return const SizedBox.shrink();
                  }
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: e.error != null
                          ? lighten(Theme.of(context).colorScheme.error, 0.52)
                          : AppColors.gray100
                    ),
                    padding: EdgeInsets.only(left: 12, top: 5, bottom: 5, right: e.isUploading ? 12 : 0),
                    constraints: const BoxConstraints(minHeight: 50),
                    child: Row(
                      children: [
                        if (!e.isUploading) FormMedia.icon(context, getFileName(e.path ?? e.link ?? '')),
                        if (e.isUploading)
                          const IconButton(
                            onPressed: null,
                            icon: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator.adaptive(
                                strokeWidth: 1.5,
                              ),
                            )
                          ),
                        w12,
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  '${getFileName(e.path ?? e.link ?? '')}${!empty(e.size) ? ' (${toRound(byte2Mb(e.size!), 2)} MB)' : ''}'),
                              if (e.error != null)
                                Text(
                                  e.error!,
                                  style: AppTextStyles.small.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ).marginOnly(top: 5)
                            ],
                          ),
                        ),
                        if (enabled) ...[
                          if (e.hasRetry)
                            IconButton(
                              onPressed: () {
                                FocusScope.of(context).requestFocus(FocusNode());
                                bloc.reUpload(e);
                              },
                              icon: const Icon(ViIcons.refresh_one_way)
                            ),
                          if (!e.isUploading)
                            deleteBtn(context, e,
                              color: Colors.transparent
                            ),
                        ]
                      ],
                    ),
                  );
                });
          }).toList().insertBetween(columnSpacing),
      ],
    );
  }

  Widget videos(BuildContext context, FormMediaState state){
    final bloc = context.read<FormMediaBloc>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showButtonAdd(bloc))Align(
          alignment: Alignment.centerLeft,
          child: IntrinsicWidth(
            child: box(context,
              state,
              height: 44,
              width: null,
              borderRadius: baseBorderRadius,
              hintText: hintText ?? lang('Chọn file'),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16)),
          ),
        ),
        if (showButtonAdd(bloc) && state.items.values.isNotEmpty) h8,
        ...state.items.values.map((e) {
            return BlocSelector<FormMediaBloc, FormMediaState, MediaItem?>(
              key: ValueKey('Item-${e.key}'),
              selector: (state) => state.items[e.key],
              builder: (context, e) {
                if (e == null) {
                  return const SizedBox.shrink();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: e.error != null ? lighten(Theme.of(context).colorScheme.error, 0.52) : AppColors.gray100
                      ),
                      clipBehavior: Clip.antiAlias,
                      margin: EdgeInsets.only(top: enabled && state.items.keys.toList().indexOf(e.key) > 0 ? 8 : 0),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 160,
                            decoration: BoxDecoration(
                              borderRadius: baseBorderRadius,
                              color: Colors.black,
                              image: !empty(e.link) ? DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(thumbnail(e.link ?? '', ratio: 16/9)))
                                  : null,
                            ),),
                          if (e.isUploading)
                            Center(
                              child: TextButton.icon(
                                onPressed: null,
                                icon: const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator.adaptive(
                                    strokeWidth: 1.5,

                                  ),
                                ),
                                label: Text('${(toRound(e.percentUploading * 100, 1))}%', style: const TextStyle(
                                    color: Colors.white
                                ),),
                              ),
                            ),
                          if (enabled) ...[
                            if (e.hasRetry)
                              Center(
                                child: IconButton(
                                    onPressed: () {
                                      FocusScope.of(context).requestFocus(FocusNode());
                                      bloc.reUpload(e);
                                    },
                                    icon: const Icon(ViIcons.refresh_one_way)
                                ),
                              ),
                            if (!e.isUploading)
                              Positioned(
                                bottom: 5,
                                right: 5,
                                child: deleteBtn(context, e),
                              ),
                            if (!empty(e.link))
                              Positioned(
                                bottom: 5,
                                left: 5,
                                child: VideoInfo(e.link ?? ''),
                              ),
                          ]
                        ],
                      ),
                    ),
                    if(e.error != null)VHVForm.instance.errorWidget(context, e.error)
                  ],
                );
              });
          }),
      ],
    );
  }

  bool showButtonAdd(FormMediaBloc bloc){
    final state = bloc.state;
    return (state.items.isEmpty || enabled) && state.items.length < bloc.length;
  }

  InputDecoration boxDecoration(BuildContext context, BorderRadius borderRadius) {
    final border = Theme.of(context).inputDecorationTheme.border?.isType<OutlineInputBorder>();
    final disabledBorder = Theme.of(context).inputDecorationTheme.disabledBorder?.isType<OutlineInputBorder>();
    final enabledBorder = Theme.of(context).inputDecorationTheme.enabledBorder?.isType<OutlineInputBorder>();
    final focusedBorder = Theme.of(context).inputDecorationTheme.enabledBorder?.isType<OutlineInputBorder>();
    final errorBorder = Theme.of(context).inputDecorationTheme.errorBorder?.isType<OutlineInputBorder>();
    return InputDecoration(
      contentPadding: const EdgeInsets.all(1),
      border: border?.copyWith(borderRadius: borderRadius),
      disabledBorder: disabledBorder?.copyWith(borderRadius: borderRadius),
      enabledBorder: enabledBorder?.copyWith(borderRadius: borderRadius),
      focusedBorder: focusedBorder?.copyWith(borderRadius: borderRadius),
      errorBorder: errorBorder?.copyWith(borderRadius: borderRadius),
    );
  }

  Widget box(BuildContext context,
      FormMediaState state,
      {double? width = 80.0,
      double? height = 80.0,
      BorderRadius borderRadius = const BorderRadius.all(Radius.circular(80)),
      MediaItem? e,
      bool showDelete = false,
      String? hintText,
      EdgeInsets? padding}) {
    final bloc = context.read<FormMediaBloc>();
    IconData icon(){
      if(bloc.type == FormMediaType.file || bloc.type == FormMediaType.files || bloc.type == FormMediaType.multiPickers || bloc.type == FormMediaType.multiPicker){
        return ViIcons.upload_cloud;
      }else if(bloc.type == FormMediaType.video || bloc.type == FormMediaType.videos){
        return ViIcons.play;
      }
      return ViIcons.image_plus;
    }
    final errorText = state.isUploading ? null : this.errorText;
    return SizedBox(
      width: width,
      height: height,
      child: Focus(
        focusNode: focusNode,
        child: InputDecorator(
            decoration: boxDecoration(context, borderRadius).copyWith(
              error: errorText != null ? const SizedBox.shrink() : null
            ),
            expands: true,
            child: Material(
              color: errorText != null ? Theme.of(context).colorScheme.errorContainer : Theme.of(context).cardColor,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: borderRadius,
              ),
              child: InkWell(
                // borderRadius: borderRadius,
                onTap: enabled && (!showDelete || e == null)
                    ? () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        bloc.selectFiles(context: context);
                      }
                    : ((e != null && !isPrivate) ? (){

                        openFile(e.link ?? e.path ?? '');

                } : null),
                child: Padding(
                  padding: padding ?? EdgeInsets.zero,
                  child: SizedBox(
                    width: width,
                    // height: double.infinity,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (e != null && !isPrivate)
                          ImageViewer(
                            !empty(e.link) ? e.link : e.path,
                            ratio: 1,
                            fit: BoxFit.cover,
                            width: width,
                            height: height,
                          ),
                        if (e != null && isPrivate)SizedBox(
                          width: width,
                          height: height,
                          child: FittedBox(child: Icon(ViIcons.image, size: 50,),)
                        ),
                        if (e != null && e.isUploading)
                          Container(
                            color: Colors.white.withValues(alpha: 0.2),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        if (e == null && hintText == null) Center(child: Icon(icon()),),
                        if (e == null && hintText != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(icon()),
                              w8,
                              Text(hintText),
                            ],
                          ),
                        if (showDelete && !hideDeleteButton && e != null && enabled)
                          Positioned(
                            bottom: 5,
                            right: 5,
                            child: deleteBtn(context, e),
                          )
                      ],
                    ),
                  ),
                ),
              ),
            )),
      ),
    );
  }
  IconButton deleteBtn(BuildContext context, MediaItem e, {Color? color}){
    final bloc = context.read<FormMediaBloc>();
    return IconButton(
      onPressed: enabled ? () {
        FocusScope.of(context).requestFocus(FocusNode());
        bloc.delete(e);
      } : null,
      icon: const Icon(ViIcons.trash_can, color: AppColors.red,),
      style: IconButton.styleFrom(
        backgroundColor: color ?? Theme.of(context).cardColor,
        padding: EdgeInsets.zero,
        fixedSize: const Size(40, 40),
        minimumSize: const Size(40, 40),
        maximumSize: const Size(40, 40),
      ),
    );
  }
}