import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfx/pdfx.dart';
import 'package:vhv_widgets/src/import.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class PDFCacheViewer extends StatefulWidget {
  final String url;
  final int currentPage;
  final String? title;
  final Function(int page, int total)? onPageChanged;
  final Function(int pages)? onRender;
  final bool hideRotateButton;
  final bool hideCloseButton;
  final Function(PdfController controller)? onCreatedController;
  final bool isLocalFile;

  const PDFCacheViewer(this.url,
      {super.key,
      this.onPageChanged,
      this.currentPage = 1,
      this.title,
      this.hideRotateButton = false,
      this.hideCloseButton = false,
      this.isLocalFile = false,
      this.onRender,
      this.onCreatedController});

  @override
  State<PDFCacheViewer> createState() => _PDFCacheViewerState();
}

class _PDFCacheViewerState extends State<PDFCacheViewer> {
  int? _currentIndex;
  int? currentIndex;
  String? _subKey;
  bool isLoaded = true;

  @override
  void dispose() {
    factories.remove('pdfReloadCallback');
    super.dispose();
  }

  @override
  void initState() {
    factories['pdfReloadCallback'] = () {
      currentIndex = _currentIndex;
      _subKey = '${time()}';
      setState(() {});
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoaded) {
      return const Loading();
    }
    return PopScope(
      onPopInvokedWithResult: (_, _) async {
        await SystemChrome.setPreferredOrientations(appOrientations);
      },
      child: Stack(
        alignment: Alignment.topRight,
        children: <Widget>[
          _PDFScreen(
            widget.url,
            isLocalFile: widget.isLocalFile,
            onRender: widget.onRender,
            notRenderChanged: !empty(_subKey),
            currentPage: currentIndex ?? widget.currentPage,
            onPageChanged: (int page, int total) {
              if (mounted) {
                _currentIndex = page;
                currentIndex = page;
                if (widget.onPageChanged != null) {
                  widget.onPageChanged!(page, total);
                }
                setState(() {});
              }
            },
            onCreatedController: widget.onCreatedController,
          ),
          if (!widget.hideRotateButton &&
              widget.url.endsWith('.pdf') &&
              (!kIsWeb && (Platform.isAndroid || Platform.isIOS)))
            IconButton(
                icon: const Icon(Icons.screen_rotation),
                color: Colors.grey,
                onPressed: () async {
                  try {
                    if (MediaQuery.of(context).orientation ==
                        Orientation.landscape) {
                      await SystemChrome.setPreferredOrientations(
                          appOrientations);
                    } else {
                      await SystemChrome.setPreferredOrientations([
                        DeviceOrientation.landscapeLeft,
                        DeviceOrientation.landscapeRight
                      ]);
                    }
                  } catch (e) {
                    showMessage(e.toString());
                  }
                }),
          if (((kIsWeb || !(Platform.isAndroid || Platform.isIOS)) &&
                  Navigator.canPop(context)) &&
              !widget.hideCloseButton)
            IconButton(
                icon: const Icon(Icons.close),
                color: Colors.grey,
                onPressed: () async {
                  appNavigator.pop();
                }),
        ],
      ),
    );
  }
}

class _PDFScreen extends StatefulWidget {
  final String filePdf;
  final int currentPage;
  final Function(PdfController controller)? onCreatedController;
  final Function(int pages)? onRender;
  final Function(int page, int total)? onPageChanged;
  final bool notRenderChanged;
  final bool isLocalFile;

  const _PDFScreen(this.filePdf,
      {this.currentPage = 1,
      this.onRender,
      this.onCreatedController,
      this.onPageChanged,
      this.notRenderChanged = false,
      this.isLocalFile = false});

  @override
  __PDFScreenState createState() => __PDFScreenState();
}

class __PDFScreenState extends State<_PDFScreen> {
  PdfController? _pdfController;
  String? filePath;
  int totalPages = 0;
  int currentPage = 0;
  late CancelToken cancelToken;

  ValueNotifier<double> process = ValueNotifier(0.0);

  @override
  void initState() {
    cancelToken = CancelToken();
    currentPage = widget.currentPage;
    init();
    super.initState();
  }

  @override
  void dispose() {
    if (_pdfController != null) {
      _pdfController!.dispose();
    }
    cancelToken.cancel('Cancel by User');
    process.dispose();
    super.dispose();
  }

  Widget? viewer;

