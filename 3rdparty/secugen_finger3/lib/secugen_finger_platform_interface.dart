import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:secugen_finger/finger_data.dart';

import 'secugen_finger_method_channel.dart';

abstract class SecugenFingerPlatform extends PlatformInterface {
  /// Constructs a SecugenFingerPlatform.
  SecugenFingerPlatform() : super(token: _token);

  static final Object _token = Object();

  static SecugenFingerPlatform _instance = MethodChannelSecugenFinger();

  /// The default instance of [SecugenFingerPlatform] to use.
  ///
  /// Defaults to [MethodChannelSecugenFinger].
  static SecugenFingerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SecugenFingerPlatform] when
  /// they register themselves.
  static set instance(SecugenFingerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<Map?> create() {
    throw UnimplementedError('create() has not been implemented.');
  }

  Future<Map?> capture() {
    throw UnimplementedError('capture() has not been implemented.');
  }

  Future<Map?> register() {
    throw UnimplementedError('register() has not been implemented.');
  }

  Future<FingerData?> getData() {
    throw UnimplementedError('getData() has not been implemented.');
  }
  onCreate() {
    throw UnimplementedError('getData() has not been implemented.');
  }
  onResume() {
    throw UnimplementedError('getData() has not been implemented.');
  }
}
