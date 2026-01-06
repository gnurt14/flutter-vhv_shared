// Dành cho môi trường không phải web (Android/iOS), tránh lỗi compile
class _FakePlatformViewRegistry {
  void registerViewFactory(String viewId, dynamic Function(int) cb) {}
}

final platformViewRegistry = _FakePlatformViewRegistry();
