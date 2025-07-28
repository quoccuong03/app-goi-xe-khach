import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:citgroupvn_car/constant/show_toast_dialog.dart';
import 'package:citgroupvn_car/model/ride_model.dart';
import 'package:citgroupvn_car/service/api.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AddComplaintController extends GetxController {
  @override
  void onInit() {
    getArgument();

    super.onInit();
  }

  var data = RideData().obs;

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      data.value = argumentData["rideData"];
    }
    update();
  }

  Future<bool?> addComplaint(Map<String, String> bodyParams) async {
    try {
      ShowToastDialog.showLoader("Vui lòng đợi");
      final response = await client.post(Uri.parse(API.addComplaint),
          headers: API.header, body: jsonEncode(bodyParams));
      Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == "success") {
        ShowToastDialog.closeLoader();
        return true;
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(responseBody['error']);
      } else {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast('Đã có lỗi xảy ra vui lòng thử lại sau!');
        throw Exception('Đã có lỗi xảy ra vui lòng thử lại sau!');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }
}
