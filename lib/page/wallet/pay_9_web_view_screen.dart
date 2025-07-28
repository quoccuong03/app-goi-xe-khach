import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Pay9WebViewScreen extends StatefulWidget {
  const Pay9WebViewScreen({super.key, required this.url});

  final String url;

  @override
  State<Pay9WebViewScreen> createState() => _Pay9WebViewScreenState();
}

class _Pay9WebViewScreenState extends State<Pay9WebViewScreen> {
  var loadingPercentage = 0;
  bool isReceivedResult = false;
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) {
          setState(() {
            loadingPercentage = 0;
          });
        },
        onProgress: (progress) {
          loadingPercentage = progress;
        },
        onPageFinished: (url) {
          setState(() {
            loadingPercentage = 100;
          });
        },
        onWebResourceError: (WebResourceError error) {
          setState(() {
            isReceivedResult = true;
          });
        },
        onNavigationRequest: (NavigationRequest navigation) async {
          if (kDebugMode) {
            log("--->url ${navigation.url}");
          }

          if(navigation.url.startsWith('https://dev-car.citgroup.vn/deposit-results')) {
            setState(() {
              isReceivedResult = true;
            });
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(
        Uri.parse(widget.url),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: GestureDetector(
            onTap: () {
              if(isReceivedResult == true) {
                return Navigator.of(context).pop();
              }
              _showMyDialog();
            },
            child: const Icon(
              Icons.arrow_back,
            ),
          ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (loadingPercentage < 100)
            LinearProgressIndicator(
              value: loadingPercentage / 100.0,
            )
        ],
      ),
    );
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Payment'.tr),
          content: SingleChildScrollView(
            child: Text('Cancel Payment'.tr),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'cancel'.tr,
                style: const TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(
                'Continue'.tr,
                style: const TextStyle(color: Colors.green),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
