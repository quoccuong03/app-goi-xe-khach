// ignore_for_file: file_names, must_be_immutable, depend_on_referenced_packages

import 'dart:async';

import 'package:citgroupvn_car/constant/show_toast_dialog.dart';
import 'package:citgroupvn_car/controller/wallet_controller.dart';
import 'package:citgroupvn_car/themes/constant_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ViewBannerScreen extends StatefulWidget {
  final String initialURl;

  const ViewBannerScreen({
    Key? key,
    required this.initialURl,
  }) : super(key: key);

  @override
  State<ViewBannerScreen> createState() => _ViewBannerScreenState();
}

class _ViewBannerScreenState extends State<ViewBannerScreen> {
  WebViewController controller = WebViewController();

  @override
  void initState() {
    initController();
    super.initState();
  }

  initController() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
            ShowToastDialog.showLoader("Vui lòng đợi");
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            ShowToastDialog.closeLoader();
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest navigation) async {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialURl));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.back();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: ConstantColors.primary,
            centerTitle: false,
            leading: GestureDetector(
              onTap: () {
                Get.back();
              },
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            )),
        body: SafeArea(child: WebViewWidget(controller: controller)),
      ),
    );
  }
}
