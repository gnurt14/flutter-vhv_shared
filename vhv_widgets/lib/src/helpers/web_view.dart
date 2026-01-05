part of '../helper.dart';
Future<bool> Function() get setLoginWebView => AppWebViewManager().loginWebView;
Future<void> Function() get logoutWebView => AppWebViewManager().logoutWebView;