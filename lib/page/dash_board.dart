// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:citgroupvn_car/constant/constant.dart';
import 'package:citgroupvn_car/constant/show_toast_dialog.dart';
import 'package:citgroupvn_car/controller/dash_board_controller.dart';
import 'package:citgroupvn_car/controller/food_controller.dart';
import 'package:citgroupvn_car/model/food_model.dart';
import 'package:citgroupvn_car/model/location_info.dart';
import 'package:citgroupvn_car/page/food_screen/carts_screen.dart';
import 'package:citgroupvn_car/page/notification_screen/notification_detail_screen.dart';
import 'package:citgroupvn_car/page/notification_screen/notification_screen.dart';
import 'package:citgroupvn_car/service/api.dart';
import 'package:citgroupvn_car/themes/button_them.dart';
import 'package:citgroupvn_car/themes/constant_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'home_screens/custom_search_location_screen.dart';

class DashBoard extends StatelessWidget {
  DashBoard({Key? key}) : super(key: key);

  DateTime backPress = DateTime.now();
  final controllerFood = Get.put(FoodController());

  Future<void> fetchData(String input) async {
    try {
      final url = Uri.parse(
          'https://rsapi.goong.io/Place/AutoComplete?api_key=${Constant.goongApiKey}&input=$input');

      var response = await client.get(url);

      final jsonResponse = jsonDecode(response.body);
      controllerFood.places.value =
          jsonResponse['predictions'] as List<dynamic>;
    } catch (e) {
      // ignore: avoid_print
      print('$e');
    }
  }

