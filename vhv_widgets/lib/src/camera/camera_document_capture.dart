import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vhv_widgets/src/import.dart';
import 'package:image/image.dart' as img;
class CameraCaptureData{
  final double ratio;
  final double width;
  final double radius;
  final double screenWidth;
  final File imageFile;
  final bool isFront;

  CameraCaptureData(this.imageFile, {required this.ratio, required this.width,
    required this.radius, required this.screenWidth, this.isFront = false});
}
class CameraDocumentCapture extends StatefulWidget {
  const CameraDocumentCapture({super.key,
    this.width,
    this.radius = 30,
    this.ratio = 3/2,
    this.lensDirection = CameraLensDirection.back,
    this.resolutionPreset = ResolutionPreset.high,
    this.bottomAction,
    this.marginDistance = 20,
    this.textTakePhoto,
    this.textSelectPhoto,
    this.backgroundColor,
    this.overlayColor,
    this.onDone,
    this.isOval = false
  });
  ///Width image after crop
  final double? width;
  ///Radius camera view in UI
  final double radius;
  ///Ratio camera view in UI
  final double ratio;
  ///Custom bottom action
  final Widget Function(VoidCallback onTake, VoidCallback onSelect)? bottomAction;
  ///Distance box camera view with left and right
  final double marginDistance;
  ///Custom text button Take photo
  final String? textTakePhoto;
  ///Custom text button Select photo
  final String? textSelectPhoto;
  final Color? backgroundColor;
  final Color? overlayColor;
  final CameraLensDirection lensDirection;
  final ResolutionPreset resolutionPreset;
  final Function(File? file)? onDone;
  final bool isOval;
  @override
  State<CameraDocumentCapture> createState() => _CameraCaptureState();
}

class _CameraCaptureState extends State<CameraDocumentCapture> {
  late CameraController controller;
  late List<CameraDescription> cameras;
  double get width{
    final w = context.width - (widget.marginDistance * 2);
    if(widget.width != null){
      return widget.width! > w ? w : widget.width!;
    }
    return w;
  }
  bool hasInit = false;
  double get widthContext => context.width;
  File? file;
  XFile? imageCap;
  @override
  void initState() {
    super.initState();
    initializeCameras().then((value) {
      if (cameras.isNotEmpty) {
        final len =  cameras.firstWhere((e) => e.lensDirection == widget.lensDirection);
        controller =
        CameraController(
            len,
            widget.resolutionPreset
        )..initialize().then((_) {
          if (!mounted) {
            return;
          }
          hasInit = true;
          setState(() {});
        });
      }
    });
  }
  Future<void> initializeCameras() async {
    await Permission.camera.request();
    cameras = await availableCameras();
    setState(() {});
  }


  Future<void> take(BuildContext context)async{
    showLoading();
    XFile file = await controller.takePicture();
    setState(() {
      imageCap = file;
    });
    File? croppedImage = await CaptureController.cropImageWithIsolate(
      CameraCaptureData(File(file.path),
        ratio: widget.ratio,
        width: width,
        radius: widget.radius,
        screenWidth: widthContext,
        isFront: isFront
      )
    );
    disableLoading();
    onBack(croppedImage);
  }
  Future<void> selectPhoto()async{
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if(image != null) {
      onBack(File(image.path));
    }
  }

  void onBack(File? file){
    if(file != null){
      if(widget.onDone != null){
        widget.onDone!(file);
      }else {
        appNavigator.pop(file);
      }
    }
  }

