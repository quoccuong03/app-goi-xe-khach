import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:citgroupvn_car/constant/show_toast_dialog.dart';
import 'package:citgroupvn_car/model/rented_vehicle_model.dart';
import 'package:citgroupvn_car/service/api.dart';
import 'package:citgroupvn_car/utils/Preferences.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class RentedVehicleController extends GetxController {
  var isLoading = true.obs;
  var rentedVehicleData = <RentedVehicleData>[].obs;

  @override
  void onInit() {
    getRentedData();
    super.onInit();
  }

  Future<dynamic> getRentedData() async {
    try {
      final response = await client.get(
          Uri.parse(
              "${API.getRentedData}?id_user_app=${Preferences.getInt(Preferences.userId)}"),
          headers: API.header);
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        isLoading.value = false;
        RentedVehicleModel model = RentedVehicleModel.fromJson(responseBody);
        rentedVehicleData.value = model.data!;
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
        rentedVehicleData.clear();
        isLoading.value = false;
      } else {
        isLoading.value = false;
        ShowToastDialog.showToast('Đã có lỗi xảy ra vui lòng thử lại sau!');
        throw Exception('Đã có lỗi xảy ra vui lòng thử lại sau!');
      }
    } on TimeoutException catch (e) {
      isLoading.value = false;
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      isLoading.value = false;
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      isLoading.value = false;
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  Future<dynamic> cancelBooking(Map<String, dynamic> bodyParams) async {
    try {
      ShowToastDialog.showLoader("Vui lòng đợi");
      final response = await client.post(Uri.parse(API.cancelRentedVehicle),
          headers: API.header, body: jsonEncode(bodyParams));

      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "Success") {
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
}
