import 'dart:convert';

import 'package:citgroupvn_car/constant/show_toast_dialog.dart';
import 'package:citgroupvn_car/controller/login_conroller.dart';
import 'package:citgroupvn_car/page/auth_screens/add_profile_photo_screen.dart';
import 'package:citgroupvn_car/page/auth_screens/forgot_password.dart';
import 'package:citgroupvn_car/page/auth_screens/login_screen.dart';
import 'package:citgroupvn_car/page/auth_screens/mobile_number_screen.dart';
import 'package:citgroupvn_car/page/dash_board.dart';
import 'package:citgroupvn_car/themes/button_them.dart';
import 'package:citgroupvn_car/themes/constant_colors.dart';
import 'package:citgroupvn_car/themes/text_field_them.dart';
import 'package:citgroupvn_car/utils/Preferences.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class LoginEmailScreen extends StatelessWidget {
  LoginEmailScreen({Key? key}) : super(key: key);

  static final GlobalKey<FormState> _loginEmailFormKey = GlobalKey<FormState>();

  static final _phoneController = TextEditingController();
  static final _passwordController = TextEditingController();
  final controller = Get.put(LoginController());

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
            child: Stack(
              children: [
                Center(
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
                                    image:
                                        AssetImage("assets/icons/logo.png"))),
                            width: 100,
                            height: 45,
                          ),
                          Text(
                            "Đăng nhập bằng mật khẩu".tr,
                            textAlign: TextAlign.center,
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
                              key: _loginEmailFormKey,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 40),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                            color: ConstantColors
                                                .textFieldBoarderColor,
                                          ),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(6))),
                                      padding: const EdgeInsets.only(left: 10),
                                      child: IntlPhoneField(
                                        onChanged: (phone) {
                                          _phoneController.text =
                                              phone.completeNumber;
                                        },
                                        initialCountryCode: 'VN',
                                        invalidNumberMessage: "number invalid",
                                        showDropdownIcon: false,
                                        disableLengthCheck: true,
                                        decoration: InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 12),
                                          hintText: 'Nhập số điện thoại'.tr,
                                          border: InputBorder.none,
                                          isDense: true,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // TextFieldThem.boxBuildTextField(
                                  //   hintText: 'email'.tr,
                                  //   controller: _phoneController,
                                  //   textInputType: TextInputType.emailAddress,
                                  //   contentPadding: EdgeInsets.zero,
                                  //   validators: (String? value) {
                                  //     if (value!.isNotEmpty) {
                                  //       return null;
                                  //     } else {
                                  //       return 'required'.tr;
                                  //     }
                                  //   },
                                  // ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 15),
                                    child: TextFieldThem.boxBuildTextField(
                                      hintText: 'password'.tr,
                                      controller: _passwordController,
                                      textInputType: TextInputType.text,
                                      obscureText: false,
                                      contentPadding: EdgeInsets.zero,
                                      validators: (String? value) {
                                        if (value!.isNotEmpty) {
                                          return null;
                                        } else {
                                          return 'required'.tr;
                                        }
                                      },
                                    ),
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.only(top: 50),
                                      child: ButtonThem.buildButton(
                                        context,
                                        title: 'log in'.tr,
                                        btnHeight: 50,
                                        btnColor: ConstantColors.primary,
                                        txtColor: Colors.white,
                                        onPress: () async {
                                          FocusScope.of(context).unfocus();
                                          if (_loginEmailFormKey.currentState!
                                              .validate()) {
                                            Map<String, String> bodyParams = {
                                              'email':
                                                  _phoneController.text.trim(),
                                              'mdp': _passwordController.text,
                                              'user_cat': "customer",
                                            };
                                            await controller
                                                .loginAPI(bodyParams)
                                                .then((value) {
                                              if (value != null) {
                                                if (value.success ==
                                                    "Success") {
                                                  Preferences.setInt(
                                                      Preferences.userId,
                                                      int.parse(value.data!.id
                                                          .toString()));
                                                  Preferences.setString(
                                                      Preferences.user,
                                                      jsonEncode(value));
                                                  _phoneController.clear();
                                                  _passwordController.clear();
                                                  if (value.data!.photo ==
                                                          null ||
                                                      value.data!.photoPath
                                                          .toString()
                                                          .isEmpty) {
                                                    Get.to(() =>
                                                        AddProfilePhotoScreen());
                                                  } else {
                                                    Preferences.setBoolean(
                                                        Preferences.isLogin,
                                                        true);
                                                    Get.offAll(DashBoard(),
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    400),
                                                        //duration of transitions, default 1 sec
                                                        transition: Transition
                                                            .rightToLeft);
                                                  }
                                                } else {
                                                  ShowToastDialog.showToast(
                                                      value.error);
                                                }
                                              }
                                            });
                                          }
                                        },
                                      )),
                                  Padding(
                                      padding: const EdgeInsets.only(top: 40),
                                      child: ButtonThem.buildBorderButton(
                                        context,
                                        title: 'Login With Phone Number'.tr,
                                        btnHeight: 50,
                                        btnColor: Colors.white,
                                        txtColor: ConstantColors.primary,
                                        onPress: () {
                                          FocusScope.of(context).unfocus();
                                          Get.back();
                                          ;
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.white,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.arrow_back_ios_rounded,
                            color: Colors.black,
                          ),
                        )),
                  ),
                )
              ],
            )),
      ),
    );
  }
}
