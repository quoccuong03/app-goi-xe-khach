import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:citgroupvn_car/constant/constant.dart';
import 'package:citgroupvn_car/constant/show_toast_dialog.dart';
import 'package:citgroupvn_car/model/notification_data.dart';
import 'package:citgroupvn_car/model/user_model.dart';
import 'package:citgroupvn_car/service/api.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class NotificationController extends GetxController {
  var isLoading = true.obs;
  var notificationList = <NotificationData>[].obs;
  var dataNotification = NotificationData(
          id: '2',
          titre: 'Title 2',
          message: 'Message 2',
          creer: '2024-06-09 19:09:24')
      .obs;
  UserModel? userModel;
  @override
  void onInit() {
    getAllNotification();
    super.onInit();
  }

  Future<dynamic> resetLoading() async {
    isLoading.value = true;
  }

  Future<dynamic> getAllNotification() async {
    try {
      isLoading.value = true;
      userModel = Constant.getUserData();
      final response = await client.get(
          Uri.parse('${API.notifications}${userModel!.data!.id}'),
          headers: API.header);
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        NotificationModel model = NotificationModel.fromJson(responseBody);
        notificationList.value = model.data!;
        isLoading.value = false;
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
        notificationList.clear();
        isLoading.value = false;
      } else {
        isLoading.value = false;
        ShowToastDialog.showToast('Đã có lỗi xảy ra vui lòng thử lại sau!');
      }

      isLoading.value = false;
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

  Future<dynamic> getNotificationById(id) async {
    try {
      userModel = Constant.getUserData();
      final response = await client.get(
          Uri.parse('${API.notificationDetail}$id/detail'),
          headers: API.header);
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        NotificationData model =
            NotificationData.fromJson(responseBody['data']);
        dataNotification.value = model;
        isLoading.value = false;
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
        notificationList.clear();
        isLoading.value = false;
      } else {
        isLoading.value = false;
        ShowToastDialog.showToast('Đã có lỗi xảy ra vui lòng thử lại sau!');
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