  Widget _buildListView(onSelect) {
    return ListView.builder(
      itemCount: controllerFood.places.length,
      itemBuilder: (context, index) {
        final coordinate = controllerFood.places[index];

        return ListTile(
          horizontalTitleGap: 5,
          title: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(
                Icons.location_on_outlined,
                color: ConstantColors.primary,
                size: 20,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width - 195,
                child: Text(
                  coordinate['description'],
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: const TextStyle(
                    color: Colors.black54,
                  ),
                ),
              )
            ],
          ),
          onTap: () async {
            final url = Uri.parse(
                'https://rsapi.goong.io/Place/Detail?place_id=${coordinate['place_id']}&api_key=${Constant.goongApiKey}');
            var response = await client.get(url);
            final jsonResponse = jsonDecode(response.body);
            onSelect(jsonResponse);
          },
        );
      },
    );
  }

  showDialogEitAddress(String text, onSelect, context) {
    final TextEditingController textFieldSearchController =
        TextEditingController();
    if (text.isNotEmpty) {
      fetchData(text);
      textFieldSearchController.text = text;
    }
    Navigator.of(context).push(CustomSearchLocationView(
        textEditingController: textFieldSearchController,
        isSelectShipmentDestination: true,
        onSelectPlaceFromMap: (locationInfo) {
          onSelect(locationInfo);
        },
        onStartAndIgnoreDestination: () async {
        },
        onSelectedPlace: (coordinate) async {
          final url = Uri.parse(
              'https://rsapi.goong.io/Place/Detail?place_id=${coordinate['place_id']}&api_key=${Constant.goongApiKey}');
          var response = await client.get(url);
          final jsonResponse = jsonDecode(response.body);
          if (jsonResponse != null) {
            double mlat = jsonResponse['result']['geometry']['location']['lat'];
            double mlng = jsonResponse['result']['geometry']['location']['lng'];
            var name = jsonResponse['result']['name'].toString();
            var detailName =
            jsonResponse['result']['formatted_address'].toString();
            onSelect(LocationInfo(
                lat: mlat,
                lng: mlng,
                addressName: name,
                detailAddress: detailName));
          }
        }));
    // return showDialog(
    //   context: context,
    //   barrierDismissible: false,
    //   builder: (BuildContext context) {
    //     FocusScope.of(context).requestFocus(textFieldSearchNode);
    //     return AlertDialog(
    //       title: Text('Enter Address'.tr),
    //       backgroundColor: Colors.white,
    //       surfaceTintColor: Colors.transparent,
    //       buttonPadding: const EdgeInsets.all(0),
    //       shape: RoundedRectangleBorder(
    //         borderRadius: BorderRadius.circular(20.0),
    //       ),
    //       content: Container(
    //         height: 250,
    //         width: MediaQuery.of(context).size.width,
    //         padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
    //         decoration: const BoxDecoration(color: Colors.white),
    //         child: Column(
    //           mainAxisAlignment: MainAxisAlignment.start,
    //           children: [
    //             TextField(
    //               controller: textFieldSearchController,
    //               focusNode: textFieldSearchNode,
    //               onChanged: (text) {
    //                 if (text.isNotEmpty) {
    //                   fetchData(text);
    //                 }
    //               },
    //               decoration: InputDecoration(
    //                 counterText: "",
    //                 contentPadding: const EdgeInsets.all(8),
    //                 fillColor: Colors.white,
    //                 filled: true,
    //                 focusedBorder: OutlineInputBorder(
    //                   borderSide: BorderSide(
    //                       color: ConstantColors.textFieldBoarderColor,
    //                       width: 0.7),
    //                 ),
    //                 enabledBorder: OutlineInputBorder(
    //                   borderSide: BorderSide(
    //                       color: ConstantColors.textFieldBoarderColor,
    //                       width: 0.7),
    //                 ),
    //                 errorBorder: OutlineInputBorder(
    //                   borderSide: BorderSide(
    //                       color: ConstantColors.textFieldBoarderColor,
    //                       width: 0.7),
    //                 ),
    //                 border: OutlineInputBorder(
    //                   borderSide: BorderSide(
    //                       color: ConstantColors.textFieldBoarderColor,
    //                       width: 0.7),
    //                 ),
    //                 hintText: "Địa chỉ của bạn".tr,
    //                 hintStyle: TextStyle(
    //                   color: ConstantColors.hintTextColor,
    //                 ),
    //               ),
    //             ),
    //             Container(
    //               height: 180,
    //               width: MediaQuery.of(context).size.width - 0,
    //               padding: const EdgeInsets.all(0),
    //               child: _buildListView((value) {
    //                 controllerFood.places.value = [];
    //                 Navigator.of(context).pop();
    //                 onSelect(value);
    //                 textFieldSearchController.text = '';
    //               }),
    //             ),
    //           ],
    //         ),
    //       ),
    //       actions: <Widget>[
    //         ButtonThem.buildBorderButton(context,
    //             title: 'cancel'.tr,
    //             btnHeight: 50,
    //             isUpperCase: false,
    //             btnColor: Colors.white,
    //             txtColor: ConstantColors.primary, onPress: () {
    //           Navigator.of(context).pop();
    //           textFieldSearchController.text = '';
    //
    //           controllerFood.places.value = [];
    //         }, btnBorderColor: ConstantColors.primary, btnWidthRatio: 0.3),
    //       ],
    //     );
    //   },
    // );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: ConstantColors.primary,
    ));
    return GetX<DashBoardController>(
      init: DashBoardController(),
      builder: (controller) {
        return SafeArea(
          child: WillPopScope(
            onWillPop: () async {
              final timeGap = DateTime.now().difference(backPress);
              final cantExit = timeGap >= const Duration(seconds: 2);
              backPress = DateTime.now();
              if (cantExit) {
                const snack = SnackBar(
                  content: Text(
                    'Press Back button again to Exit',
                    style: TextStyle(color: Colors.white),
                  ),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.black,
                );
                ScaffoldMessenger.of(context).showSnackBar(snack);
                return false; // false will do nothing when back press
              } else {
                return true; // true will exit the app
              }
            },
            child: Scaffold(
              appBar: controller.selectedDrawerIndex.value != 6
                  ? AppBar(
                      backgroundColor:
                          controller.selectedDrawerIndex.value == 7 ||
                                  controller.selectedDrawerIndex.value == 13 ||
                                  controller.selectedDrawerIndex.value == 5
                              ? ConstantColors.primary
                              : ConstantColors.background,
                      elevation: 0,
                      centerTitle: controller.selectedDrawerIndex.value != 13,
                      title: controller.selectedDrawerIndex.value == 13
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 0),
                              child: GestureDetector(
                                onTap: () {
                                  showDialogEitAddress(
                                      controllerFood.address.value.name ?? '',
                                      (value) async {
                                    if (value != null) {
                                      var locationInfo = value as LocationInfo;
                                      controllerFood.address.value =
                                          AddressData(
                                              lat: locationInfo.lat,
                                              lng: locationInfo.lng,
                                              name: locationInfo.addressName,
                                              detailAddress: locationInfo.detailAddress);
                                    }
                                  }, context);
                                },
                                child: Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'GIAO TỚI',
                                          style: TextStyle(
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.white),
                                        ),
                                        SizedBox(
                                          width: 100,
                                          child: Text(
                                            controllerFood.address.value.name ??
                                                '',
                                            style: const TextStyle(
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.white),
                                          ),
                                        )
                                      ],
                                    ),
                                    const Icon(
                                      Icons.arrow_drop_down,
                                      size: 25.0,
                                      color: Colors.white,
                                    )
                                  ],
                                ),
                              ),
                            )
                          : controller.selectedDrawerIndex.value == 0
                              ? Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.transparent,
                                      image: DecorationImage(
                                          fit: BoxFit.fitWidth,
                                          image: AssetImage(
                                              "assets/images/vgrab_logo.png"))),
                                  width: 52,
                                  height: 42,
                                )
                              : controller.selectedDrawerIndex.value != 6
                                  ? Text(
                                      controller
                                          .drawerItems[controller
                                              .selectedDrawerIndex.value]
                                          .title
                                          .tr,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                        color: controller.selectedDrawerIndex
                                                        .value ==
                                                    5 ||
                                                controller.selectedDrawerIndex
                                                        .value ==
                                                    7
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    )
                                  : const Text(""),
                      leading: Builder(builder: (context) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {
                              Scaffold.of(context).openDrawer();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.menu,
                                size: 24,
                                color: controller.selectedDrawerIndex.value ==
                                    5 ||
                                    controller
                                        .selectedDrawerIndex.value ==
                                        7
                                    ? Colors.white
                                    : ConstantColors.drawerTabColor,
                              ),
                            ),
                          ),
                        );
                      }),
                      actions: [
                          if (controller.selectedDrawerIndex.value != 13)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: InkWell(
                                onTap: () {
                                  Get.to(NotificationScreens());
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.notifications_none,
                                    color: controller.selectedDrawerIndex.value ==
                                                5 ||
                                            controller
                                                    .selectedDrawerIndex.value ==
                                                7
                                        ? Colors.white
                                        : ConstantColors.drawerTabColor,
                                  ),
                                ),
                              ),
                            ),
                          if (controller.selectedDrawerIndex.value == 13)
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: GestureDetector(
                                onTap: () {
                                  Get.to(const CartsScreen());
                                },
                                child: const Icon(Icons.shopping_bag_outlined,
                                    color: Colors.white),
                              ),
                            )
                        ])
                  : null,
              drawer: buildAppDrawer(context, controller),
              body: controller
                  .getDrawerItemWidget(controller.selectedDrawerIndex.value),
            ),
          ),
        );
      },
    );
  }

  buildAppDrawer(BuildContext context, DashBoardController controller) {
    var drawerOptions = <Widget>[];
    var displayDrawItems = controller.drawerItems
        .where((element) => element.isHide == false)
        .toList();
    for (var i = 0; i < displayDrawItems.length; i++) {
      var d = displayDrawItems[i];
      var isSelectedTab = i == controller.selectedDrawerIndex.value;
      var tabColor = isSelectedTab
          ? ConstantColors.primary
          : ConstantColors.drawerTabColor;
      drawerOptions.add(InkWell(
        onTap: () {
          ShowToastDialog.closeLoader();
          controller.onSelectItem(i);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isSelectedTab ? ConstantColors.selectedTabColor : Colors.transparent
          ),
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Row(
            children: [
              Icon(
                d.icon,
                color: tabColor,
              ),
              const SizedBox(width: 16,),
              Expanded(
                child: Text(
                  d.title.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: tabColor,
                  ),

                ),
              ),
            ],
          ),
        ),
      ));
    }
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          /// Drawer Header
          if (controller.userModel == null) Center(
                  child:
                      CircularProgressIndicator(color: ConstantColors.primary),
                )
          else Padding(
              padding: const EdgeInsets.only(left: 16, top: 36, right: 16, bottom: 30),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: ConstantColors.dividerColor)),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl:
                            controller.userModel!.data!.photoPath.toString(),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Constant.loader(),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                      child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          "${controller.userModel!.data!.prenom} ${controller.userModel!.data!.nom}",
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          controller.userModel!.data!.email.toString(),
                          style: TextStyle(
                              color: ConstantColors.blurTextColor,
                              fontSize: 12,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                    ],
                  ))
                ],
              ),
            ),
/*          UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    color: ConstantColors.primary,
                  ),
                  currentAccountPicture: ClipOval(
                    child: Padding(
                      padding: const EdgeInsets.all(3.0040096),
                      child: ClipOval(
                        child: Container(
                          color: Colors.white,
                          child: CachedNetworkImage(
                            imageUrl: controller.userModel!.data!.photoPath
                                .toString(),
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Constant.loader(),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                      ),
                    ),
                  ),
                  accountName: Text(
                    "${controller.userModel!.data!.prenom} ${controller.userModel!.data!.nom}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  accountEmail: Text(
                      controller.userModel!.data!.email.toString(),
                      style: const TextStyle(color: Colors.white)),
                ),*/
        /// Tabs
          Column(children: drawerOptions),
          Text(
            'V : ${Constant.appVersion}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class DrawerItem {
  String title;
  IconData icon;
  bool isHide = false;

  DrawerItem(this.title, this.icon, {this.isHide = false});
}
