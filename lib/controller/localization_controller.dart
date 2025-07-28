import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:citgroupvn_car/constant/show_toast_dialog.dart';
import 'package:citgroupvn_car/service/api.dart';
import 'package:citgroupvn_car/utils/Preferences.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../model/language_model.dart';

class LocalizationController extends GetxController {
  var languageList = <LanguageData>[].obs;
  RxString selectedLanguage = "vn".obs;

  @override
  void onInit() {
    if (Preferences.getString(Preferences.languageCodeKey)
        .toString()
        .isNotEmpty) {
      selectedLanguage(
          Preferences.getString(Preferences.languageCodeKey).toString());
    }
    // getLanguage();
    loadData();
    super.onInit();
  }

  void loadData() async {
    // final response = await rootBundle.loadString("assets/file/language.json");
    // final decodeData = jsonDecode(response);
    // var productData = decodeData["data"];
    // languageList.value = List.from(productData).map<Data>((item) => Data.fromJson(item)).toList();
    await getLanguage().then((value) {
      if (value!.success == 'Success') {
        languageList
            .addAll(value.data!.where((element) => element.status == 'true'));
      }
    });
  }

  Future<LanguageModel?> getLanguage() async {
    try {
      ShowToastDialog.showLoader("Vui lòng đợi");
      final response = await client.get(
        Uri.parse(API.getLanguage),
        headers: API.authheader,
      );

      Map<String, dynamic> responseBody = json.decode(response.body);
      print('RESPONSEBODY: ${responseBody}');

      if (response.statusCode == 200 && responseBody['success'] == "Success") {
        ShowToastDialog.closeLoader();

        return LanguageModel.fromJson(responseBody);
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
