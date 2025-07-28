import 'package:citgroupvn_car/constant/constant.dart';
import 'package:citgroupvn_car/controller/my_package_controller.dart';
import 'package:citgroupvn_car/model/package_data.dart';
import 'package:citgroupvn_car/themes/button_them.dart';
import 'package:citgroupvn_car/themes/constant_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class MyPackageScreens extends StatelessWidget {
  MyPackageScreens({Key? key}) : super(key: key);
  final controllerMyPackage = Get.put(MyPackageController());
  String amountShow({String? value}) {
    return value ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return GetX<MyPackageController>(
      init: MyPackageController(),
      initState: (state) {
        controllerMyPackage.getAllPackage();
      },
      builder: (controller) {
        return Scaffold(
            backgroundColor: ConstantColors.background,
            body: RefreshIndicator(
              onRefresh: () => controller.getAllPackage(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 0),
                child: controller.isLoading.value
                    ? Constant.loader()
                    : Column(children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          color: ConstantColors.primary,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Current my package information".tr,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
                                    )
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                            text: "${"Total request".tr}: ",
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14),
                                            children: [
                                              TextSpan(
                                                text: controller.userModel!.data!.totalRequests ?? '0',
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16),
                                              ),
                                            ]
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                            text: "${"Total days".tr}: ",
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500),
                                            children: [
                                              TextSpan(
                                                text: controller.userModel!
                                                    .data!.totalDay ??
                                                    '0',
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight:
                                                    FontWeight.w600),
                                              )
                                            ]),
                                      ),
                                    ),
                                  ],
                                ),
                                if (controller.userModel!.data!.expireDate !=
                                    "null")
                                  Row(
                                    children: [
                                      Expanded(
                                        child: RichText(
                                          text: TextSpan(
                                              text: "${"Expire Date".tr}: ",
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500),
                                              children: [
                                                TextSpan(
                                                  text: controller.userModel!.data!.expireDate != "null" ? controller.userModel!.data!.expireDate ?? '' : '',
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                      FontWeight.w600),
                                                )
                                              ]),
                                        ),
                                      ),
                                    ],
                                  ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                        ),
                        if (controller.packageList.isNotEmpty)
                          ListView.builder(
                              itemCount: controller.packageList.length,
                              shrinkWrap: true,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              itemBuilder: (context, index) {
                                return itemPackage(context, controller,
                                    controller.packageList[index]);
                              })
                      ]),
              ),
            ));
      },
    );
  }

  Widget itemPackage(context, controller, PackageData dataPackage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        width: MediaQuery.of(context).size.width - 20,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: ConstantColors.primary,
            width: 1.0,
          ),
          color: Colors.white,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: ConstantColors.primary.withOpacity(0.1),
              blurRadius: 3,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              Row(children: [
                Text(
                  dataPackage.name ?? '',
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                )
              ]),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 7.0),
              ),
              Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                          text: "${"Total request".tr}: ",
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                          children: [
                            TextSpan(
                              text: dataPackage.totalRequest ?? '',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            )
                          ]),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(child: RichText(
                    text: TextSpan(
                        text: "${"Total days".tr}: ",
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                        children: [
                          TextSpan(
                            text: dataPackage.totalDay ?? '',
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          )
                        ]),
                  ),)
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: RichText(
                        text: TextSpan(
                            text: "${"Price".tr}: ",
                            style: const TextStyle(
                                color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
                            children: [
                          TextSpan(
                            text: Constant()
                                .amountShow(amount: dataPackage.price.toString()),
                            style: TextStyle(
                                color: ConstantColors.primary, fontSize: 16, fontWeight: FontWeight.w600),
                          )
                        ])),
                  ),
                  MaterialButton(
                    onPressed: () =>
                        {buildBottomSheet(context, controller, dataPackage.id)},
                    height: 30,
                    elevation: 0.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    color: ConstantColors.primary,
                    child: Text(
                      "Buy now".tr,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

buildBottomSheet(BuildContext context, controller, id) {
  return showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Container(
            height: 160,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 20),
                  child: Text(
                    "do_you_want_to_buy_this_package".tr,
                    style: TextStyle(
                      color: const Color(0XFF333333).withOpacity(0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ButtonThem.buildBorderButton(context,
                        title: 'cancel'.tr,
                        btnHeight: 50,
                        isUpperCase: false,
                        btnColor: Colors.white,
                        txtColor: ConstantColors.primary, onPress: () {
                      FocusScope.of(context).unfocus();

                      Get.back();
                    },
                        btnBorderColor: ConstantColors.primary,
                        btnWidthRatio: 0.4),
                    ButtonThem.buildButton(context,
                        title: 'yes'.tr,
                        btnHeight: 50,
                        isUpperCase: false,
                        btnColor: ConstantColors.primary,
                        txtColor: Colors.white, onPress: () {
                      FocusScope.of(context).unfocus();
                      controller.buyPackage(id);
                      Get.back();
                    }, btnWidthRatio: 0.4)
                  ],
                ),
              ],
            ),
          );
        });
      });
}
