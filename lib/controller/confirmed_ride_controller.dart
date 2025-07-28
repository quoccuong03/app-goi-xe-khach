import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:citgroupvn_car/constant/show_toast_dialog.dart';
import 'package:citgroupvn_car/model/ride_model.dart';
import 'package:citgroupvn_car/service/api.dart';
import 'package:citgroupvn_car/utils/Preferences.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ConfirmedRideController extends GetxController {
  var isLoading = true.obs;
  var rideList = <RideData>[].obs;

  @override
  void onInit() {
    getNewRide();
    super.onInit();
  }

  Future<dynamic> getNewRide() async {
    try {
      final response = await client.get(
          Uri.parse(
              "${API.confirmedRide}?id_user_app=${Preferences.getInt(Preferences.userId)}"),
          headers: API.header);

      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        isLoading.value = false;
        RideModel model = RideModel.fromJson(responseBody);
        rideList.value = model.data!;
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
        rideList.clear();
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
}
