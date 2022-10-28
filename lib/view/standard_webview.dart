
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutterwave_standard/models/responses/charge_response.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'flutterwave_style.dart';

class StandardWebView extends StatefulWidget {
  final String url;
  final FlutterwaveStyle? style;
  const StandardWebView({required this.url, this.style});

  @override
  State<StandardWebView> createState() => _StandardWebViewAppState();
}

class _StandardWebViewAppState extends State<StandardWebView> {

  @override
  void initState() {
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers = {
      Factory(() => EagerGestureRecognizer())
    };

    UniqueKey _key = UniqueKey();

    AppBar? appBar;
    if (widget.style != null) {
      appBar = AppBar(
        title: Text(
          widget.style!.getAppBarText(),
          style: widget.style!.getAppBarTextStyle(),
        ),
      );
    }

      return SafeArea(
          child: Scaffold(
            key: _key,
            appBar: appBar,
            body: WebView(
              initialUrl: widget.url,
              javascriptMode:  JavascriptMode.unrestricted,
              gestureRecognizers: gestureRecognizers,
              navigationDelegate: (request) {
                final url = Uri.parse(request.url);
                if (_hasCompletedProcessing(url)) {
                  _finish(url);
                  return NavigationDecision.prevent;
                } else {
                  _hasCompletedProcessing(url);
                  return NavigationDecision.navigate;
                }
              }
            ),
          )
      );
  }

  bool _hasCompletedProcessing(final Uri uri) {
    final status = uri.queryParameters["status"];
    final txRef = uri.queryParameters["tx_ref"];
    final id = uri.queryParameters["transaction_id"];
    return status != null && txRef != null;
  }

  _finish(final Uri uri) {
    final status = uri.queryParameters["status"];
    final txRef = uri.queryParameters["tx_ref"];
    final id = uri.queryParameters["transaction_id"];
    final ChargeResponse chargeResponse = ChargeResponse(
      status: status,
      transactionId: id,
      txRef: txRef,
      success: status?.contains("success") == true
    );
    Navigator.pop(context, chargeResponse);
  }
}