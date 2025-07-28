// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:citgroupvn_car/constant/show_toast_dialog.dart';
import 'package:citgroupvn_car/controller/forgot_password_controller.dart';
import 'package:citgroupvn_car/controller/phone_number_controller.dart';
import 'package:citgroupvn_car/page/auth_screens/add_profile_photo_screen.dart';
import 'package:citgroupvn_car/page/auth_screens/signup_screen.dart';
import 'package:citgroupvn_car/page/dash_board.dart';
import 'package:citgroupvn_car/service/api.dart';
import 'package:citgroupvn_car/themes/button_them.dart';
import 'package:citgroupvn_car/themes/constant_colors.dart';
import 'package:citgroupvn_car/themes/text_field_them.dart';
import 'package:citgroupvn_car/utils/Preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordOtpScreen extends StatelessWidget {
  String? phoneNumber;
  String? verificationId;

  ForgotPasswordOtpScreen(
      {Key? key, required this.phoneNumber, required this.verificationId})
      : super(key: key);

  final controller = Get.put(ForgotPasswordController());
  static final _formKey = GlobalKey<FormState>();

  final _passwordController = TextEditingController();
  final _conformPasswordController = TextEditingController();
  final _phoneNumberController = Get.put(PhoneNumberController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Update Password".tr,
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
                          padding: const EdgeInsets.only(top: 50),
                          child: TextFieldThem.boxBuildTextField(
                            hintText: 'password'.tr,
                            controller: _passwordController,
                            textInputType: TextInputType.text,
                            obscureText: false,
                            contentPadding: EdgeInsets.zero,
                            validators: (String? value) {
                              if (value!.length >= 6) {
                                return null;
                              } else {
                                return 'Password required at least 6 characters'
                                    .tr;
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: TextFieldThem.boxBuildTextField(
                            hintText: 'confirm_password'.tr,
                            controller: _conformPasswordController,
                            textInputType: TextInputType.text,
                            obscureText: false,
                            contentPadding: EdgeInsets.zero,
                            validators: (String? value) {
                              if (_passwordController.text != value) {
                                return 'Confirm password is invalid'.tr;
                              } else {
                                return null;
                              }
                            },
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: ButtonThem.buildButton(
                              context,
                              title: 'done'.tr,
                              btnHeight: 50,
                              btnColor: ConstantColors.primary,
                              txtColor: Colors.white,
                              onPress: () async {
                                FocusScope.of(context).unfocus();
                                if (_formKey.currentState!.validate()) {
                                  Map<String, String> bodyParams = {
                                    'phone': phoneNumber.toString(),
                                    'user_cat': "customer",
                                  };
                                  await _phoneNumberController
                                      .phoneNumberIsExit(bodyParams)
                                      .then((value) async {
                                    if (value == true) {
                                      Map<String, String> bodyParams = {
                                        'phone': phoneNumber.toString(),
                                        'user_cat': "customer",
                                      };
                                      await _phoneNumberController
                                          .getDataByPhoneNumber(bodyParams)
                                          .then((value) async {
                                        if (value != null) {
                                          if (value.success == "success") {
                                            ShowToastDialog.closeLoader();

                                            Preferences.setInt(
                                                Preferences.userId,
                                                int.parse(
                                                    value.data!.id.toString()));
                                            Preferences.setString(
                                                Preferences.user,
                                                jsonEncode(value));
                                            Preferences.setString(
                                                Preferences.accesstoken,
                                                value.data!.accesstoken
                                                    .toString());
                                            Preferences.setString(
                                                Preferences.admincommission,
                                                value.data!.adminCommission
                                                    .toString());
                                            API.header['accesstoken'] =
                                                Preferences.getString(
                                                    Preferences.accesstoken);

                                            final String? firebaseToken =
                                                await FirebaseAuth
                                                    .instance.currentUser!
                                                    .getIdToken();
                                            Map<String, String> bodyParams = {
                                              'phone': phoneNumber.toString(),
                                              'id_user':
                                                  value.data!.id.toString(),
                                              'opt_firebase_tokken':
                                                  firebaseToken.toString(),
                                              'new_password':
                                                  _passwordController.text
                                                      .trim(),
                                              'confirm_password':
                                                  _passwordController.text
                                                      .trim(),
                                              'user_cat': "user_app",
                                            };

                                            controller
                                                .resetPassword(bodyParams)
                                                .then((valueReset) {
                                              if (valueReset != null) {
                                                if (valueReset == true) {
                                                  ShowToastDialog.showToast(
                                                      "Password change successfully!"
                                                          .tr);
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
                                                    Get.offAll(DashBoard());
                                                  }
                                                } else {
                                                  ShowToastDialog.showToast(
                                                      "Please try again later"
                                                          .tr);
                                                }
                                              }
                                            });
                                          } else {
                                            ShowToastDialog.showToast(
                                                value.error);
                                          }
                                        }
                                      });
                                    } else if (value == false) {
                                      ShowToastDialog.closeLoader();
                                      Get.off(SignupScreen(
                                        phoneNumber: phoneNumber.toString(),
                                      ));
                                    }
                                  });
                                }
                              },
                            )),
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
          ),
        ),
      ),
    );
  }
}
