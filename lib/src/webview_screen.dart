import 'dart:developer';
import 'dart:io';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:flutter/material.dart';
import 'package:hesabe/hesabe.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewScreen extends StatefulWidget {
  final String paymentURL;
  final String? responseUrl;
  final String? failureUrl;

  WebviewScreen({
    required this.paymentURL,
    this.responseUrl,
    this.failureUrl,
  });

  @override
  _WebviewScreenState createState() => _WebviewScreenState();
}

class _WebviewScreenState extends State<WebviewScreen> {
  bool flag = false;
  late final WebViewController _controller;

@override
void initState() {
  super.initState();

  _controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (String url) {
          if (widget.responseUrl != null && url.contains('${widget.responseUrl}')) {
            if (mounted) setState(() { flag = true; });
            parseResult(url);
          } else if (widget.failureUrl != null && url.contains('${widget.failureUrl}')) {
            if (mounted) setState(() { flag = true; });
            parseResult(url);
          }
        },
        onPageStarted: (url) {
          log('onPageStarted $url');
        },
      ),
    )
    ..loadRequest(Uri.parse(widget.paymentURL));
}


  @override
 Widget build(BuildContext context) {
  return SafeArea(
    child: WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(Hesabe.EVENT_PAYMENT_CANCELLED_BY_USER);
        return false;
      },
      child: Scaffold(
        body: WebViewWidget(controller: _controller), // ✅ Use WebViewWidget
      ),
    ),
  );
}


  void parseResult(String url) {
    final parse = Uri.parse(url);
    final data = parse.queryParameters['data'];
    Navigator.of(context).pop(data);
  }
}
