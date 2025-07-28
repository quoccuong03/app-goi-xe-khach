import 'dart:async';

import 'package:citgroupvn_car/constant/constant.dart';
import 'package:citgroupvn_car/controller/food_controller.dart';
import 'package:citgroupvn_car/controller/my_package_controller.dart';
import 'package:citgroupvn_car/model/food_model.dart';
import 'package:citgroupvn_car/model/package_data.dart';
import 'package:citgroupvn_car/page/food_screen/store_detail_screen.dart';
import 'package:citgroupvn_car/themes/button_them.dart';
import 'package:citgroupvn_car/themes/constant_colors.dart';
import 'package:citgroupvn_car/themes/text_field_them.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class FoodHomeScreens extends StatefulWidget {
  const FoodHomeScreens({Key? key}) : super(key: key);
  @override
  State<FoodHomeScreens> createState() => _FoodHomeScreensState();
}

class _FoodHomeScreensState extends State<FoodHomeScreens> {
  final controllerFood = Get.put(FoodController());
  final _searchFieldController = TextEditingController();

  Timer? _debounceTimer;
  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _searchFieldController.addListener(_onSearchTextChanged);
  }

  void _onSearchTextChanged() {
    if (_debounceTimer != null && _debounceTimer!.isActive) {
      _debounceTimer!.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      controllerFood.getHome(_searchFieldController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetX<FoodController>(
      init: FoodController(),
      initState: (state) {
        controllerFood.getHome('');
        controllerFood.getCart();
        controllerFood.getCurrentLocation();
      },
      builder: (controller) {
        return SafeArea(
            child: Scaffold(
          backgroundColor: ConstantColors.background,
          body: RefreshIndicator(
            onRefresh: () async {
              _searchFieldController.text = '';
              controllerFood.getCart();
              return await Future<void>.delayed(Duration(milliseconds: 100));
            },
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                child: controller.isLoading.value
                    ? Constant.loader()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                            ),
                            TextFieldThem.boxBuildTextField(
                              hintText: 'Tìm kiếm'.tr,
                              controller: _searchFieldController,
                              prefixIcon: Icon(Icons.search_outlined),
                              suffixIcon: _searchFieldController.text.isNotEmpty
                                  ? GestureDetector(
                                      onTap: () {
                                        _searchFieldController.text = '';
                                      },
                                      child: Icon(Icons.cancel),
                                    )
                                  : const Padding(
                                      padding: EdgeInsets.all(0),
                                    ),
                              fillColor: const Color.fromRGBO(242, 242, 242, 1),
                              contentPadding: EdgeInsets.zero,
                              validators: (String? value) {
                                if (value!.isNotEmpty) {
                                  return null;
                                } else {
                                  return 'required'.tr;
                                }
                              },
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                            ),
                            const Text(
                              'Cửa hàng nổi bật',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                            ),
                            SizedBox(
                              height: 126,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: controller
                                    .dataHome.value.featute_stores!
                                    .map((i) => GestureDetector(
                                        onTap: () {
                                          Get.to(StoreDetailScreen(
                                            storeData: i,
                                          ));
                                        },
                                        child: Container(
                                          width: 126.0,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 126,
                                                height: 80,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5.0),
                                                decoration: BoxDecoration(
                                                  color: ConstantColors.primary,
                                                  image: DecorationImage(
                                                    fit: BoxFit.fitWidth,
                                                    image: NetworkImage(
                                                        i.banner as String),
                                                  ),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                    Radius.circular(8.0),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                child: Text(
                                                  i.name ?? '',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontSize: 14.0,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.black),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                child: Text(
                                                  "${i.distance ?? '0'} km",
                                                  style: const TextStyle(
                                                    fontSize: 12.0,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Color.fromRGBO(
                                                        79, 79, 79, 1),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )))
                                    .toList(),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                            ),
                            const Text(
                              'Sản phẩm nổi bật',
                              style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                            ),
                            SizedBox(
                              height: 210,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: controller
                                    .dataHome.value.featute_products!
                                    .map((i) => Container(
                                          width: 184.0,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 5.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 184,
                                                height: 103,
                                                decoration: BoxDecoration(
                                                  color: ConstantColors.primary,
                                                  image: DecorationImage(
                                                    fit: BoxFit.fitWidth,
                                                    image: NetworkImage(
                                                        i.image as String),
                                                  ),
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(8.0),
                                                    topRight:
                                                        Radius.circular(8.0),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: 184,
                                                padding: EdgeInsets.all(0),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color:
                                                          const Color.fromRGBO(
                                                              0, 0, 0, 0.08)),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10),
                                                      child: Text(
                                                        i.name ?? '',
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                            fontSize: 14.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10),
                                                      child: Text(
                                                        i.description ?? '0',
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          fontSize: 12.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Color.fromRGBO(
                                                              141, 141, 141, 1),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10),
                                                      child: Text(
                                                        "${i.distance ?? '0'} km",
                                                        style: const TextStyle(
                                                          fontSize: 10.0,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: Color.fromRGBO(
                                                              79, 79, 79, 1),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            Constant().amountShow(
                                                                amount: i.price
                                                                    .toString()),
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 13),
                                                          ),
                                                          GestureDetector(
                                                            onTap: () {
                                                              controller.updateCart(
                                                                  i.id ?? '',
                                                                  i.store!.id ??
                                                                      '',
                                                                  '1');
                                                            },
                                                            child: Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(8),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              30),
                                                                  color: ConstantColors
                                                                      .primary,
                                                                  boxShadow: <BoxShadow>[
                                                                    BoxShadow(
                                                                      color: ConstantColors
                                                                          .primary
                                                                          .withOpacity(
                                                                              0.1),
                                                                      blurRadius:
                                                                          3,
                                                                      offset:
                                                                          const Offset(
                                                                              0,
                                                                              3),
                                                                    ),
                                                                  ],
                                                                ),
                                                                child: const Icon(
                                                                    Icons.add,
                                                                    size: 16,
                                                                    color: Colors
                                                                        .white)),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 4.0),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                          ]),
              ),
            ),
          ),
        ));
      },
    );
  }
}
