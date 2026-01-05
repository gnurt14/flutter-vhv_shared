import 'package:dio/dio.dart';

extension DioNative on Dio{
  Future<Response> downloadForBrowser(
      String urlPath,
      dynamic savePath, {
        ProgressCallback? onReceiveProgress,
        Map<String, dynamic>? queryParameters,
        CancelToken? cancelToken,
        bool deleteOnError = true,
        FileAccessMode fileAccessMode = FileAccessMode.write,
        String lengthHeader = Headers.contentLengthHeader,
        Object? data,
        Options? options,
      })async {
    throw UnsupportedError(
      'The downloadForBrowser method is available in the Web environment.',
    );
  }
}