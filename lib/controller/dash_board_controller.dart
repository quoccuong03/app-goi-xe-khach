import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:citgroupvn_car/constant/constant.dart';
import 'package:citgroupvn_car/constant/show_toast_dialog.dart';
import 'package:citgroupvn_car/model/banners_data.dart';
import 'package:citgroupvn_car/model/other_service_data.dart';
import 'package:citgroupvn_car/model/user_model.dart';
import 'package:citgroupvn_car/page/auth_screens/login_screen.dart';
import 'package:citgroupvn_car/page/food_screen/carts_screen.dart';
import 'package:citgroupvn_car/page/contact_us/contact_us_screen.dart';
import 'package:citgroupvn_car/page/dash_board.dart';
import 'package:citgroupvn_car/page/food_screen/food_home_screen.dart';
import 'package:citgroupvn_car/page/food_screen/orders_history_screen.dart';
import 'package:citgroupvn_car/page/main_screen/main_screen.dart';
import 'package:citgroupvn_car/page/my_package_screen/my_package_screen.dart';
import 'package:citgroupvn_car/page/my_profile/my_profile_screen.dart';
import 'package:citgroupvn_car/page/new_ride_screens/new_ride_screen.dart';
import 'package:citgroupvn_car/page/privacy_policy/privacy_policy_screen.dart';
import 'package:citgroupvn_car/page/terms_service/terms_of_service_screen.dart';
import 'package:citgroupvn_car/page/wallet/wallet_screen.dart';
import 'package:citgroupvn_car/service/api.dart';
import 'package:citgroupvn_car/utils/Preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as get_cord_address;
import '../page/home_screens/home_screen.dart';

class DashBoardController extends GetxController {
  RxInt selectedDrawerIndex = 0.obs;
  var banners = <BannerData>[].obs;
  var otherServices = <OtherServiceData>[].obs;

  @override
  void onInit() {
    getUsrData();
    updateToken();
    getPaymentSettingData();
    getBanners();
    getOtherServices();
    getCurrentLocation(true);
    super.onInit();
  }

  UserModel? userModel;

  getUsrData() {
    userModel = Constant.getUserData();
  }

  updateToken() async {
    // use the returned token to send messages to users from your custom server
    String? token = await FirebaseMessaging.instance.getToken();

    if (token != null) {
      updateFCMToken(token);
    }
  }

  final drawerItems = [
    DrawerItem('home', CupertinoIcons.home),
    DrawerItem('book_driver', Icons.directions_car),
    DrawerItem('chauffeur_service', Icons.car_rental),
    DrawerItem('All Rides', Icons.local_car_wash),
    DrawerItem('orders_history', Icons.history),
    // DrawerItem('favorite_ride', CupertinoIcons.star),
    DrawerItem('my_package', Icons.wallet),
    // DrawerItem('on_ride', Icons.directions_boat_outlined),
    // DrawerItem("completed", Icons.incomplete_circle),
    // DrawerItem('canceled', Icons.cancel_outlined),
    // DrawerItem('rent_a_vehicle', Icons.car_rental),
    // DrawerItem('rented_vehicle', Icons.car_rental),
    // DrawerItem('promo_code', Icons.discount),
    DrawerItem('my_wallet', Icons.account_balance_wallet_outlined),
    DrawerItem('my_profile', Icons.person_outline),
    // DrawerItem('refer_a_friend', Icons.people_sharp),
    // DrawerItem('change_language', Icons.language),
    DrawerItem('term_service', Icons.design_services),
    DrawerItem('privacy_policy', Icons.privacy_tip),
    DrawerItem('contact_us', Icons.support_agent),
    // DrawerItem('rate_business', Icons.rate_review_outlined),
    DrawerItem('sign_out', Icons.logout),
    DrawerItem('book_car_driver', Icons.car_rental, isHide: true),
    DrawerItem('food', Icons.car_rental, isHide: true),
    DrawerItem('book_motorbike_driver', Icons.car_rental, isHide: true),
    DrawerItem('Đặt xe máy', Icons.motorcycle_outlined, isHide: true),
    DrawerItem('Đặt Oto', Icons.directions_car, isHide: true),
  ];

  getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        return MainScreens();
      case 1:
        return const HomeScreen(
          initHomeActionType: InitHomeActionType.bookVehicle,
        );
      case 2:
        return const HomeScreen(
          initHomeActionType: InitHomeActionType.bookDriver,
        );
      case 3:
        return const NewRideScreen();
      // case 4:
      //   return const FavoriteRideScreen();
      case 4:
        return const OrdersHistoryScreen();

