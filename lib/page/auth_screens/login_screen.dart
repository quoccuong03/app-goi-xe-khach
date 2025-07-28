import 'dart:convert';

import 'package:citgroupvn_car/constant/show_toast_dialog.dart';
import 'package:citgroupvn_car/controller/login_conroller.dart';
import 'package:citgroupvn_car/controller/phone_number_controller.dart';
import 'package:citgroupvn_car/page/auth_screens/login_email_screen.dart';
import 'package:citgroupvn_car/page/auth_screens/mobile_number_screen.dart';
import 'package:citgroupvn_car/themes/button_them.dart';
import 'package:citgroupvn_car/themes/constant_colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);

  static final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();

  final controller = Get.put(LoginController());
  final phoneController = Get.put(PhoneNumberController());
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: ConstantColors.background,
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/login_bg.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.fitWidth,
                              image: AssetImage("assets/icons/logo.png"))),
                      width: 100,
                      height: 45,
                    ),
                    Text(
                      "ĐĂNG NHẬP".tr,
                      style: const TextStyle(
                          letterSpacing: 0.60,
                          fontSize: 22,
                          color: Colors.black,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                        width: 80,
                        child: Divider(
                          color: ConstantColors.primary,
                          thickness: 3,
                        )),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Form(
                        key: _loginFormKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      color:
                                          ConstantColors.textFieldBoarderColor,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(6))),
                                padding: const EdgeInsets.only(left: 10),
                                child: IntlPhoneField(
                                  onChanged: (phone) {
                                    phoneController.phoneNumber.value =
                                        phone.completeNumber;
                                  },
                                  initialCountryCode: 'VN',
                                  invalidNumberMessage: "number invalid",
                                  showDropdownIcon: false,
                                  disableLengthCheck: true,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    hintText: 'Nhập số điện thoại'.tr,
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(top: 50),
                                child: ButtonThem.buildButton(
                                  context,
                                  title: 'Continue'.tr,
                                  btnHeight: 50,
                                  btnColor: ConstantColors.primary,
                                  txtColor: Colors.white,
                                  onPress: () async {
                                    FocusScope.of(context).unfocus();
                                    if (phoneController
                                        .phoneNumber.value.isNotEmpty) {
                                      ShowToastDialog.showLoader(
                                          "Code sending".tr);
                                      phoneController.sendCode(
                                          phoneController.phoneNumber.value,
                                          false);
                                    }
                                  },
                                )),
                            GestureDetector(
                              onTap: () {
                                Get.to(
                                    MobileNumberScreen(
                                      isLogin: false,
                                      isForgotPassword: true,
                                    ),
                                    duration: const Duration(
                                        milliseconds:
                                            400), //duration of transitions, default 1 sec
                                    transition: Transition.rightToLeft);
                                // Get.to(ForgotPasswordScreen(),
                                //     duration: const Duration(
                                //         milliseconds:
                                //             400), //duration of transitions, default 1 sec
                                //     transition: Transition.rightToLeft);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Center(
                                  child: Text(
                                    "forgot".tr,
                                    style: TextStyle(
                                        color: ConstantColors.primary,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(top: 40),
                                child: ButtonThem.buildBorderButton(
                                  context,
                                  title: 'Đăng nhập bằng mật khẩu'.tr,
                                  btnHeight: 50,
                                  btnColor: Colors.white,
                                  txtColor: ConstantColors.primary,
                                  onPress: () {
                                    FocusScope.of(context).unfocus();

                                    Get.to(LoginEmailScreen(),
                                        duration: const Duration(
                                            milliseconds:
                                                400), //duration of transitions, default 1 sec
                                        transition: Transition.rightToLeft);
                                  },
                                  btnBorderColor: ConstantColors.primary,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/login_bg.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text.rich(
                textAlign: TextAlign.center,
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'You don’t have an account yet? '.tr,
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w500),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Get.to(MobileNumberScreen(isLogin: false),
                              duration: const Duration(
                                  milliseconds:
                                      400), //duration of transitions, default 1 sec
                              transition:
                                  Transition.rightToLeft); //transition effect);
                        },
                    ),
                    const TextSpan(
                      text: ' ',
                    ),
                    TextSpan(
                      text: 'SIGNUP'.tr,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ConstantColors.primary),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Get.to(
                              MobileNumberScreen(
                                isLogin: false,
                              ),
                              duration: const Duration(
                                  milliseconds:
                                      400), //duration of transitions, default 1 sec
                              transition:
                                  Transition.rightToLeft); //transition effect);
                        },
                    ),
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
