import 'package:dio/dio.dart';
import 'package:vhv_network/src/helper.dart';
import 'package:vhv_network/vhv_network.dart';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'dart:typed_data';

import 'package:vhv_shared/vhv_shared.dart';
extension DioBrowser on Dio{
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
    try{

    final response = await BasicAppConnect.get(urlConvert(urlPath, true),
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
        handlingResponse: false,
        options: options,
      );

      if(response is Response) {
        final bytes = Uint8List.fromList(response.data!);

        // Convert bytes to a JS array (JSArray<BlobPart>)
        final jsArray = <JSAny>[bytes.toJS].toJS;

        // Create Blob
        final blob = web.Blob(jsArray);

        // Create object URL
        final objectUrl = web.URL.createObjectURL(blob);

        // Create <a> tag
        final anchor = web.HTMLAnchorElement()
          ..href = objectUrl
          ..download = getFileName(urlPath);

        // Click to trigger download
        anchor.click();

        // Revoke URL
        web.URL.revokeObjectURL(objectUrl);
        return response;
      }
    }catch(e){
      return Response(data: null, requestOptions: RequestOptions());
    }
    return Response(data: null, requestOptions: RequestOptions());
  }
}