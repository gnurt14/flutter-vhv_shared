library html_editor;
export 'package:html_editor/src/html_editor_unsupported.dart'
if(dart.library.html) 'package:html_editor/src/html_editor_web.dart'
if(dart.library.io) 'package:html_editor/src/html_editor_mobile.dart';
typedef void OnClik();

