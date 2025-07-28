// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:citgroupvn_car/constant/constant.dart';
import 'package:citgroupvn_car/constant/show_toast_dialog.dart';
import 'package:citgroupvn_car/model/driver_model.dart';
import 'package:citgroupvn_car/model/payment_method_model.dart';
import 'package:citgroupvn_car/model/taxi_model.dart';
import 'package:citgroupvn_car/model/vehicle_category_model.dart';
import 'package:citgroupvn_car/service/api.dart';
import 'package:citgroupvn_car/utils/Preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:get/get.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:http/http.dart' as http;

import '../model/payment_setting_model.dart';

class HomeController extends GetxController {
  //for Choose your Rider
  RxString selectPaymentMode = "Payment Method".obs;
  List<AddChildModel> addChildList = [
    AddChildModel(editingController: TextEditingController())
  ];
  List<AddStopModel> multiStopList = [];
  List<AddStopModel> multiStopListNew = [];

  RxString selectedVehicle = "".obs;
  late VehicleData? vehicleData;
  late PaymentMethodData? paymentMethodData;

  RxBool confirmWidgetVisible = false.obs;

  RxString tripOptionCategory = "General".obs;
  RxString paymentMethodType = "Select Method".obs;
  RxString paymentMethodId = "".obs;
  RxDouble distance = 0.0.obs;
  RxString duration = "".obs;

  var paymentSettingModel = PaymentSettingModel().obs;

  RxBool cash = false.obs;
  RxBool pay9 = false.obs;
  RxBool wallet = false.obs;
  // RxBool stripe = false.obs;
  // RxBool razorPay = false.obs;
  // RxBool payTm = false.obs;
  // RxBool paypal = false.obs;
  // RxBool payStack = false.obs;
  // RxBool flutterWave = false.obs;
  // RxBool mercadoPago = false.obs;
  // RxBool payFast = false.obs;

  @override
  void onInit() {
    getPaymentSettingData();

    super.onInit();
  }

  addStops() async {
    ShowToastDialog.showLoader("Vui lòng đợi");
    multiStopList.add(AddStopModel(
        editingController: TextEditingController(),
        latitude: "",
        longitude: ""));
    multiStopListNew = List<AddStopModel>.generate(
      multiStopList.length,
      (int index) => AddStopModel(
          editingController: multiStopList[index].editingController,
          latitude: multiStopList[index].latitude,
          longitude: multiStopList[index].longitude),
    );
    ShowToastDialog.closeLoader();
    update();
  }

  removeStops(int index) {
    ShowToastDialog.showLoader("Vui lòng đợi");
    multiStopList.removeAt(index);
    multiStopListNew = List<AddStopModel>.generate(
      multiStopList.length,
      (int index) => AddStopModel(
          editingController: multiStopList[index].editingController,
          latitude: multiStopList[index].latitude,
          longitude: multiStopList[index].longitude),
    );
    ShowToastDialog.closeLoader();
    update();
  }

  clearData() {
    selectedVehicle.value = "";
    selectPaymentMode.value = "Payment Method";
    tripOptionCategory = "General".obs;
    paymentMethodType = "Select Method".obs;
    paymentMethodId = "".obs;
    distance = 0.0.obs;
    duration = "".obs;
    multiStopList.clear();
    multiStopListNew.clear();
  }

