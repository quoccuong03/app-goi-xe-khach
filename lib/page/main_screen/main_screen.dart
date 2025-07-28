// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:citgroupvn_car/constant/constant.dart';
import 'package:citgroupvn_car/controller/dash_board_controller.dart';
import 'package:citgroupvn_car/controller/wallet_controller.dart';
import 'package:citgroupvn_car/page/main_screen/view_banner_screen.dart';
import 'package:citgroupvn_car/themes/constant_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';

class MainScreens extends StatelessWidget {
  MainScreens({Key? key}) : super(key: key);
  final controllerDashBoard = Get.put(DashBoardController());
  final walletController = Get.put(WalletController());
  Widget wallet(context) {
    Future<void> _refreshAPI() async {
      walletController.getAmount();
    }

    return GetX<WalletController>(
      init: WalletController(),
      initState: (state) {
        _refreshAPI();
      },
      builder: (controller) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: ConstantColors.widgetBackgroundColor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    margin: EdgeInsets.only(bottom: 12),
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Số dư Ví:',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: Colors.black),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Container(
                          constraints:
                              BoxConstraints(maxWidth: Get.width - 150),
                          child: Text(
                            Constant().amountShow(
                                amount:
                                    walletController.walletAmount.toString()),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: ConstantColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      // Wallet
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            controllerDashBoard.onSelectItem(6);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: ConstantColors.primary),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/icons/ic_add.png',
                                  width: 20,
                                  height: 20,
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Container(
                                  constraints: BoxConstraints(
                                      maxWidth: Get.width / 3 - 50),
                                  child: Text(
                                    'Nạp tiền',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      // Package
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            controllerDashBoard.onSelectItem(5);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: ConstantColors.primary),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/icons/ic_box.png',
                                  width: 20,
                                  height: 20,
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Container(
                                  constraints: BoxConstraints(
                                      maxWidth: Get.width / 3 - 50),
                                  child: Text(
                                    'Mua gói',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      // Order History
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            controllerDashBoard.onSelectItem(4);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: ConstantColors.primary),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.history,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  'Lịch sử đơn',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        );
      },
    );
  }

