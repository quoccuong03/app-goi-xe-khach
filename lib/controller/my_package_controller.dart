import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:citgroupvn_car/constant/constant.dart';
import 'package:citgroupvn_car/constant/show_toast_dialog.dart';
import 'package:citgroupvn_car/model/package_data.dart';
import 'package:citgroupvn_car/model/user_model.dart';
import 'package:citgroupvn_car/service/api.dart';
import 'package:citgroupvn_car/utils/Preferences.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class MyPackageController extends GetxController {
  var isLoading = true.obs;
  var packageList = <PackageData>[].obs;

  @override
  void onInit() {
    getAllPackage();
    super.onInit();
  }

  UserModel? userModel;

  getUsrData() async {
    userModel = Constant.getUserData();
    try {
      Map<String, String> bodyParams = {
        'phone': userModel?.data?.phone != null
            ? userModel!.data!.phone!.toString()
            : "",
        'user_cat': "customer",
      };
      final response = await client.post(Uri.parse(API.getProfileByPhone),
          headers: API.header, body: jsonEncode(bodyParams));

      Map<String, dynamic> responseBody = json.decode(response.body);
      Preferences.setString(Preferences.user, jsonEncode(responseBody));
      userModel = Constant.getUserData();
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

  Future<dynamic> getAllPackage() async {
    try {
      final response =
          await client.get(Uri.parse(API.packages), headers: API.header);
      Map<String, dynamic> responseBody = json.decode(response.body);
      print('RESPONSEBODY: ${responseBody}');
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        PackageModel model = PackageModel.fromJson(responseBody);
        packageList.value = model.data!;
        await getUsrData();
        isLoading.value = false;
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
        packageList.clear();
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

  Future<dynamic> buyPackage(id) async {
    try {
      ShowToastDialog.showLoader("Vui lòng đợi".tr);
      Map<String, String> bodyParams = {
        'id_user': userModel?.data?.id ?? '',
        'user_cat': "customer",
        'package_id': id,
      };
      final response = await client.post(Uri.parse(API.buyPackages),
          headers: API.header, body: jsonEncode(bodyParams));
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        await getAllPackage();
        ShowToastDialog.showToast('Mua gói thành công');
        ShowToastDialog.closeLoader();
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(responseBody['message']);
      } else {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast('Đã có lỗi xảy ra vui lòng thử lại sau!');
      }
    } on TimeoutException catch (e) {
      log("->1${e.message}");
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      log("->2${e.message}");

      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      log("->3$e");

      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      log("->4$e");
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }
}
