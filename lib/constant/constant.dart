// ignore_for_file: deprecated_member_use, non_constant_identifier_names, body_might_complete_normally_catch_error

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:citgroupvn_car/constant/show_toast_dialog.dart';
import 'package:citgroupvn_car/controller/dash_board_controller.dart';
import 'package:citgroupvn_car/model/payment_setting_model.dart';
import 'package:citgroupvn_car/model/tax_model.dart';
import 'package:citgroupvn_car/model/user_model.dart';
import 'package:citgroupvn_car/page/chats_screen/conversation_screen.dart';
import 'package:citgroupvn_car/service/api.dart';
import 'package:citgroupvn_car/themes/button_them.dart';
import 'package:citgroupvn_car/themes/constant_colors.dart';
import 'package:citgroupvn_car/utils/Preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class Constant {
  static String? kGoogleApiKey = "AIzaSyDDDini42y-kiFcCeNA1CefFm943ie5ZIA";
  static String? goongApiKey = "B1p8P0TS54bb2NnW7NWrPZZGbREPGrGyUmaZKNqB";
  static const mapBoxAccessToken =
      "pk.eyJ1IjoiZGV2dGVhbTIwMjQiLCJhIjoiY2x2ZjVhZTlyMGdjYTJqb3p0ZnZ5dWdzZCJ9.DaStkcd0xkxfMojAcnAm2w";
  static String? distanceUnit = "KM";
  static String? appVersion = "0.0";
  static String? decimal = "0";
  static String? currency = "đ";
  static String? driverRadius = "0";
  static bool symbolAtRight = true;
  static List<TaxModel> taxList = [];
  static String mapType = "google";
  static String driverLocationUpdate = "10";
  static double defaultZoomMap = 17;

  // static String? taxValue = "0";
  // static String? taxType = 'Percentage';
  // static String? taxName = 'Tax';
  static String? contactUsEmail = "",
      contactUsAddress = "",
      contactUsPhone = "";
  static String? rideOtp = "yes";

  static String stripePublishablekey =
      "pk_test_51Kaaj9SE3HQdbrEJneDaJ2aqIyX1SBpYhtcMKfwchyohSZGp53F75LojfdGTNDUwsDV5p6x5BnbATcrerModlHWa00WWm5Yf5h";

  static CollectionReference conversation =
      FirebaseFirestore.instance.collection('conversation');
  static CollectionReference location_update =
      FirebaseFirestore.instance.collection('ride_location_update');

  static String getUuid() {
    var uuid = const Uuid();
    return uuid.v1();
  }

  static UserModel getUserData() {
    final String user = Preferences.getString(Preferences.user);
    Map<String, dynamic> userMap = jsonDecode(user);
    return UserModel.fromJson(userMap);
  }

  static PaymentSettingModel getPaymentSetting() {
    final String user = Preferences.getString(Preferences.paymentSetting);
    if (user.isNotEmpty) {
      Map<String, dynamic> userMap = jsonDecode(user);
      return PaymentSettingModel.fromJson(userMap);
    }
    return PaymentSettingModel();
  }

  String getDestinationText(String? destination) {
    if(destination == null || destination == "null") {
      return "Chưa cập nhật vị trí";
    } else {
      return destination;
    }
  }

  String formatDate(String dateStr) {
    try {
      var dateFormat = DateFormat("dd MMM, yyyy");
      var date = dateFormat.parse(dateStr);
      return DateFormat("dd/MM/yyyy").format(date);
    } catch(e) {
      return "";
    }
  }

  String amountShow({required String? amount, showPrefix = false}) {
    double doubleAmount = 0;
    if (amount != null && amount.isNotEmpty && amount.toString() != "null") {
      doubleAmount = double.parse(amount.toString());
    }
    var startCharacter =
        showPrefix ? _getStartCharacterAmount(doubleAmount) : '';
    var formatAmount = _formatAmount(doubleAmount);
    return (Constant.symbolAtRight == true)
        ? startCharacter + formatAmount
        : Constant.currency.toString() + startCharacter + formatAmount;
  }

  String _getStartCharacterAmount(double doubleAmount) {
    if (doubleAmount > 0) {
      return '+';
    } else {
      return '';
    }
  }

  bool isNegativeAmount(String? amount) {
    if (amount != null && amount.isNotEmpty && amount.toString() != "null") {
      var doubleAmount = double.parse(amount.toString());
      if (doubleAmount < 0) return true;
    }
    return false;
  }

  String _formatAmount(double amount) {
    return NumberFormat.currency(
            locale: 'vi_VN',
            symbol: Constant.symbolAtRight == true
                ? Constant.currency.toString()
                : '')
        .format(amount);
  }

  static Widget emptyView(BuildContext context, String msg, bool isButtonShow) {
    final controllerDashBoard = Get.put(DashBoardController());
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Image.asset('assets/images/empty_placeholde.png'),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 150),
          child: Text(
            msg,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        Visibility(
          visible: isButtonShow,
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: ButtonThem.buildButton(
              context,
              title: 'Book Now'.tr,
              btnHeight: 45,
              btnWidthRatio: 0.8,
              btnColor: ConstantColors.primary,
              txtColor: Colors.white,
              onPress: () async {
                controllerDashBoard.onSelectItem(0);
              },
            ),
          ),
        )
      ],
    );
  }

  static Widget loader() {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: Center(
        child: CircularProgressIndicator(color: ConstantColors.primary),
      ),
    );
  }

  static Widget empty() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Center(
        child: Icon(
          Icons.hourglass_disabled_outlined,
          color: ConstantColors.dividerColor,
          size: 50,
        ),
      ),
    );
  }

  static Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  static Future<void> launchMapURl(
      String? latitude, String? longLatitude) async {
    String appleUrl =
        'https://maps.apple.com/?saddr=&daddr=$latitude,$longLatitude&directionsmode=driving';
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longLatitude';

    if (Platform.isIOS) {
      if (await canLaunch(appleUrl)) {
        await launch(appleUrl);
      } else {
        if (await canLaunch(googleUrl)) {
          await launch(googleUrl);
        } else {
          throw 'Could not open the map.';
        }
      }
    }
  }

  static Future<Url> uploadChatImageToFireStorage(File image) async {
    ShowToastDialog.showLoader('Uploading image...');
    var uniqueID = const Uuid().v4();
    Reference upload =
        FirebaseStorage.instance.ref().child('images/$uniqueID.png');

    File compressedImage = await compressImage(image);
    UploadTask uploadTask = upload.putFile(compressedImage);

    uploadTask.snapshotEvents.listen((event) {
      ShowToastDialog.showLoader(
          'Uploading image ${(event.bytesTransferred.toDouble() / 1000).toStringAsFixed(2)} /'
          '${(event.totalBytes.toDouble() / 1000).toStringAsFixed(2)} '
          'KB');
    });
    uploadTask.whenComplete(() {}).catchError((onError) {
      ShowToastDialog.closeLoader();
      log(onError.message);
    });
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    var metaData = await storageRef.getMetadata();
    ShowToastDialog.closeLoader();
    return Url(
        mime: metaData.contentType ?? 'image', url: downloadUrl.toString());
  }

  static Future<File> compressImage(File file) async {
    File compressedImage = await FlutterNativeImage.compressImage(
      file.path,
      quality: 25,
    );
    return compressedImage;
  }

  static Future<ChatVideoContainer> uploadChatVideoToFireStorage(
      File video) async {
    ShowToastDialog.showLoader('Uploading video');
    var uniqueID = const Uuid().v4();
    Reference upload =
        FirebaseStorage.instance.ref().child('videos/$uniqueID.mp4');
    File compressedVideo = await _compressVideo(video);
    SettableMetadata metadata = SettableMetadata(contentType: 'video');
    UploadTask uploadTask = upload.putFile(compressedVideo, metadata);
    uploadTask.snapshotEvents.listen((event) {
      ShowToastDialog.showLoader(
          'Uploading video ${(event.bytesTransferred.toDouble() / 1000).toStringAsFixed(2)} /'
          '${(event.totalBytes.toDouble() / 1000).toStringAsFixed(2)} '
          'KB');
    });
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    var metaData = await storageRef.getMetadata();
    final uint8list = await VideoThumbnail.thumbnailFile(
        video: downloadUrl,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.PNG);
    final file = File(uint8list ?? '');
    String thumbnailDownloadUrl = await uploadVideoThumbnailToFireStorage(file);
    ShowToastDialog.closeLoader();
    return ChatVideoContainer(
        videoUrl: Url(
            url: downloadUrl.toString(), mime: metaData.contentType ?? 'video'),
        thumbnailUrl: thumbnailDownloadUrl);
  }

  static Future<File> _compressVideo(File file) async {
    MediaInfo? info = await VideoCompress.compressVideo(file.path,
        quality: VideoQuality.DefaultQuality,
        deleteOrigin: false,
        includeAudio: true,
        frameRate: 24);
    if (info != null) {
      File compressedVideo = File(info.path!);
      return compressedVideo;
    } else {
      return file;
    }
  }

  static Future<String> uploadVideoThumbnailToFireStorage(File file) async {
    var uniqueID = const Uuid().v4();
    Reference upload =
        FirebaseStorage.instance.ref().child('thumbnails/$uniqueID.png');
    File compressedImage = await compressImage(file);
    UploadTask uploadTask = upload.putFile(compressedImage);
    var downloadUrl =
        await (await uploadTask.whenComplete(() {})).ref.getDownloadURL();
    return downloadUrl.toString();
  }

  static redirectMap(
      {required String name,
      required double latitude,
      required double longLatitude}) async {
    if (Constant.mapType == "google") {
      bool? isAvailable = await MapLauncher.isMapAvailable(MapType.google);
      if (isAvailable == true) {
        await MapLauncher.showDirections(
          mapType: MapType.google,
          directionsMode: DirectionsMode.driving,
          destinationTitle: name,
          destination: Coords(latitude, longLatitude),
        );
      } else {
        ShowToastDialog.showToast("Google map is not installed");
      }
    } else if (Constant.mapType == "googleGo") {
      bool? isAvailable = await MapLauncher.isMapAvailable(MapType.googleGo);
      if (isAvailable == true) {
        await MapLauncher.showDirections(
          mapType: MapType.googleGo,
          directionsMode: DirectionsMode.driving,
          destinationTitle: name,
          destination: Coords(latitude, longLatitude),
        );
      } else {
        ShowToastDialog.showToast("Google Go map is not installed");
      }
    } else if (Constant.mapType == "waze") {
      bool? isAvailable = await MapLauncher.isMapAvailable(MapType.waze);
      if (isAvailable == true) {
        await MapLauncher.showDirections(
          mapType: MapType.waze,
          directionsMode: DirectionsMode.driving,
          destinationTitle: name,
          destination: Coords(latitude, longLatitude),
        );
      } else {
        ShowToastDialog.showToast("Waze is not installed");
      }
    } else if (Constant.mapType == "mapswithme") {
      bool? isAvailable = await MapLauncher.isMapAvailable(MapType.mapswithme);
      if (isAvailable == true) {
        await MapLauncher.showDirections(
          mapType: MapType.mapswithme,
          directionsMode: DirectionsMode.driving,
          destinationTitle: name,
          destination: Coords(latitude, longLatitude),
        );
      } else {
        ShowToastDialog.showToast("Mapswithme is not installed");
      }
    } else if (Constant.mapType == "yandexNavi") {
      bool? isAvailable = await MapLauncher.isMapAvailable(MapType.yandexNavi);
      if (isAvailable == true) {
        await MapLauncher.showDirections(
          mapType: MapType.yandexNavi,
          directionsMode: DirectionsMode.driving,
          destinationTitle: name,
          destination: Coords(latitude, longLatitude),
        );
      } else {
        ShowToastDialog.showToast("YandexNavi is not installed");
      }
    } else if (Constant.mapType == "yandexMaps") {
      bool? isAvailable = await MapLauncher.isMapAvailable(MapType.yandexMaps);
      if (isAvailable == true) {
        await MapLauncher.showDirections(
          mapType: MapType.yandexMaps,
          directionsMode: DirectionsMode.driving,
          destinationTitle: name,
          destination: Coords(latitude, longLatitude),
        );
      } else {
        ShowToastDialog.showToast("yandexMaps map is not installed");
      }
    }
  }
}

