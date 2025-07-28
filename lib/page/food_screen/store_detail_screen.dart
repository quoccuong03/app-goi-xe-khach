import 'package:citgroupvn_car/constant/constant.dart';
import 'package:citgroupvn_car/controller/food_controller.dart';
import 'package:citgroupvn_car/model/food_model.dart';
import 'package:citgroupvn_car/themes/constant_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoreDetailScreen extends StatelessWidget {
  final StoreData storeData;

  StoreDetailScreen({Key? key, required this.storeData}) : super(key: key);

  final controllerFood = Get.put(FoodController());

  @override
  Widget build(BuildContext context) {
    return GetX<FoodController>(
      init: FoodController(),
      initState: (state) {
        controllerFood.resetLoading();
        controllerFood.getStoreDetail(storeData.id ?? '');
      },
      builder: (controller) {
        return SafeArea(
            child: Scaffold(
          backgroundColor: ConstantColors.background,
          appBar: AppBar(
            backgroundColor: ConstantColors.primary,
            leading: InkWell(
                onTap: () {
                  Get.back();
                },
                child: const Icon(
                  Icons.arrow_back,
                  size: 25,
                  color: Colors.white,
                )),
            title: Text(storeData.name ?? '',
                style: const TextStyle(color: Colors.white)),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              return await Future<void>.delayed(Duration(milliseconds: 100));
            },
            child: SingleChildScrollView(
              child: controller.isLoading.value
                  ? Constant.loader()
                  : Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Color.fromRGBO(242, 242, 242, 1),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.location_on_rounded,
                                        size: 25,
                                        color: Colors.red,
                                      ),
                                      Text(
                                        ' ${storeData.distance ?? ''} km',
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Khoảng cách',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                          ListView.builder(
                            itemCount: controller.productList.length,
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            itemBuilder: (context, index) {
                              return itemProduct(context, controller,
                                  controller.productList[index]);
                            },
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ));
      },
    );
  }

  Widget itemProduct(context, FoodController controller, ProductData data) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey, // Set border color here
            width: 1.0, // Set border width here
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: GestureDetector(
          onTap: () async {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(data.name ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(
                    height: 4,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 150,
                    child: Text(data.description ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: ConstantColors.subTitleTextColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(Constant().amountShow(amount: data.price.toString()),
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
              Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: ConstantColors.primary,
                      image: DecorationImage(
                        fit: BoxFit.fitWidth,
                        image: NetworkImage(data.image as String),
                      ),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  GestureDetector(
                    onTap: () async {
                      controller.updateCart(
                          data.id ?? '', storeData.id ?? '', '1');
                    },
                    child: Container(
                      width: 70,
                      height: 24,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: ConstantColors.primary,
                          width: 2.0,
                        ),
                      ),
                      child: Text('Thêm',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: ConstantColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