  Future<void> init() async {
    if (widget.filePdf.endsWith('.pdf')) {
      if (widget.filePdf.startsWith('assets')) {
        try {
          _pdfController = PdfController(
              document: PdfDocument.openAsset(widget.filePdf),
              initialPage: widget.currentPage);
          setState(() {});
          if (widget.onCreatedController != null && _pdfController != null) {
            widget.onCreatedController!(_pdfController!);
          }
        } catch (_) {}
      } else {
        if (!widget.isLocalFile) {
          final file = await createFileOfPdfUrl(widget.filePdf);
          filePath = file;
        } else {
          filePath = widget.filePdf;
        }
        if (mounted && filePath != null) {
          _pdfController = PdfController(
            document: PdfDocument.openFile(filePath!),
            initialPage: widget.currentPage,
          );
          setState(() {});
          if (widget.onCreatedController != null && _pdfController != null) {
            widget.onCreatedController!(_pdfController!);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.filePdf.endsWith('.pdf')) {
      return fileUnValid;
    }
    if (widget.filePdf.startsWith('assets') && !empty(_pdfController)) {
      return pdfView;
    }
    if (filePath != null) {
      if (filePath != '') {
        return pdfView;
      } else {
        return loadFail;
      }
    } else {
      return loading;
    }
  }

  Widget? errorWidget;

  Widget get pdfView {
    return Scaffold(
      body: Material(
          color: Colors.white,
          child: Center(
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                PdfView(
                  onDocumentError: (error) {
                    setState(() {
                      // debugPrint('${widget.filePdf}');
                      errorWidget = Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          color: Theme.of(context).cardColor,
                          child: Center(
                            child:
                                Text("File không thể hiển thị lúc này!".lang()),
                          ));
                    });
                  },
                  controller: _pdfController!,
                  scrollDirection: Axis.vertical,
                  onDocumentLoaded: (PdfDocument document) {
                    setState(() {
                      totalPages = document.pagesCount;
                      if (widget.onRender != null) {
                        widget.onRender!(document.pagesCount);
                      }
                      if (widget.onPageChanged != null &&
                          !widget.notRenderChanged) {
                        widget.onPageChanged!(
                            widget.currentPage, document.pagesCount);
                      }
                    });
                  },
                  onPageChanged: (page) {
                    if (widget.onPageChanged != null) {
                      widget.onPageChanged!(page, totalPages);
                    }
                    setState(() {
                      currentPage = page;
                    });
                  },
                ),
                if (errorWidget != null)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.8),
                      child: errorWidget!,
                    ),
                  ),
              ],
            ),
          )),
      bottomNavigationBar:
          !empty(totalPages) && !empty(factories['hasShowBottomPDFView'])
              ? Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x19000000),
                        blurRadius: 8,
                        offset: Offset(0, -2),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: IconButton(
                            onPressed: () {
                              setState(() {
                                widget.onPageChanged!(
                                    currentPage <= 1 ? 1 : currentPage--,
                                    totalPages);
                                _pdfController!.animateToPage(currentPage,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.linear);
                              });
                            },
                            icon: const Icon(ViIcons.chevron_left)),
                      ),
                      Text(
                          '$currentPage/${"{total, plural, one {# page} other {# pages}}".lang(value: totalPages)}'),
                      Material(
                        color: Colors.transparent,
                        child: IconButton(
                            onPressed: () {
                              setState(() {
                                widget.onPageChanged!(
                                    currentPage >= totalPages
                                        ? totalPages
                                        : currentPage++,
                                    totalPages);
                                _pdfController!.animateToPage(currentPage,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.linear);
                              });
                            },
                            icon: const Icon(ViIcons.chevron_right)),
                      ),
                    ],
                  ),
                )
              : null,
    );
  }

  Widget get fileUnValid {
    return Material(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("File không thể hiển thị lúc này!".lang(),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(widget.filePdf.substring(widget.filePdf.lastIndexOf('/') + 1),
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .color!
                        .withValues(alpha: 0.5)))
          ],
        ),
      ),
    );
  }

  Widget get loadFail {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Tải dữ liệu thất bại!".lang(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          BaseButton(
              child: Text(
                "Thử lại".lang(),
              ),
              onPressed: () async {
                setState(() {
                  filePath = null;
                });
                await init();
              })
        ],
      ),
    );
  }

  Widget get loading {
    return ValueListenableBuilder<double>(
        valueListenable: process,
        builder: (_, value, child) {
          return Scaffold(
            backgroundColor: Theme.of(context).cardColor,
            body: Center(
              child: Text('${"Đang tải".lang()} ${(value * 100).ceil()}%'),
            ),
          );
        });
  }

  Future<String?> createFileOfPdfUrl(String url) async {
    try {
      final res =
          await download(url, process: process, cancelToken: cancelToken);
      return res;
    } catch (_) {}
    return null;
  }
}
