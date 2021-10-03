import 'dart:developer';
import 'dart:io';

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
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
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
          body: WebView(
            initialUrl: widget.paymentURL,
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              _controller = webViewController;
              if (!flag) {
                _controller.loadUrl(widget.paymentURL);
              }
            },
            onPageFinished: (String url) {
              /* Check if URL contains the value given at 'responseUrl' field */
              if (widget.responseUrl != null &&
                  url.contains('${widget.responseUrl}')) {
                if (mounted)
                  setState(() {
                    flag = true;
                  });
                /* If yes, parse the result */
                parseResult(url);
              } else if (widget.failureUrl != null &&
                  url.contains('${widget.failureUrl}')) {
                if (mounted)
                  setState(() {
                    flag = true;
                  });
                parseResult(url);
              }
            },
            onPageStarted: (url) {
              log('onPageStarted $url');
            },
            gestureNavigationEnabled: true,
          ),
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
