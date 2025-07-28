import 'package:citgroupvn_car/constant/constant.dart';
import 'package:citgroupvn_car/controller/notification_controller.dart';
import 'package:citgroupvn_car/themes/constant_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationDetailScreens extends StatelessWidget {
  final String? id;
  NotificationDetailScreens({Key? key, required this.id}) : super(key: key);
  final controllerNotification = Get.put(NotificationController());

  @override
  Widget build(BuildContext context) {
    return GetX<NotificationController>(
      init: NotificationController(),
      initState: (state) {
        controllerNotification.resetLoading();
        controllerNotification.getNotificationById(id);
      },
      builder: (controller) {
        return Scaffold(
          backgroundColor: ConstantColors.background,
          appBar: AppBar(
            backgroundColor: ConstantColors.background,
            leading: InkWell(
                onTap: () {
                  Get.back();
                },
                child: Icon(
                  Icons.arrow_back_ios,
                  color: ConstantColors.primary,
                )),
            centerTitle: true,
            title: Text('notification'.tr,
                style: const TextStyle(color: Colors.black)),
          ),
          body: SingleChildScrollView(
            child: controller.isLoading.value
                ? Constant.loader()
                : Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Row(children: [
                          Text(
                            controller.dataNotification.value.titre ?? '',
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w600),
                          )
                        ]),
                        Row(
                          children: [
                            Text(
                              controller.dataNotification.value.creerModify ??
                                  '',
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 2.0),
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 24,
                              child: Text(
                                controller.dataNotification.value.message ?? '',
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}