  bool get isFront => widget.lensDirection == CameraLensDirection.front;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Material(
        elevation: 0,
        color: widget.backgroundColor ?? const Color(0xff1e1e1e),
        child: Builder(
            builder: (context) {
              if(!hasInit){
                return Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: SizedBox(
                          width: width,
                          child: AspectRatio(
                              aspectRatio: widget.ratio,
                              child: widget.isOval ? ClipOval(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2)
                                  ),
                                  child: const Loading(),
                                ),
                              ) : Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(widget.radius),
                                  color: Colors.white.withValues(alpha: 0.2)
                                ),
                                child: const Loading(),
                              )
                          ),
                        ),
                      ),
                    ),
                    ColorFiltered(
                      colorFilter: const ColorFilter.matrix([
                        0.2126,0.7152,0.0722,0,0,
                        0.2126,0.7152,0.0722,0,0,
                        0.2126,0.7152,0.0722,0,0,
                        0,0,0,1,0,
                      ]),
                      child: IgnorePointer(
                        ignoring: true,
                        child: Opacity(
                          opacity: 0.5,
                          child: actionBottom(),
                        ),
                      ),
                    )
                  ],
                );
              }
              return Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Stack(
                        children: [
                          SizedBox(
                              width: double.infinity,
                              child: imageCap != null ?
                              (isFront ? Transform.flip(flipX: true,
                                child: Image.file(File(imageCap!.path)),
                              ) : Image.file(File(imageCap!.path)))
                                  : CameraPreview(controller)
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            left: 0,
                            bottom: 0,
                            child: ClipPath(
                              clipper: _CaptureShadowClipper(
                                ratio: widget.ratio,
                                width: width,
                                radius: widget.radius,
                                isOval: widget.isOval
                              ),
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                color: imageCap != null
                                  ? (widget.backgroundColor ?? const Color(0xff1e1e1e))
                                  : (widget.overlayColor ?? Colors.black.withValues(alpha: 0.8)
                                ),
                              )
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actionBottom()
                ],
              );
            }
        )
    );
  }
  Widget actionBottom(){
    return widget.bottomAction != null
        ? widget.bottomAction!(() => take(context), () => selectPhoto())
        : Padding(
      padding: EdgeInsets.all(paddingBase),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 48,
            child: TextButton(
              onPressed: selectPhoto,
              style: TextButton.styleFrom(
                  foregroundColor: Colors.white
              ),
              child: Text(widget.textSelectPhoto ?? "Chọn từ thư viện".lang()),
            ),
          ),
          const SizedBox(height: 5,),
          SizedBox(
            height: 48,
            width: double.infinity,
            child: BaseButton(
                onPressed: ()async{
                  take(context);
                },
                child: Text(widget.textTakePhoto ?? "Chụp ảnh".lang())
            ),
          )
        ],
      ),
    );
  }
}
class _CaptureShadowClipper extends CustomClipper<Path> {
  final double width;
  final double ratio;
  final double radius;
  final bool isOval;

  _CaptureShadowClipper({required this.radius, required this.width, required this.ratio, this.isOval = false});
  @override
  Path getClip(Size size) {
    final height = width / ratio;
    Path path = Path();
    if(!isOval) {
      path.addRRect(RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset(size.width / 2, size.height / 2),
              width: width,
              height: height
          ),
          Radius.circular(radius)
      ));
    }else {
      path.addOval(Rect.fromLTWH(
        (size.width - width) / 2,
        (size.height - height) / 2,
        width,
        height,
      ));
    }
    path = Path.combine(PathOperation.difference, Path()
      ..addRect(Rect.fromLTRB(0, 0, size.width, size.height)), path);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class CaptureController {
  static Future<Uint8List?> cropImage(File imageFile, {
    required double width,
    required double ratio,
    required double radius,
    required double screenWidth,
    bool isFront = false

  }) async {
    List<int> imageBytes = await imageFile.readAsBytes();
    img.Image originalImage = img.decodeImage(Uint8List.fromList(imageBytes))!;
    final scale = originalImage.width / screenWidth;
    final height = width / ratio;
    int x = ((originalImage.width - (width * scale)) / 2).round();
    int y = (originalImage.height - (height * scale)) ~/ 2;
    img.Image croppedImage = img.copyCrop(
      originalImage,
      x: x,
      y: y,
      width: (width * scale).round(),
      height: (height * scale).round(),
    );
    if(isFront) {
      croppedImage = img.flip(croppedImage, direction: img.FlipDirection.horizontal);
    }
    Uint8List croppedBytes = Uint8List.fromList(img.encodePng(croppedImage));
    return croppedBytes;
  }

  static Future<File?> cropImageWithIsolate(CameraCaptureData data) async {
    final receivePort = ReceivePort();
    await Isolate.spawn(_cropImage, [data, receivePort.sendPort]);
    final croppedBytes = await receivePort.first;
    if(croppedBytes is Uint8List) {
      String timestamp = DateTime
          .now()
          .millisecondsSinceEpoch
          .toString();
      Directory tempDir = await getTemporaryDirectory();

      String tempPath = '${tempDir.path}/cropped_image_$timestamp.png';

      await File(tempPath).writeAsBytes(croppedBytes);
      return File(tempPath);
    }
    return null;
  }

// Hàm sẽ được gọi trong isolate để xử lý cắt ảnh
  static void _cropImage(List<dynamic> arguments) async {
    CameraCaptureData data = arguments[0];
    SendPort sendPort = arguments[1];
    final file = await cropImage(data.imageFile,
        width: data.width,
        ratio: data.ratio,
        radius: data.radius,
        screenWidth: data.screenWidth,
        isFront: data.isFront
    );
    sendPort.send(file);
  }
}