      case 5:
        return MyPackageScreens();
      // case 4:
      //   return OnRideScreens();
      // case 5:
      //   return const CompletedRideScreen();
      // case 6:
      //   return const CanceledRideScreens();
      // case 5:
      //   return RentVehicleScreen();
      // case 6:
      //   return const RentedVehicleScreen();
      // case 6:
      //   return const CouponCodeScreen();
      case 6:
        return WalletScreen();
      case 7:
        return MyProfileScreen();
      // case 9:
      //   return const ReferralScreen();
      // case 10:
      //   return const LocalizationScreens(
      //     intentType: "dashBoard",
      //   );
      case 8:
        return const TermsOfServiceScreen();
      case 9:
        return const PrivacyPolicyScreen();
      case 10:
        return const ContactUsScreen();

      case 12:
        return const HomeScreen(
          initHomeActionType: InitHomeActionType.bookCarDriver,
        );
      case 13:
        return const FoodHomeScreens();

      case 14:
        return const HomeScreen(
          initHomeActionType: InitHomeActionType.bookMotorbikeDriver,
        );
      case 15:
        return const HomeScreen(
          initHomeActionType: InitHomeActionType.bookMotorbike,
        );
      case 16:
        return const HomeScreen(
          initHomeActionType: InitHomeActionType.bookCar,
        );

      default:
        return const Text("Error");
    }
  }

  onSelectItem(int index) {
    if (index == 11) {
      Preferences.clearKeyData(Preferences.isLogin);
      Preferences.clearKeyData(Preferences.user);
      Preferences.clearKeyData(Preferences.userId);
      Get.offAll(LoginScreen());
    } else {
      selectedDrawerIndex.value = index;
    }
    Get.back();
  }

  Future<dynamic> updateFCMToken(String token) async {
    try {
      Map<String, dynamic> bodyParams = {
        'user_id': Preferences.getInt(Preferences.userId),
        'fcm_id': token,
        'device_id': "",
        'user_cat': userModel!.data!.userCat
      };
      final response = await client.post(Uri.parse(API.updateToken),
          headers: API.header, body: jsonEncode(bodyParams));

      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        return responseBody;
      } else {
        ShowToastDialog.showToast('Đã có lỗi xảy ra vui lòng thử lại sau!');
        throw Exception('Đã có lỗi xảy ra vui lòng thử lại sau!');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  final Location currentLocation = Location();

  getCurrentLocation(bool isDepartureSet) async {
    if (isDepartureSet) {
      LocationData location = await currentLocation.getLocation();
      List<get_cord_address.Placemark> placeMarks =
          await get_cord_address.placemarkFromCoordinates(
              location.latitude ?? 0.0, location.longitude ?? 0.0);

      final address = (placeMarks.first.subLocality!.isEmpty
              ? ''
              : "${placeMarks.first.subLocality}, ") +
          (placeMarks.first.street!.isEmpty
              ? ''
              : "${placeMarks.first.street}, ") +
          (placeMarks.first.name!.isEmpty ? '' : "${placeMarks.first.name}, ") +
          (placeMarks.first.subAdministrativeArea!.isEmpty
              ? ''
              : "${placeMarks.first.subAdministrativeArea}, ") +
          (placeMarks.first.administrativeArea!.isEmpty
              ? ''
              : "${placeMarks.first.administrativeArea}, ") +
          (placeMarks.first.country!.isEmpty
              ? ''
              : "${placeMarks.first.country}, ") +
          (placeMarks.first.postalCode!.isEmpty
              ? ''
              : "${placeMarks.first.postalCode}, ");
      departureController.text = address;
    }
  }

  Future<dynamic> getPaymentSettingData() async {
    try {
      final response =
          await client.get(Uri.parse(API.paymentSetting), headers: API.header);

      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        Preferences.setString(
            Preferences.paymentSetting, jsonEncode(responseBody));
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
      } else {
        ShowToastDialog.showToast('Đã có lỗi xảy ra vui lòng thử lại sau!');
        throw Exception('Đã có lỗi xảy ra vui lòng thử lại sau!');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  Future<dynamic> getBanners() async {
    try {
      final response =
          await client.get(Uri.parse(API.banners), headers: API.header);

      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "Success") {
        BannerModel model = BannerModel.fromJson(responseBody);
        print('MODEL: ${model}');
        banners.value = model.data!;
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
      } else {
        ShowToastDialog.showToast('Đã có lỗi xảy ra vui lòng thử lại sau!');
        throw Exception('Đã có lỗi xảy ra vui lòng thử lại sau!');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  Future<dynamic> getOtherServices() async {
    try {
      final response =
          await client.get(Uri.parse(API.otherServices), headers: API.header);
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "Success") {
        OtherServicesModel model = OtherServicesModel.fromJson(responseBody);
        print('MODEL: ${model}');
        otherServices.value = model.data;
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
      } else {
        ShowToastDialog.showToast('Đã có lỗi xảy ra vui lòng thử lại sau!');
        throw Exception('Đã có lỗi xảy ra vui lòng thử lại sau!');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }
}
