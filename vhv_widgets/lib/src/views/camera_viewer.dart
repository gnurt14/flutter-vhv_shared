import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vhv_widgets/vhv_widgets.dart';


class CameraViewer extends StatefulWidget {
  const CameraViewer({super.key});

  @override
  State<CameraViewer> createState() {
    return _CameraViewerState();
  }
}

IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
    }
}

void logError(String code, String? message) {
  if (message != null) {
  } else {
  }
}

class _CameraViewerState extends State<CameraViewer>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? controller;
  late List<CameraDescription> cameras;
  XFile? imageFile;
  late AnimationController _flashModeControlRowAnimationController;
  late AnimationController _focusModeControlRowAnimationController;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;
  int _pointers = 0;
  bool initial = false;
  Future<void> init()async{
    cameras = await initCamera();
    if(mounted){
      setState(() {
        initial = true;
      });
    }
  }
  @override
  void initState() {
    init();
    super.initState();
    _ambiguate(WidgetsBinding.instance)?.addObserver(this);

    _flashModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _focusModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _ambiguate(WidgetsBinding.instance)?.removeObserver(this);
    _flashModeControlRowAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: <Widget>[
          Container(
            height: double.infinity,
            width: double.infinity,
            color: Colors.black,
            child: Center(child: _cameraPreviewWidget()),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: CameraButton(onTap: onTakePictureButtonPressed),
            ),
          ),
          if(initial)Align(
            alignment: Alignment.topCenter,
            child: SafeArea(child: _modeControlRowWidget()),
          ),
          if(!initial)const Center(
            child: CircularProgressIndicator.adaptive(),
          )
        ],
      ),
    );
  }

  Widget _cameraPreviewWidget() {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return const CircularProgressIndicator();
    } else {
      return Listener(
        onPointerDown: (_) => _pointers++,
        onPointerUp: (_) => _pointers--,
        child: CameraPreview(
          controller!,
          child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onScaleStart: _handleScaleStart,
                  onScaleUpdate: _handleScaleUpdate,
                  onTapDown: (details) => onViewFinderTap(details, constraints),
                );
              }),
        ),
      );
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    if (controller == null || _pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);

    await controller!.setZoomLevel(_currentScale);
  }


  Widget _modeControlRowWidget() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        children: <Widget>[
          OptionButton(
            icon: Icons.close,
            onTapCallback: (){
              appNavigator.pop();
            },
          ),
          const Spacer(),
          _cameraTogglesButton(),
          // SizedBox(width: 15, height: 15),
          //  _focusModeButton(),
          const SizedBox(width: 15, height: 15),
          _flashModeButton(),
        ],
      ),
    );
  }

  int _indexFlash(int current, int max){
    if(current < max){
      return current + 1;
    }else{
      return 0;
    }
  }

  Widget _flashModeButton() {
    List<dynamic> list = [
      FlashMode.off,
      FlashMode.auto,
      FlashMode.always,
      FlashMode.torch,
    ];
    List<IconData> listIcon = [
      Icons.flash_off,
      Icons.flash_auto,
      Icons.flash_on,
      Icons.highlight,
    ];
    final int index = (controller?.value.flashMode != null)?
    list.indexOf(controller?.value.flashMode):0;
    final int nextIndex = _indexFlash(index, list.length - 1);
    return OptionButton(
      icon: listIcon.elementAt(index),
      onTapCallback: (){
        onSetFlashModeButtonPressed(list.elementAt(nextIndex));
      },
    );
  }

  // Widget _focusModeButton() {
  //   return Builder(
  //     builder: (_){
  //       return OptionButton(
  //         icon: (controller?.value.focusMode == FocusMode.auto)
  //             ?Icons.filter_center_focus:Icons.center_focus_strong_outlined,
  //         onTapCallback: (){
  //           onSetFocusModeButtonPressed((controller?.value.focusMode == FocusMode.locked)
  //               ?FocusMode.auto:FocusMode.locked);
  //         },
  //       );
  //     },
  //   );
  // }
  CameraDescription? cameraDescription;

  OptionButton _cameraTogglesButton() {
    final List<CameraDescription> toggles = <CameraDescription>[];
    int index = 0;
    int nextIndex = 0;
    void onChanged() {
      if (cameraDescription != null) {
        index = toggles.indexOf(cameraDescription!);
        if(index < toggles.length - 1){
          nextIndex = index + 1;
        }
      }
      onNewCameraSelected(toggles.elementAt(nextIndex));
    }

    if (cameras.isEmpty) {
    } else {
      for (CameraDescription camera in cameras) {
        if(cameraDescription == null
            && camera.lensDirection == CameraLensDirection.back){
          cameraDescription = camera;
          onNewCameraSelected(camera);
        }
        toggles.add(camera);
      }
    }
    return OptionButton(
      icon: cameraDescription != null?getCameraLensIcon(cameraDescription!.lensDirection):null,
      onTapCallback: onChanged,
    );
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final CameraController cameraController = controller!;

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    cameraDescription = cameraDescription;
    if (controller != null) {
      await controller!.dispose();
    }

    final CameraController cameraController = CameraController(
      cameraDescription,
      kIsWeb ? ResolutionPreset.max : ResolutionPreset.ultraHigh,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) setState(() {});
      if (cameraController.value.hasError) {
        showMessage(
            'Camera error ${cameraController.value.errorDescription}', type: 'error');
      }
    });

    try {
      await cameraController.initialize();
      await Future.wait([
        cameraController
            .getMaxZoomLevel()
            .then((value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((value) => _minAvailableZoom = value),
      ]);
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onTakePictureButtonPressed() {
    takePicture().then((XFile? file) {
      if (mounted) {
        appNavigator.pop(file);
      }
    });
  }

  void onFlashModeButtonPressed() {
    if (_flashModeControlRowAnimationController.value == 1) {
      _flashModeControlRowAnimationController.reverse();
    } else {
      _flashModeControlRowAnimationController.forward();
      _focusModeControlRowAnimationController.reverse();
    }
  }


  void onFocusModeButtonPressed() {
    if (_focusModeControlRowAnimationController.value == 1) {
      _focusModeControlRowAnimationController.reverse();
    } else {
      _focusModeControlRowAnimationController.forward();
      _flashModeControlRowAnimationController.reverse();
    }
  }

  void onAudioModeButtonPressed() {
    if (controller != null) {
      onNewCameraSelected(controller!.description);
    }
  }

  void onCaptureOrientationLockButtonPressed() async {
    try {
      if (controller != null) {
        final CameraController cameraController = controller!;
        if (cameraController.value.isCaptureOrientationLocked) {
          await cameraController.unlockCaptureOrientation();
        } else {
          await cameraController.lockCaptureOrientation();
        }
      }
    } on CameraException catch (e) {
      _showCameraException(e);
    }
  }

  void onSetFlashModeButtonPressed(FlashMode mode) {
    setFlashMode(mode).then((_) {
      if (mounted) setState(() {});
    });
  }


  void onSetFocusModeButtonPressed(FocusMode mode) {
    setFocusMode(mode).then((_) {
      if (mounted) setState(() {});
    });
  }



  Future<void> setFlashMode(FlashMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller!.setFlashMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }


  Future<void> setFocusMode(FocusMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller!.setFocusMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  bool taking = false;

  Future<XFile?> takePicture() async {
    if(!taking) {
      taking = true;
      final CameraController? cameraController = controller;
      if (cameraController == null || !cameraController.value.isInitialized) {
        showMessage('Error: select a camera first.', type: 'error');
        taking = false;
        return null;
      }

      if (cameraController.value.isTakingPicture) {
        taking = false;
        return null;
      }
      try {
        XFile file = await cameraController.takePicture();
        taking = false;
        return file;
      } on CameraException catch (e) {
        taking = false;
        _showCameraException(e);
        return null;
      }
    }
    return null;
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showMessage('Error: ${e.code}\n${e.description}', type:'error');
  }
}

class CameraApp extends StatelessWidget {
  const CameraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CameraViewer(),
    );
  }
}

T? _ambiguate<T>(T? value) => value;

class OptionButton extends StatefulWidget {
  final IconData? icon;
  final Function? onTapCallback;
  final AnimationController? rotationController;
  final ValueNotifier<DeviceOrientation>? orientation;
  final bool isEnabled;
  const OptionButton({
    super.key,
    this.icon,
    required this.onTapCallback,
    this.rotationController,
    this.orientation,
    this.isEnabled = true,
  });

  @override
  State<OptionButton> createState() => _OptionButtonState();
}

class _OptionButtonState extends State<OptionButton>
    with SingleTickerProviderStateMixin {
  final double _angle = 0.0;

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !widget.isEnabled,
      child: Opacity(
        opacity: widget.isEnabled ? 1.0 : 0.3,
        child: Transform.rotate(
          angle: _angle,
          child: ClipOval(
            child: Material(
              color: const Color(0xFF4F6AFF),
              child: InkWell(
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(
                    widget.icon,
                    color: Colors.white,
                    size: 24.0,
                  ),
                ),
                onTap: () {
                  if (widget.onTapCallback != null) {
                    HapticFeedback.selectionClick();

                    widget.onTapCallback!();
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class CameraButton extends StatefulWidget {
  final Function? onTap;

  const CameraButton({
    super.key,
    this.onTap,
  });

  @override
  State<CameraButton> createState() => _CameraButtonState();
}

class _CameraButtonState extends State<CameraButton>
    with SingleTickerProviderStateMixin {
  final Duration _duration = const Duration(milliseconds: 100);
  AnimationController? _animationController;
  double _scale = 0;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: _duration,
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
      if(mounted){
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _animationController!.value;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: SizedBox(
        height: 60,
        width: 60,
        child: Transform.scale(
          scale: _scale,
          child: CustomPaint(
            painter: CameraButtonPainter(
            ),
          ),
        ),
      ),
    );
  }

  void _onTapDown(TapDownDetails details) {
    _animationController!.forward();
  }

  void _onTapUp(TapUpDetails details) {
    Future.delayed(_duration, () {
      _animationController!.reverse();
    });

    widget.onTap?.call();
  }

  void _onTapCancel() {
    _animationController!.reverse();
  }
}

class CameraButtonPainter extends CustomPainter {

  CameraButtonPainter();

  @override
  void paint(Canvas canvas, Size size) {
    var bgPainter = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    var radius = size.width / 2;
    var center = Offset(size.width / 2, size.height / 2);
    bgPainter.color = Colors.white.withValues(alpha: .5);
    canvas.drawCircle(center, radius, bgPainter);
    bgPainter.color = Colors.white;
    canvas.drawCircle(center, radius - 8, bgPainter);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}