List<List<LatLng>> calculateRoutes(
    LatLng startPoint, LatLng endPoint, List<LatLng> listStopPoint) {
  log('listStopPoint = $listStopPoint');
  List<List<LatLng>> listRoutes = [];

  var startRoutePoint = startPoint;
  try {
    while (listStopPoint.isNotEmpty) {
      var listDistance = listStopPoint
          .map((point) => calculateDistance(startRoutePoint, point))
          .toList();
      var minDistance = findMinValue(listDistance);
      var nearestIndex = listDistance.indexOf(minDistance);
      if (nearestIndex >= 0) {
        var nearestPoint = listStopPoint.elementAt(nearestIndex);
        listRoutes.add([startPoint, nearestPoint]);
        listStopPoint.removeAt(nearestIndex);
        startRoutePoint = nearestPoint;
      }
    }
  } catch (e) {
    log('error = $e');
    return [
      [startPoint, endPoint]
    ];
  }
  listRoutes.add([startRoutePoint, endPoint]);
  return listRoutes;
}

double findMinValue(List<double> numbers) {
  if (numbers.isEmpty) {
    throw ArgumentError('List is null');
  }

  double minValue = numbers[0];

  for (int i = 1; i < numbers.length; i++) {
    if (numbers[i] < minValue) {
      minValue = numbers[i];
    }
  }

  return minValue;
}

