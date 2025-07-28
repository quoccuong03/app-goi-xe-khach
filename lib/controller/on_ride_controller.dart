import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:citgroupvn_car/constant/constant.dart';
import 'package:citgroupvn_car/constant/show_toast_dialog.dart';
import 'package:citgroupvn_car/model/ride_model.dart';
import 'package:citgroupvn_car/model/user_model.dart';
import 'package:citgroupvn_car/service/api.dart';
import 'package:citgroupvn_car/utils/Preferences.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class OnRideController extends GetxController {
  var isLoading = true.obs;
  var rideList = <RideData>[].obs;

  @override
  void onInit() {
    getOnRide();
    getUsrData();
    super.onInit();
  }

  UserModel? userModel;

  getUsrData() {
    userModel = Constant.getUserData();
  }

  Future<dynamic> getOnRide() async {
    try {
      final response = await client.get(
          Uri.parse(
              "${API.onRide}?id_user_app=${Preferences.getInt(Preferences.userId)}"),
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
      log("->1${e.message}");
      isLoading.value = false;
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      log("->2${e.message}");

      isLoading.value = false;
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      log("->3$e");

      isLoading.value = false;
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      log("->4$e");
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }
}
