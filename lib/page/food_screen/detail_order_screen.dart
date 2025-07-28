
import 'package:citgroupvn_car/constant/constant.dart';
import 'package:citgroupvn_car/themes/constant_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:intl/intl.dart';

import '../../controller/food_controller.dart';
import '../../model/food_model.dart';

class DetailOrderScreen extends StatefulWidget {
  const DetailOrderScreen({super.key, required this.detailOrder});
  final DetailOrder? detailOrder;

  @override
  State<DetailOrderScreen> createState() => _DetailOrderScreenState();
}

class _DetailOrderScreenState extends State<DetailOrderScreen> {
  final controllerFood = Get.put(FoodController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thông tin đơn hàng',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: ConstantColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// Ngay tao don
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text(
                      'Ngày tạo đơn',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black),
                    ),
                    Expanded(child: Text(
                      widget.detailOrder?.createdAt != null ? formatDate(widget.detailOrder!.createdAt) : '',
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: Colors.black
                      ),
                    ))
                  ],
                ),
              ),
              /// Chi tiet giao hang
              const SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Chi tiết giao hàng',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 16,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 30,
                    height: 74,
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      image: DecorationImage(
                        fit: BoxFit.fitWidth,
                        image: AssetImage('assets/images/shipment_detail.png'),
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Địa chỉ nhà hàng',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black)),
                          const SizedBox(height: 4,),
                          SizedBox(
                            width: Get.width - 72,
                            child: Text(
                              '${widget.detailOrder?.shopAddress}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 8,),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Địa chỉ giao hàng',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black)),
                          const SizedBox(height: 4,),
                          SizedBox(
                            width: Get.width - 72,
                            child: Text(
                              '${widget.detailOrder?.userAddress}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          )
                        ],
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 8,),
              /// ListView Builder
              controllerFood.isLoading.value
                  ? Constant.loader()
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.detailOrder?.orderItems.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  return DetailOrderItemView(
                    orderItem: widget.detailOrder?.orderItems.elementAt(index),
                  );
                },
              ),
              /// Tong
              const SizedBox(height: 8,),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  children: [
                    const Text(
                      'Tổng cộng',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.black),
                    ),
                    Expanded(child: Text(
                      Constant().amountShow(
                          amount: controllerFood.getHistoryTotalAmount(
                              widget.detailOrder?.orderItems).toString()),
                      textAlign: TextAlign.end,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ConstantColors.primary
                      ),
                    ))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  String formatDate(DateTime dateTime) {
    String dayOfWeek = convertDayOfWeek(dateTime.weekday);

    var formattedDate =
        '$dayOfWeek, '
        '${dateTime.day.toString().padLeft(2,'0')} '
        'tháng ${dateTime.month.toString().padLeft(2,'0')},'
        ' ${dateTime.hour.toString().padLeft(2,'0')}:${dateTime.minute.toString().padLeft(2,'0')}';
    return formattedDate;
  }

  String convertDayOfWeek(int day) {
    switch (day) {
      case DateTime.monday:
        return 'Thứ hai';
      case DateTime.tuesday:
        return 'Thứ ba';
      case DateTime.wednesday:
        return 'Thứ tư';
      case DateTime.thursday:
        return 'Thứ năm';
      case DateTime.friday:
        return 'Thứ sáu';
      case DateTime.saturday:
        return 'Thứ bảy';
      case DateTime.sunday:
        return 'Chủ nhật';
      default:
        return '';
    }
  }
}

class DetailOrderItemView extends StatelessWidget {
  DetailOrderItemView({super.key, required this.orderItem});

  final OrderItem? orderItem;
  final controllerFood = Get.put(FoodController());

  @override
  Widget build(BuildContext context) {
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
                    orderItem?.product.name ?? "",
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
                const SizedBox(height: 8,),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    orderItem?.product.description ?? "",
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                        color: Colors.black),
                  ),
                ),
                const SizedBox(height: 8,),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    Constant().amountShow(amount: orderItem?.product.price ?? ""),
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
                // const SizedBox(height: 8,),
                // Container(
                //   decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(16),
                //       border: Border.all(
                //           color: Colors.black, width: 1)),
                //   child: const Padding(
                //     padding: EdgeInsets.symmetric(
                //         horizontal: 8, vertical: 4),
                //     child: Row(
                //       mainAxisSize: MainAxisSize.min,
                //       children: [
                //         Icon(Icons.edit, size: 16, color: Colors.black),
                //         SizedBox(width: 4,),
                //         Text(
                //           'Thay đổi',
                //           style: TextStyle(
                //               color: Colors.black,
                //               fontSize: 12,
                //               fontWeight: FontWeight.w500),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                Visibility(
                    visible: (orderItem?.product.notes?.isNotEmpty == true),
                    child: const SizedBox(
                      height: 8,
                    )),
                Visibility(
                  visible: (orderItem?.product.notes?.isNotEmpty == true),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Ghi chú: ${orderItem?.product.notes?.toString()}',
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
                    image: NetworkImage(orderItem?.product.image ?? ""),
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
