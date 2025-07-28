import 'package:citgroupvn_car/constant/constant.dart';
import 'package:citgroupvn_car/controller/notification_controller.dart';
import 'package:citgroupvn_car/model/notification_data.dart';
import 'package:citgroupvn_car/page/notification_screen/notification_detail_screen.dart';
import 'package:citgroupvn_car/themes/constant_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationScreens extends StatelessWidget {
  NotificationScreens({Key? key}) : super(key: key);
  final controllerNotification = Get.put(NotificationController());

  @override
  Widget build(BuildContext context) {
    return GetX<NotificationController>(
      init: NotificationController(),
      initState: (state) {
        controllerNotification.getAllNotification();
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
            body: RefreshIndicator(
              onRefresh: () => controller.getAllNotification(),
              child: controller.isLoading.value
                  ? Constant.loader()
                  : ListView.builder(
                      itemCount: controller.notificationList.length,
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemBuilder: (context, index) {
                        return itemNotification(context, controller,
                            controller.notificationList[index]);
                      },
                    ),
            ));
      },
    );
  }

  Widget itemNotification(
      context, controller, NotificationData dataNotification) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: GestureDetector(
          onTap: () async {
            Get.to(NotificationDetailScreens(
              id: dataNotification.id,
            ));
          },
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
                      dataNotification.titre ?? '',
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    )
                  ]),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 2.0),
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 65,
                        child: Text(
                          dataNotification.message ?? '',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        dataNotification.creerModify ?? '',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
