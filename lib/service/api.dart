import 'dart:io';

import 'package:citgroupvn_car/page/auth_screens/login_screen.dart';
import 'package:citgroupvn_car/utils/Preferences.dart';
import 'package:get/get.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:http/http.dart' as http;

class API {
  static const baseUrl = "https://dev-car.citgroup.vn/api/v1/"; // live
  static const apiKey = "base64:VL1A5MHX88eRp+AmNwsWaXSol7Q/Cydj5PoJhijPCGc=";

  static Map<String, String> authheader = {
    HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
    'apikey': apiKey,
  };
  static Map<String, String> header = {
    HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
    'apikey': apiKey,
    'accesstoken': Preferences.getString(Preferences.accesstoken)
  };

  static const userSignUP = "${baseUrl}user";
  static const userLogin = "${baseUrl}user-login";
  static const sendResetPasswordOtp = "${baseUrl}reset-password-otp";
  static const resetPasswordOtp = "${baseUrl}resert-password-firbase-otp";
  static const getProfileByPhone = "${baseUrl}profilebyphone";
  static const getExistingUserOrNot = "${baseUrl}existing-user";
  static const updateUserNic = "${baseUrl}update-user-nic";
  static const uploadUserPhoto = "${baseUrl}user-photo";
  static const updateUserEmail = "${baseUrl}update-user-email";
  static const changePassword = "${baseUrl}update-user-mdp";
  static const updatePreName = "${baseUrl}user-pre-name";
  static const updateLastName = "${baseUrl}user-name";
  static const updateAddress = "${baseUrl}user-address";
  static const contactUs = "${baseUrl}contact-us";
  static const updateToken = "${baseUrl}update-fcm";
  static const favorite = "${baseUrl}favorite";
  static const rentVehicle = "${baseUrl}vehicle-get";
  static const transaction = "${baseUrl}transaction";
  static const wallet = "${baseUrl}wallet";
  static const amount = "${baseUrl}amount";
  static const getFcmToken = "${baseUrl}fcm-token";
  static const deleteFavouriteRide = "${baseUrl}delete-favorite-ride";
  static const rejectRide = "${baseUrl}set-rejected-requete";
  static const deposit = "${baseUrl}deposit";

  static const getRideReview = "${baseUrl}get-ride-review";
  static const taxi = "${baseUrl}taxi";
  static const userPendingPayment = "${baseUrl}user-pending-payment";
  static const setFavouriteRide = "${baseUrl}favorite-ride";
  static const getVehicleCategory = "${baseUrl}Vehicle-category";
  static const driverDetails = "${baseUrl}driver";
  static const getPaymentMethod = "${baseUrl}payment-method";
  static const bookRides = "${baseUrl}requete-register";
  static const userAllRides = "${baseUrl}user-all-rides";
  static const newRide = "${baseUrl}requete-userapp";
  static const confirmedRide = "${baseUrl}user-confirmation";
  static const onRide = "${baseUrl}user-ride";
  static const completedRide = "${baseUrl}user-complete";
  static const canceledRide = "${baseUrl}user-cancel";
  static const driverConfirmRide = "${baseUrl}driver-confirm";
  static const feelSafeAtDestination = "${baseUrl}feel-safe";
  static const sos = "${baseUrl}storesos";
  static const bookRide = "${baseUrl}set-Location";
  static const getRentedData = "${baseUrl}location";
  static const cancelRentedVehicle = "${baseUrl}canceled-location";
  static const paymentSetting = "${baseUrl}payment-settings";
  static const payRequestWallet = "${baseUrl}pay-requete-wallet";
  static const payRequestCash = "${baseUrl}payment-by-cash";
  static const payRequestTransaction = "${baseUrl}pay-requete";
  static const addReview = "${baseUrl}note";
  static const addComplaint = "${baseUrl}complaints";
  static const discountList = "${baseUrl}discount-list";
  static const rideDetails = "${baseUrl}ridedetails";
  static const getLanguage = "${baseUrl}language";
  static const deleteUser = "${baseUrl}user-delete?user_id=";
  static const settings = "${baseUrl}settings";
  static const privacyPolicy = "${baseUrl}privacy-policy";
  static const termsOfCondition = "${baseUrl}terms-of-condition";
  static const referralAmount = "${baseUrl}get-referral";
  static const packages = "${baseUrl}packages";
  static const buyPackages = "${baseUrl}buy-package";
  static const notifications = "${baseUrl}notification?user_id=";
  static const notificationDetail = "${baseUrl}notification/customer/";
  static const banners = "${baseUrl}banners";
  static const otherServices = "${baseUrl}other-services";
  static const foodProducts = "${baseUrl}products";
  static const stores = "${baseUrl}stores";
  static const updateCart = "${baseUrl}stores/cart/add";
  static const cart = "${baseUrl}carts";
  static const submitOrder = "${baseUrl}submit-order";
  static const listOrders = "${baseUrl}user/orders";
  static const detailOrder = "${baseUrl}orders/";
  static const deleteCard = "${baseUrl}carts/delete-cart";
  static const getLimitOtp = "${baseUrl}get-limit-reset-password";
  static const setLimitOtp = "${baseUrl}set-limit-reset-password";
}

class UnauthorizedInterceptor implements InterceptorContract {
  @override
  Future<RequestData> interceptRequest({required RequestData data}) async {
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({required ResponseData data}) async {
    if (data.statusCode == 401 && !data.url!.contains('wallet')) {
      print('DATA.URL: ${data.url}');
      Preferences.clearKeyData(Preferences.isLogin);
      Preferences.clearKeyData(Preferences.user);
      Preferences.clearKeyData(Preferences.userId);
      Get.offAll(LoginScreen());
    }
    return data;
  }
}

final http.Client client = InterceptedClient.build(
  interceptors: [UnauthorizedInterceptor()],
  requestTimeout: Duration(seconds: 5),
);
