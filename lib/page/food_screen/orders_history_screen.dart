import 'dart:developer';

import 'package:citgroupvn_car/constant/constant.dart';
import 'package:citgroupvn_car/themes/constant_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:intl/intl.dart';

import '../../controller/food_controller.dart';
import '../../model/food_model.dart';

import 'detail_order_screen.dart';

class OrdersHistoryScreen extends StatefulWidget {
  const OrdersHistoryScreen({super.key});

  @override
  State<OrdersHistoryScreen> createState() => _OrdersHistoryScreenState();
}

class _OrdersHistoryScreenState extends State<OrdersHistoryScreen> {
  final controllerFood = Get.put(FoodController());

  @override
  Widget build(BuildContext context) {
    return GetX<FoodController>(
      init: FoodController(),
      initState: (state) async {
        controllerFood.resetLoading();
        await controllerFood.getListOrders();
        controllerFood.isLoading.value = false;
      },
      builder: (controllerFood) {
        return Scaffold(
          // appBar: AppBar(
          //   title: const Text(
          //     'Lịch sử đơn hàng',
          //     style: TextStyle(
          //         color: Colors.white,
          //         fontWeight: FontWeight.w600,
          //         fontSize: 18),
          //   ),
          //   backgroundColor: ConstantColors.primary,
          //   iconTheme: const IconThemeData(color: Colors.white),
          // ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                controllerFood.getListOrders();
                return await Future<void>.delayed(const Duration(milliseconds: 500));
              },
              child: Column(
                children: [
                  /// ListView Builder
                  Expanded(
                    child: controllerFood.isLoading.value
                        ? Constant.loader()
                        : (controllerFood.historyOrders.isEmpty)
                            ? Constant.empty()
                            : ListView.builder(
                                itemCount:
                                    controllerFood.historyOrders.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return InkWell(
                                    onTap: () async {
                                      /// show Detail Screen
                                      var detailOrderResult =
                                          await controllerFood.getDetailOrder(
                                              controllerFood.historyOrders
                                                  .elementAt(index)
                                                  .id);
                                      if (detailOrderResult != null) {
                                        Get.to(DetailOrderScreen(
                                          detailOrder: detailOrderResult,
                                        ));
                                      }
                                    },
                                    child: HistoryItemView(
                                      historyOrder: controllerFood.historyOrders
                                          .elementAt(index),
                                    ),
                                  );
                                },
                              ),
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

class HistoryItemView extends StatelessWidget {
  HistoryItemView(
      {super.key, required this.historyOrder});

  final HistoryOrder historyOrder;
  final controllerFood = Get.put(FoodController());

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: ConstantColors.dividerColor)
        )
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          SizedBox(
              width: double.infinity,
              child:
              Text(DateFormat("dd/MM/yyyy").format(historyOrder.updatedAt),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),)),
          const SizedBox(height: 16,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                decoration: (historyOrder.store.banner.isNotEmpty == true)
                    ? BoxDecoration(
                        color: ConstantColors.primary,
                        image: DecorationImage(
                          fit: BoxFit.fitWidth,
                          image: NetworkImage(historyOrder.store.banner),
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8.0),
                        ),
                      )
                    : BoxDecoration(color: ConstantColors.primary),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        historyOrder.store.name,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      const SizedBox(height: 4,),
                      Text(
                        historyOrder.store.owner,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: Colors.black),
                      ),
                      const SizedBox(height: 4,),
                      Row(
                        children: <Widget>[
                          historyOrder.status == "Đã hủy" ?
                          const Icon(Icons.close, size: 16, color: Colors.red)
                          : const Icon(Icons.check, size: 16, color: Colors.green),
                          const SizedBox(width: 4,),
                          Text(
                            historyOrder.status,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    Constant().amountShow(
                        amount: historyOrder.total),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black
                    ),),
                  const SizedBox(height: 16,),
                  // InkWell(
                  //   onTap: () {
                  //     _showMyDialog(context);
                  //   },
                  //   child: Container(
                  //     padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  //     decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(16),
                  //       color: ConstantColors.primary,
                  //     ),
                  //     child: const Text('Đặt lại', style: TextStyle(
                  //       fontSize: 12,
                  //       fontWeight: FontWeight.bold,
                  //       color: Colors.white,
                  //     ),),
                  //   ),
                  // )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showMyDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Đặt lại đơn'),
          alignment: Alignment.center,
          content: const SingleChildScrollView(
            child: Text("Bạn có muốn đặt lại đơn hàng không?"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Hủy',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Có',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: (){},
            ),
          ],
        );
      },
    );
  }
}

