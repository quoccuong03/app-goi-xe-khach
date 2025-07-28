import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:citgroupvn_car/constant/constant.dart';
import 'package:citgroupvn_car/model/location_info.dart';
import 'package:citgroupvn_car/service/api.dart';
import 'package:citgroupvn_car/themes/button_them.dart';
import 'package:citgroupvn_car/themes/constant_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/food_controller.dart';
import '../../model/food_model.dart';
import 'package:http/http.dart' as http;

import '../home_screens/custom_search_location_screen.dart';
import 'add_notes_dialog.dart';

class CartsScreen extends StatefulWidget {
  const CartsScreen({super.key});

  @override
  State<CartsScreen> createState() => _CartsScreenState();
}

class _CartsScreenState extends State<CartsScreen> {
  final controllerFood = Get.put(FoodController());

  @override
  Widget build(BuildContext context) {
    return GetX<FoodController>(
      init: FoodController(),
      initState: (state) async {
        controllerFood.resetLoading();
        await controllerFood.getCart();
        controllerFood.isLoading.value = false;
      },
      builder: (controllerFood) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Giỏ hàng',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18),
            ),
            backgroundColor: ConstantColors.primary,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Column(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      child: Text(
                        'Địa điểm giao hàng',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: RichText(
                          text: TextSpan(
                              text: '${controllerFood.address.value.name}',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                              children: [
                                TextSpan(
                                  text:
                                      '\n${controllerFood.address.value.detailAddress}',
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400),
                                )
                              ]),
                        ),
                      )),
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 8, bottom: 8, right: 16),
                        child: InkWell(
                          onTap: () {
                            showDialogEitAddress(
                                controllerFood.address.value.detailAddress ??
                                    '', (value) async {
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
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: ConstantColors.primary, width: 2)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: Text(
                                'Thay đổi địa điểm',
                                style: TextStyle(
                                    color: ConstantColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Đơn hàng',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              /// ListView Builder
              Expanded(
                child: controllerFood.isLoading.value
                    ? Constant.loader()
                    : ListView.builder(
                        itemCount:
                            controllerFood.cartData.value.cart_items?.length ??
                                0,
                        itemBuilder: (BuildContext context, int index) {
                          return OrderItemView(
                            cartItemData: controllerFood
                                .cartData.value.cart_items!
                                .elementAt(index),
                            dataIndex: index,
                          );
                        },
                      ),
              ),

              /// Button
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Divider(
                    height: 1,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            ' ${controllerFood.getFoodNumber()} Món',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black),
                          ),
                        ),
                        Expanded(
                            child: Text(
                          Constant().amountShow(
                            amount: controllerFood.getTotalAmount().toString(),
                          ),
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        )),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                            child: InkWell(
                          onTap: Get.back,
                          child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: const Color(0xFFEE8311),
                              ),
                              child: const Text(
                                'Tiếp tục mua hàng',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                              )),
                        )),
                        const SizedBox(
                          width: 16,
                        ),
                        Expanded(
                            child: InkWell(
                          onTap: () async {
                            if ((controllerFood
                                        .cartData.value.cart_items?.length ??
                                    0) >
                                0) {
                              await controllerFood.submitOrder();
                              controllerFood.resetLoading();
                              await controllerFood.getCart();
                              controllerFood.isLoading.value = false;
                            }
                          },
                          child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 8),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: ConstantColors.primary),
                              child: const Text(
                                'Đặt đơn',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                              )),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  showDialogEitAddress(String text, onSelect, context) {
    final TextEditingController textFieldSearchController =
        TextEditingController();
    final textFieldSearchNode = FocusNode(debugLabel: 'textFieldSearchNode');
    if (text.isNotEmpty) {
      fetchData(text);
      textFieldSearchController.text = text;
    }
    Navigator.of(context).push(CustomSearchLocationView(
        textEditingController: textFieldSearchController,
        isSelectShipmentDestination: true,
        onSelectPlaceFromMap: (locationInfo){
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
  }

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
}

class OrderItemView extends StatefulWidget {
  const OrderItemView(
      {super.key, required this.cartItemData, required this.dataIndex});

  final CartItemData cartItemData;
  final int dataIndex;

  @override
  State<OrderItemView> createState() => _OrderItemViewState();
}

class _OrderItemViewState extends State<OrderItemView> {
  final controllerFood = Get.put(FoodController());
  Timer? _debounceTimer;
  int currentQuantity = 0;
  int defaultQuantity = 0;

  @override
  void initState() {
    currentQuantity = int.parse(widget.cartItemData.quantity ?? '0');
    super.initState();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onFoodNumberChanged(
      String product_id, String store_id, String quantity) {
    if (_debounceTimer != null && _debounceTimer!.isActive) {
      _debounceTimer!.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      controllerFood.isUpdatingQuantity.value = true;
      await controllerFood.updateCart(product_id, store_id, quantity,
          isUpdateCart: true);
      await controllerFood.getCart();
      controllerFood.isUpdatingQuantity.value = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    defaultQuantity = int.parse(widget.cartItemData.quantity ?? '0');
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(color: ConstantColors.dividerColor))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width - 150,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    widget.cartItemData.product?.name ?? "",
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    widget.cartItemData.product?.description ?? "",
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                        color: Colors.black),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    Constant().amountShow(
                        amount: widget.cartItemData.product?.price ?? ""),
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black, width: 1)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.edit, size: 16, color: Colors.black),
                        const SizedBox(
                          width: 4,
                        ),
                        InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AddNoteDialog(initText: widget.cartItemData.notes, title: "Thêm ghi chú",);
                              },
                            ).then((noteValue) {
                              if(noteValue != null) {
                                controllerFood.updateCart(widget.cartItemData.product?.id ?? '',
                                  widget.cartItemData.product?.storeId ?? '',
                                  '0',
                                  notes: noteValue,
                                  isUpdateCart: true,
                                );
                              }
                            });
                          },
                          child: const Text(
                            'Thêm ghi chú',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                    visible: (widget.cartItemData.notes?.isNotEmpty == true),
                    child: const SizedBox(
                      height: 8,
                    )),
                Visibility(
                  visible: (widget.cartItemData.notes?.isNotEmpty == true),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Ghi chú: ${widget.cartItemData.notes.toString()}',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 70,
                height: 70,
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  color: ConstantColors.primary,
                  image: DecorationImage(
                    fit: BoxFit.fitWidth,
                    image:
                        NetworkImage(widget.cartItemData.product?.image ?? ""),
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 75,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        if (controllerFood.isUpdatingQuantity.value ||
                            currentQuantity == 0) return;
                        setState(() {
                          currentQuantity = currentQuantity - 1;
                        });
                        _onFoodNumberChanged(
                            widget.cartItemData.product?.id ?? '',
                            widget.cartItemData.product?.storeId ?? '',
                            '${currentQuantity - defaultQuantity}');
                      },
                      child: CircleAvatar(
                        backgroundColor: ConstantColors.primary,
                        radius: 10,
                        child: const Icon(Icons.remove,
                            size: 16, color: Colors.white),
                      ),
                    ),
                    Expanded(
                        child: Text(
                      '$currentQuantity',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    )),
                    InkWell(
                      onTap: () {
                        if (controllerFood.isUpdatingQuantity.value) return;
                        setState(() {
                          currentQuantity = currentQuantity + 1;
                        });
                        _onFoodNumberChanged(
                            widget.cartItemData.product?.id ?? '',
                            widget.cartItemData.product?.storeId ?? '',
                            '${currentQuantity - defaultQuantity}');
                      },
                      child: CircleAvatar(
                        backgroundColor: ConstantColors.primary,
                        radius: 10,
                        child: const Icon(Icons.add,
                            size: 16, color: Colors.white),
                      ),
                    )
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