  static Widget serviceItem(icon, text, index, context, isOtherService, link) {
    final controllerDashBoard = Get.put(DashBoardController());

    // return GestureDetector(
    //   onTap: () async {
    //     controllerDashBoard.onSelectItem(index);
    //   },
    //   child: Container(
    //       width: MediaQuery.of(context).size.width / 2 - 50,
    //       padding: EdgeInsets.symmetric(vertical: 20),
    //       decoration: BoxDecoration(
    //         borderRadius: BorderRadius.circular(10),
    //         border: Border.all(
    //           color: ConstantColors.primary,
    //           width: 1.0,
    //         ),
    //         color: Colors.white,
    //         boxShadow: <BoxShadow>[
    //           BoxShadow(
    //             color: ConstantColors.primary.withOpacity(0.1),
    //             blurRadius: 3,
    //             offset: const Offset(0, 3),
    //           ),
    //         ],
    //       ),
    //       child: Column(
    //         children: [
    //           Padding(
    //             padding: const EdgeInsets.all(8.0),
    //             child: Icon(
    //               icon,
    //               size: 52.0,
    //               color: ConstantColors.primary,
    //             ),
    //           ),
    //           Text(
    //             text,
    //             style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.normal),
    //           ),
    //         ],
    //       )),
    // );
    return InkWell(
      onTap: () async {
        if (isOtherService == true) {
          Get.to(() => ViewBannerScreen(initialURl: link ?? ''));
        } else {
          controllerDashBoard.onSelectItem(index);
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 20),
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              padding: EdgeInsets.all(9),
              margin: EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(29),
                color: ConstantColors.itemsBackgroundColor,
              ),
              child: (isOtherService == true)
                  ? Image.network(
                      icon,
                      fit: BoxFit.fitHeight,
                      errorBuilder: (BuildContext context, Object exception,
                          StackTrace? stackTrace) {
                        return SizedBox(
                          width: 0,
                          height: 0,
                        );
                      },
                    )
                  : Image.asset(
                      icon,
                      fit: BoxFit.fitHeight,
                    ),
            ),
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetX<DashBoardController>(
        init: DashBoardController(),
        initState: (state) {
          controllerDashBoard.getBanners();
          controllerDashBoard.getOtherServices();
        },
        builder: (controller) {
          return Scaffold(
              backgroundColor: ConstantColors.background,
              body: SingleChildScrollView(
                  child: Column(
                children: [
                  Divider(
                    color: ConstantColors.dividerColor,
                  ),
                  wallet(context),
                  FlutterCarousel(
                    options: CarouselOptions(
                        height: 200.0,
                        showIndicator: false,
                        autoPlay: true,
                        enableInfiniteScroll: true,
                        autoPlayInterval: const Duration(seconds: 4),
                        viewportFraction: 1.0,
                        autoPlayAnimationDuration:
                            const Duration(milliseconds: 500)),
                    items: controllerDashBoard.banners.map((i) {
                      return Builder(
                        builder: (BuildContext context) {
                          return GestureDetector(
                              onTap: () async {
                                Get.to(() =>
                                    ViewBannerScreen(initialURl: i.link ?? ''));
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.symmetric(horizontal: 5.0),
                                decoration: BoxDecoration(
                                  color: ConstantColors.primary,
                                  image: DecorationImage(
                                    fit: BoxFit.fitWidth,
                                    image: NetworkImage(i.bannerUrl as String),
                                  ),
                                  // borderRadius: BorderRadius.all(
                                  //   Radius.circular(10.0),
                                  // ),
                                ),
                              ));
                        },
                      );
                    }).toList(),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        constraints: BoxConstraints(maxWidth: Get.width - 20),
                        decoration: BoxDecoration(
                          color: ConstantColors.widgetBackgroundColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: Text(
                            'Lái xe hộ khi bạn đã uống rượu bia',
                            style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                                color: ConstantColors.primary),
                          ),
                        )),
                  ]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      serviceItem('assets/icons/ic_motorbike.png',
                          'Lái hộ xe máy', 14, context, false, null),
                      serviceItem('assets/icons/ic_oto.png', 'Lái hộ Oto', 12,
                          context, false, null),
                    ],
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        constraints: BoxConstraints(maxWidth: Get.width - 20),
                        decoration: BoxDecoration(
                          color: ConstantColors.widgetBackgroundColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: Text(
                            'Đi lại',
                            style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                                color: ConstantColors.primary),
                          ),
                        )),
                  ]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      serviceItem('assets/icons/ic_order_motorbike.png',
                          'Đặt xe máy', 15, context, false, null),
                      serviceItem('assets/icons/ic_order_oto.png', 'Đặt Oto',
                          16, context, false, null),
                    ],
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        constraints: BoxConstraints(maxWidth: Get.width - 20),
                        decoration: BoxDecoration(
                          color: ConstantColors.widgetBackgroundColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: Text(
                            'Đặt hàng',
                            style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                                color: ConstantColors.primary),
                          ),
                        )),
                  ]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      serviceItem('assets/icons/ic_shop.png', 'Mua đồ ăn', 13,
                          context, false, null),
                    ],
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        constraints: BoxConstraints(maxWidth: Get.width - 20),
                        decoration: BoxDecoration(
                          color: ConstantColors.widgetBackgroundColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: Text(
                            'Dịch vụ khác',
                            style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                                color: ConstantColors.primary),
                          ),
                        )),
                  ]),
                  Container(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: controllerDashBoard.otherServices.length,
                      itemBuilder: (BuildContext context, int index) {
                        var item =
                            controllerDashBoard.otherServices.elementAt(index);
                        return serviceItem(item.iconService, item.name, -1,
                            context, true, item.link);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                ],
              )));
        });
  }
}