Future<RouteInfo> getRouteInfos(
    LatLng startPoint, LatLng endPoint, List<LatLng> listStopPoints) async {
  double totalDistance = 0.0;
  double totalDuration = 0.0;
  List<LatLng> totalCoordinates = [];
  try {
    var routes = calculateRoutes(startPoint, endPoint, listStopPoints);
    for (var routeElement in routes) {
      final url = Uri.parse('https://rsapi.goong.io/Direction?'
          'origin=${routeElement[0].latitude},${routeElement[0].longitude}'
          '&destination=${routeElement[1].latitude},${routeElement[1].longitude}'
          '&vehicle=bike&api_key=${Constant.goongApiKey}');

      var response = await client.get(url);

      final jsonResponse = jsonDecode(response.body);
      var route = jsonResponse['routes'][0]['overview_polyline']['points'];
      var duration = jsonResponse['routes'][0]['legs'][0]['duration']['value'];
      var distance = jsonResponse['routes'][0]['legs'][0]['distance']['value'];

      if (duration != null && distance != null) {
        totalDuration += duration;
        totalDistance += distance;
      }
      List<PointLatLng> result = PolylinePoints().decodePolyline(route);
      List<LatLng> coordinates = result
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
      totalCoordinates += coordinates;
    }
    return RouteInfo(
        distance: totalDistance,
        duration: totalDuration,
        polylinePoints: totalCoordinates);
  } catch (e) {
    log('error = $e');
    return const RouteInfo(polylinePoints: []);
  }
}

class RouteInfo {
  const RouteInfo({this.distance, this.duration, required this.polylinePoints});

  final double? distance;
  final double? duration;
  final List<LatLng> polylinePoints;
}

double calculateDistance(LatLng position1, LatLng position2) {
  return Geolocator.distanceBetween(
    position1.latitude,
    position1.longitude,
    position2.latitude,
    position2.longitude,
  );
}

class Url {
  String mime;

  String url;

  Url({this.mime = '', this.url = ''});

  factory Url.fromJson(Map<dynamic, dynamic> parsedJson) {
    return Url(mime: parsedJson['mime'] ?? '', url: parsedJson['url'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'mime': mime, 'url': url};
  }
}
