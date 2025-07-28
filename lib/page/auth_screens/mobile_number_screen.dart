import 'package:citgroupvn_car/constant/show_toast_dialog.dart';
import 'package:citgroupvn_car/controller/phone_number_controller.dart';
import 'package:citgroupvn_car/themes/button_them.dart';
import 'package:citgroupvn_car/themes/constant_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class MobileNumberScreen extends StatelessWidget {
  final bool? isLogin;
  final bool? isForgotPassword;

  MobileNumberScreen({Key? key, required this.isLogin, this.isForgotPassword})
      : super(key: key);

  final controller = Get.put(PhoneNumberController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstantColors.background,
      body: SafeArea(
        child: Container(
          height: Get.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                "assets/images/login_bg.png",
              ),
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
                                  image: AssetImage("assets/icons/logo.png"))),
                          width: 100,
                          height: 45,
                        ),
                        Text(
                          isForgotPassword == true
                              ? "Enter the phone number we will send an OPT to create new password."
                                  .tr
                              : isLogin == true
                                  ? "Login Phone".tr
                                  : "Signup Phone".tr,
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
                          padding: const EdgeInsets.only(top: 80),
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: ConstantColors.textFieldBoarderColor,
                                ),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(6))),
                            padding: const EdgeInsets.only(left: 10),
                            child: IntlPhoneField(
                              onChanged: (phone) {
                                controller.phoneNumber.value =
                                    phone.completeNumber;
                              },
                              initialCountryCode: 'VN',
                              invalidNumberMessage:
                                  "Số điện thoại không hợp lệ",
                              showDropdownIcon: false,
                              disableLengthCheck: true,
                              decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 12),
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
                                if (controller.phoneNumber.value.isNotEmpty) {
                                  if (isForgotPassword == true) {
                                    Map<String, String> bodyParams = {
                                      'phone': controller.phoneNumber.value
                                          .toString(),
                                      'user_cat': "customer",
                                    };
                                    await controller
                                        .phoneNumberIsExit(bodyParams)
                                        .then((value) async {
                                      if (value == true) {
                                        ShowToastDialog.showLoader(
                                            "Đang gửi mã".tr);
                                        controller.sendCode(
                                            controller.phoneNumber.value,
                                            isForgotPassword);
                                      } else if (value == false) {
                                        ShowToastDialog.showToast(
                                            "Phone number not found".tr);
                                        ;
                                      }
                                    });
                                  } else {
                                    ShowToastDialog.showLoader(
                                        "Đang gửi mã".tr);
                                    controller.sendCode(
                                        controller.phoneNumber.value,
                                        isForgotPassword);
                                  }
                                }
                              },
                            )),
                        Padding(
                            padding: const EdgeInsets.only(top: 50),
                            child: ButtonThem.buildBorderButton(
                              context,
                              title: 'Đăng nhập'.tr,
                              btnHeight: 50,
                              btnColor: Colors.white,
                              btnBorderColor: ConstantColors.primary,
                              txtColor: ConstantColors.primary,
                              onPress: () {
                                FocusScope.of(context).unfocus();
                                Get.back();
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
