import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:citgroupvn_car/constant/constant.dart';
import 'package:citgroupvn_car/constant/show_toast_dialog.dart';
import 'package:citgroupvn_car/model/user_model.dart';
import 'package:citgroupvn_car/service/api.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class RideDetailsController extends GetxController {
  @override
  void onInit() {
    getUsrData();
    super.onInit();
  }

  UserModel? userModel;

  getUsrData() {
    userModel = Constant.getUserData();
  }

  Future<dynamic> feelNotSafe(Map<String, dynamic> bodyParams) async {
    try {
      ShowToastDialog.showLoader("Vui lòng đợi");
      final response = await client.post(Uri.parse(API.feelSafeAtDestination),
          headers: API.header, body: jsonEncode(bodyParams));
      log('#feelNotSafe: body = ${response.body}');
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (responseBody['success'] == 'success') {
        ShowToastDialog.closeLoader();
        return responseBody;
      } else {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(responseBody['error'].toString().tr);
        // throw Exception('Đã có lỗi xảy ra vui lòng thử lại sau!');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString().tr);
    } on SocketException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString().tr);
    } on Error catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString().tr);
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString().tr);
    }
    return null;
  }

  Future<dynamic> canceledRide(Map<String, String> bodyParams) async {
    try {
      ShowToastDialog.showLoader("Vui lòng đợi");
      final response = await client.post(Uri.parse(API.rejectRide),
          headers: API.header, body: jsonEncode(bodyParams));

      Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == "success") {
        ShowToastDialog.closeLoader();
        return responseBody;
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
    }
    ShowToastDialog.closeLoader();
    return null;
  }

  Future<dynamic> setConformRequest(Map<String, dynamic> bodyParams) async {
    try {
      ShowToastDialog.showLoader("Vui lòng đợi");
      final response = await client.post(Uri.parse(API.driverConfirmRide),
          headers: API.header, body: jsonEncode(bodyParams));

      Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == "success") {
        ShowToastDialog.closeLoader();
        return responseBody;
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "failed") {
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
    }
    ShowToastDialog.closeLoader();
    return null;
  }

  Future<dynamic> sos(Map<String, dynamic> bodyParams) async {
    try {
      ShowToastDialog.showLoader("Vui lòng đợi");
      final response = await client.post(Uri.parse(API.sos),
          headers: API.header, body: jsonEncode(bodyParams));

      Map<String, dynamic> responseBody = json.decode(response.body);
      if (responseBody['success'] == "success") {
        ShowToastDialog.closeLoader();
        return responseBody;
      } else {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(responseBody['error'].toString().tr);
        // throw Exception('Đã có lỗi xảy ra vui lòng thử lại sau!');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString().tr);
    } on SocketException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString().tr);
    } on Error catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString().tr);
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString().tr);
    }
    return null;
  }
}
