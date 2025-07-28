import 'package:citgroupvn_car/lang/app_vi.dart';
import 'package:citgroupvn_car/lang/app_en.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocalizationService extends Translations {
  // Default locale
  static const locale = Locale('vi', 'VN');

  static final locales = [
    const Locale('en'),
    const Locale('vi'),
  ];

  // Keys and their translations
  // Translations are separated maps in `lang` file
  @override
  Map<String, Map<String, String>> get keys => {
        'en': enUS,
        'vi': viVN,
      };

  // Gets locale from language, and updates the locale
  void changeLocale(String lang) {
    Get.updateLocale(Locale(lang));
  }
}
