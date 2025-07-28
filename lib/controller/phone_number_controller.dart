import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:citgroupvn_car/constant/show_toast_dialog.dart';
import 'package:citgroupvn_car/model/user_model.dart';
import 'package:citgroupvn_car/page/auth_screens/forgot_password_otp_screen.dart';
import 'package:citgroupvn_car/page/auth_screens/otp_screen.dart';
import 'package:citgroupvn_car/service/api.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class PhoneNumberController extends GetxController {
  RxString phoneNumber = "".obs;

  sendCode(String phoneNumber, isForgotPassword) async {
    final isLimmit = await checkLimitOtp();
    if (!isLimmit) {
      await FirebaseAuth.instance
          .verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          print('asdasdasdasdasd: ${e}');
          ShowToastDialog.closeLoader();
          if (e.code == 'invalid-phone-number') {
            ShowToastDialog.showToast("Số điện thoại không hợp lệ.");
          } else if (e.code == 'too-many-requests') {
            ShowToastDialog.showToast("Vui lòng thử lại sau.");
          } else {
            ShowToastDialog.showToast(e.code.toString());
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          ShowToastDialog.closeLoader();
          setLimitOtp();
          Get.to(OtpScreen(
              phoneNumber: phoneNumber,
              verificationId: verificationId,
              isForgotPassword: isForgotPassword));
          // }
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      )
          .catchError((error) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(
            "Bạn đã gửi OTP quá nhiều lần. Vui lòng thử lại sau");
      });
    } else {
      ShowToastDialog.showToast(
          'Thiết bị của bạn đã nhận quá số OTP. Vui lòng thử lại sau!');
    }

    // await FirebaseAuth.instance.verifyPasswordResetCode(code)
  }

  Future<bool?> phoneNumberIsExit(Map<String, String> bodyParams) async {
    try {
      ShowToastDialog.showLoader("Vui lòng đợi");
      final response = await client.post(Uri.parse(API.getExistingUserOrNot),
          headers: API.authheader, body: jsonEncode(bodyParams));

      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        ShowToastDialog.closeLoader();
        if (responseBody['data'] == true) {
          return true;
        } else {
          return false;
        }
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

  Future<bool> checkLimitOtp() async {
    bool isLimit = false;

    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      String deviceId = '';
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? '';
      }
      var bodyParams = {'device_id': deviceId, 'user_cat': 'user_app'};
      final response = await client.post(Uri.parse(API.getLimitOtp),
          headers: API.authheader, body: jsonEncode(bodyParams));

      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        if (responseBody['data']['limit'] <= 0) {
          isLimit = true;
        }
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
      } else {
        ShowToastDialog.closeLoader();
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
    return isLimit;
  }

  Future<bool> setLimitOtp() async {
    bool isLimit = false;

    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      String deviceId = '';
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? '';
      }
      var bodyParams = {'device_id': deviceId, 'user_cat': 'user_app'};
      final response = await client.post(Uri.parse(API.setLimitOtp),
          headers: API.authheader, body: jsonEncode(bodyParams));

      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        if (responseBody['data']['limit'] <= 0) {
          isLimit = true;
        }
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
      } else {
        ShowToastDialog.closeLoader();
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
    return isLimit;
  }

  Future<UserModel?> getDataByPhoneNumber(
      Map<String, String> bodyParams) async {
    try {
      ShowToastDialog.showLoader("Vui lòng đợi");
      final response = await client.post(Uri.parse(API.getProfileByPhone),
          headers: API.header, body: jsonEncode(bodyParams));

      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        ShowToastDialog.closeLoader();
        return UserModel.fromJson(responseBody);
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
