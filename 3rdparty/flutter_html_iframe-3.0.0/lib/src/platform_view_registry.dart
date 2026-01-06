// ignore_for_file: avoid_web_libraries_in_flutter
// ignore_for_file: unused_import

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Tạo 1 alias đến platformViewRegistry chỉ dành cho web
// Khi chạy trên web, import dart:ui_web
// Khi không phải web, dùng stub để tránh lỗi build
export 'platform_view_registry_stub.dart'
if (dart.library.ui_web) 'platform_view_registry_web.dart';