  Future<TaxiModel?> getTaxiData() async {
    try {
      ShowToastDialog.showLoader("Vui lòng đợi");
      final response = await client.get(
          Uri.parse(
              "${API.taxi}?id_user_app=${Preferences.getInt(Preferences.userId)}"),
          headers: API.header);

      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        ShowToastDialog.closeLoader();
        return TaxiModel.fromJson(responseBody);
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

  // Future<dynamic> getDurationDistance(
  //     mapbox.LatLng departureLatLong, mapbox.LatLng destinationLatLong) async {
  //   ShowToastDialog.showLoader("Vui lòng đợi");
  //   double originLat, originLong, destLat, destLong;
  //   originLat = departureLatLong.latitude;
  //   originLong = departureLatLong.longitude;
  //   destLat = destinationLatLong.latitude;
  //   destLong = destinationLatLong.longitude;
  //
  //   String url = 'https://maps.googleapis.com/maps/api/distancematrix/json';
  //   http.Response restaurantToCustomerTime = await client.get(Uri.parse(
  //       '$url?units=metric&origins=$originLat,'
  //       '$originLong&destinations=$destLat,$destLong&key=${Constant.kGoogleApiKey}'));
  //
  //   var decodedResponse = jsonDecode(restaurantToCustomerTime.body);
  //   print("decodedResponse ${decodedResponse['error_message']}");
  //   if (decodedResponse['status'] == 'OK' &&
  //       decodedResponse['rows'].first['elements'].first['status'] == 'OK') {
  //     ShowToastDialog.closeLoader();
  //     return decodedResponse;
  //     //   estimatedTime = decodedResponse['rows'].first['elements'].first['distance']['value'] / 1000.00;
  //     //   if (selctedOrderTypeValue == "Delivery") {
  //     //     setState(() => deliveryCharges = (estimatedTime! * double.parse(deliveryCost)).toString());
  //     //   }
  //   }
  //   ShowToastDialog.closeLoader();
  //   return null;
  // }

  Future<dynamic> getPaymentSettingData() async {
    try {
      final response =
          await client.get(Uri.parse(API.paymentSetting), headers: API.header);

      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        Preferences.setString(
            Preferences.paymentSetting, jsonEncode(responseBody));
        paymentSettingModel.value = Constant.getPaymentSetting();
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

  Future<PlacesDetailsResponse?> placeSelectAPI(BuildContext context) async {
    // show input autocomplete with selected mode
    // then get the Prediction selected
    Prediction? p = await PlacesAutocomplete.show(
      context: context,
      apiKey: Constant.kGoogleApiKey,
      mode: Mode.overlay,
      onError: (response) {
        log("-->${response.status}");
      },
      language: 'fr',
      resultTextStyle: Theme.of(context).textTheme.titleMedium,
      types: [],
      strictbounds: false,
      components: [],
    );

    return displayPrediction(p);
  }

  Future<PlacesDetailsResponse?> displayPrediction(Prediction? p) async {
    if (p != null) {
      GoogleMapsPlaces? places = GoogleMapsPlaces(
        apiKey: Constant.kGoogleApiKey,
        apiHeaders: await const GoogleApiHeaders().getHeaders(),
      );
      try {
        PlacesDetailsResponse? detail =
            await places.getDetailsByPlaceId(p.placeId.toString());
        return detail;
      } catch (e) {
        log('error = $e');
      }
    }
    return null;
  }

  Future<dynamic> getUserPendingPayment() async {
    try {
      ShowToastDialog.showLoader("Vui lòng đợi");

      Map<String, dynamic> bodyParams = {
        'user_id': Preferences.getInt(Preferences.userId)
      };
      final response = await client.post(Uri.parse(API.userPendingPayment),
          headers: API.header, body: jsonEncode(bodyParams));

      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        ShowToastDialog.closeLoader();
        return responseBody;
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

  Future<VehicleCategoryModel?> getVehicleCategory() async {
    try {
      ShowToastDialog.showLoader("Vui lòng đợi");
      final response = await client.get(Uri.parse(API.getVehicleCategory),
          headers: API.header);
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        update();
        ShowToastDialog.closeLoader();
        return VehicleCategoryModel.fromJson(responseBody);
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

  Future<DriverModel?> getDriverDetails(
      String typeVehicle, String lat1, String lng1) async {
    try {
      ShowToastDialog.showLoader("Vui lòng đợi");
      final response = await client.get(
          Uri.parse(
              "${API.driverDetails}?type_vehicle=$typeVehicle&lat1=$lat1&lng1=$lng1"),
          headers: API.header);

      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        ShowToastDialog.closeLoader();
        return DriverModel.fromJson(responseBody);
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

  Future<PaymentMethodModel?> getPaymentMethod() async {
    try {
      ShowToastDialog.showLoader("Vui lòng đợi");
      final response = await client.get(Uri.parse(API.getPaymentMethod),
          headers: API.header);
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        ShowToastDialog.closeLoader();
        return PaymentMethodModel.fromJson(responseBody);
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

  //  if (km > deliveryChargeModel.minimum_delivery_charges_within_km) {
  //             deliveryCharges = (km * deliveryChargeModel.delivery_charges_per_km).toDouble().toStringAsFixed(decimal);
  //             setState(() {});
  //           } else {
  //             deliveryCharges = deliveryChargeModel.minimum_delivery_charges.toDouble().toStringAsFixed(decimal);
  //             setState(() {});
  //           }

  Future<dynamic> setFavouriteRide(Map<String, String> bodyParams) async {
    try {
      ShowToastDialog.showLoader("Vui lòng đợi");
      final response = await client.post(Uri.parse(API.setFavouriteRide),
          headers: API.header, body: jsonEncode(bodyParams));
      Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        ShowToastDialog.closeLoader();
        return responseBody;
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
  }

  Future<dynamic> bookRide(Map<String, dynamic> bodyParams) async {
    try {
      ShowToastDialog.showLoader("Vui lòng đợi");
      log('bodyParam = $bodyParams');
      final response = await client.post(Uri.parse(API.bookRides),
          headers: API.header, body: jsonEncode(bodyParams));

      Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        ShowToastDialog.closeLoader();
        return responseBody;
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

  double calculateTripPrice(
      {required double distance,
      required double minimumDeliveryChargesWithin,
      required double minimumDeliveryCharges,
      required double deliveryCharges}) {
    double cout = 0.0;

    if (distance > minimumDeliveryChargesWithin) {
      cout = (distance * deliveryCharges).toDouble();
    } else {
      cout = minimumDeliveryCharges;
    }
    return cout;
  }
}

class AddChildModel {
  TextEditingController editingController = TextEditingController();

  AddChildModel({required this.editingController});
}

class AddStopModel {
  String latitude = "";
  String longitude = "";
  TextEditingController editingController = TextEditingController();

  AddStopModel({
    required this.editingController,
    required this.latitude,
    required this.longitude,
  });
}
