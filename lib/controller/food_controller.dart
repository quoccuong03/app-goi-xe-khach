import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:citgroupvn_car/constant/show_toast_dialog.dart';
import 'package:citgroupvn_car/model/food_model.dart';
import 'package:citgroupvn_car/model/user_model.dart';
import 'package:citgroupvn_car/service/api.dart';
import 'package:citgroupvn_car/utils/Preferences.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:http/http.dart' as http;

import 'package:geocoding/geocoding.dart' as get_cord_address;
import 'package:location/location.dart';

class FoodController extends GetxController {
  var isLoading = true.obs;
  var address = AddressData().obs;
  var productList = <ProductData>[].obs;
  var places = <dynamic>[].obs;
  var dataHome = FoodHomeData(featute_products: [], featute_stores: []).obs;
  var cartData = CartData(cart_items: [], total: '0', store: StoreData()).obs;
  RxBool isUpdatingQuantity = false.obs;
  List<HistoryOrder> historyOrders = <HistoryOrder>[].obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<dynamic> resetLoading() async {
    isLoading.value = true;
  }

  int getFoodNumber() {
    var number = 0;
    cartData.value.cart_items?.forEach((data) {
      number += int.parse(data.quantity ?? '0');
    });
    return number;
  }

  double getTotalAmount() {
    var amount = 0.0;
    cartData.value.cart_items?.forEach((data) {
      amount += int.parse(data.amount ?? '0');
    });
    return amount;
  }

  double getHistoryTotalAmount(List<OrderItem>? orderItem) {
    var amount = 0.0;
    orderItem?.forEach((data) {
      amount += data.total;
    });
    return amount;
  }

  UserModel? userModel;
  getCurrentLocation() async {
    try {
      LocationData location = await Location().getLocation();
      print('LOCATION: ${location}');
      List<get_cord_address.Placemark> placeMarks =
          await get_cord_address.placemarkFromCoordinates(
              location.latitude ?? 0.0, location.longitude ?? 0.0);

      final addressDetail = (placeMarks.first.street!.isEmpty
          ? 'Chọn điểm giao hàng'
          : "${placeMarks.first.street} ");
      final detailAddress = (placeMarks.first.subLocality!.isEmpty
              ? ''
              : "${placeMarks.first.subLocality}, ") +
          (placeMarks.first.street!.isEmpty
              ? ''
              : "${placeMarks.first.street}, ") +
          (placeMarks.first.name!.isEmpty ? '' : "${placeMarks.first.name}, ") +
          (placeMarks.first.subAdministrativeArea!.isEmpty
              ? ''
              : "${placeMarks.first.subAdministrativeArea}, ") +
          (placeMarks.first.administrativeArea!.isEmpty
              ? ''
              : "${placeMarks.first.administrativeArea}, ") +
          (placeMarks.first.country!.isEmpty
              ? ''
              : "${placeMarks.first.country}, ") +
          (placeMarks.first.postalCode!.isEmpty
              ? ''
              : "${placeMarks.first.postalCode}, ");
      address.value = AddressData(
          lat: location.latitude ?? 0.0,
          lng: location.longitude ?? 0.0,
          name: addressDetail,
          detailAddress: detailAddress);
    } catch (e) {
      log("->4$e");
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
  }

  Future<dynamic> getHome(String? searchText) async {
    try {
      final response = await client.get(
          Uri.parse(
              '${API.foodProducts}${searchText!.isNotEmpty ? '?keyword=' + (searchText ?? '') : ''}'),
          headers: API.header);
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        FoodHomeData model = FoodHomeData.fromJson(responseBody['data']);
        dataHome.value = model;
        isLoading.value = false;
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
        isLoading.value = false;
      } else {
        isLoading.value = false;
        ShowToastDialog.showToast('Đã có lỗi xảy ra vui lòng thử lại sau!');
      }
    } on TimeoutException catch (e) {
      log("->1${e.message}");
      isLoading.value = false;
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      log("->2${e.message}");

      isLoading.value = false;
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      log("->3$e");

      isLoading.value = false;
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      log("->4$e");
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  Future<dynamic> getStoreDetail(String id) async {
    try {
      final response = await client
          .get(Uri.parse('${API.stores}/${id}/products'), headers: API.header);
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        List<ProductData> model = [];

        responseBody['data'].forEach((i) => model.add(ProductData.fromJson(i)));
        print('MODEL: ${model}');
        productList.value = model;
        isLoading.value = false;
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
        isLoading.value = false;
      } else {
        isLoading.value = false;
        ShowToastDialog.showToast('Đã có lỗi xảy ra vui lòng thử lại sau!');
      }
    } on TimeoutException catch (e) {
      log("->1${e.message}");
      isLoading.value = false;
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      log("->2${e.message}");

      isLoading.value = false;
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      log("->3$e");

      isLoading.value = false;
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      log("->4$e");
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  Future<dynamic> updateCart(
      String product_id, String store_id, String quantity,
      {bool isUpdateCart = false, String notes = ""}) async {
    try {
      ShowToastDialog.showLoader(isUpdateCart
          ? 'Đang cập nhật giỏ hàng'
          : 'Đang thêm sản phẩm vào giỏ hàng');
      List<dynamic> cartDataTemp = [];
      if (cartData.value.store!.id == null ||
          cartData.value.cart_items!.isEmpty ||
          cartData.value.store!.id != store_id) {
        cartDataTemp = [
          {
            "product_id": product_id,
            "store_id": store_id,
            "quantity": quantity,
            "notes": notes
          }
        ];
      } else {
        cartData.value.cart_items?.forEach((element) {
          cartDataTemp.add({
            "product_id": element.product?.id,
            "store_id": element.store_id,
            "quantity": element.quantity,
            "notes": element.notes,
          });
        });
        if (cartDataTemp.any((i) => i['product_id'] == product_id)) {
          cartDataTemp.forEach((i) {
            if (i['product_id'] == product_id) {
              int currentQuantity = int.parse(i['quantity'] ?? '0');
              i['quantity'] =
                  (currentQuantity + int.parse(quantity)).toString();
              i['notes'] = notes;
            }
          });
        } else {
          cartDataTemp.add({
            "product_id": product_id,
            "store_id": store_id,
            "quantity": quantity,
            "note": notes
          });
        }
      }
      var bodyParams = {"cartData": cartDataTemp};
      final response = await client.post(Uri.parse(API.updateCart),
          headers: API.header, body: jsonEncode(bodyParams));
      Map<String, dynamic> responseBody = json.decode(response.body);
      ShowToastDialog.closeLoader();
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        ShowToastDialog.showToast(isUpdateCart
            ? 'Giỏ hàng đã được cập nhật'
            : 'Sản phẩm đã được thêm vào giỏ hàng');
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
      } else {
        ShowToastDialog.showToast('Đã có lỗi xảy ra vui lòng thử lại sau!');
      }
    } on TimeoutException catch (e) {
      log("->1${e.message}");
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      log("->2${e.message}");

      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      log("->3$e");

      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      log("->4$e");
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    await getCart();
    return null;
  }

  Future<dynamic> submitOrder() async {
    var listProduct = cartData.value.cart_items?.map((item) {
          return Product(
              productId: item.product?.id ?? "",
              storeId: item.store_id ?? "",
              quantity: item.quantity ?? "",
              price: item.product?.price ?? "",
              notes: item.notes);
        }).toList() ??
        [];
    SubmitOrdersInput submitOrdersInput = SubmitOrdersInput(
      lat1: cartData.value.store?.latitude ?? "",
      lng1: cartData.value.store?.longitude ?? "",
      lat2: address.value.lat?.toString() ?? "",
      lng2: address.value.lng?.toString() ?? "",
      shopAddress: cartData.value.store?.address ?? "",
      userAddress: address.value.detailAddress ?? "",
      products: listProduct,
    );
    try {
      ShowToastDialog.showLoader('Đang đặt đơn');
      log('submitOrdersInput = ${jsonEncode(submitOrdersInput.toJson())}');

      final response = await client.post(Uri.parse(API.submitOrder),
          headers: API.header, body: jsonEncode(submitOrdersInput.toJson()));
      Map<String, dynamic> responseBody = json.decode(response.body);
      ShowToastDialog.closeLoader();
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        ShowToastDialog.showToast('Đã đặt đơn thành công');
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
      } else {
        ShowToastDialog.showToast('Đã có lỗi xảy ra vui lòng thử lại sau!');
      }
    } on TimeoutException catch (e) {
      log("->1${e.message}");
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      log("->2${e.message}");

      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      log("->3$e");

      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      log("->4$e");
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    await getCart();
    return null;
  }

  Future<dynamic> submitOrderAgain(DetailOrder detailOrder) async {
    var listProduct = detailOrder.orderItems.map((item) {
      return Product(
        productId: item.product.id ?? "",
        storeId: item.storeId.toString(),
        quantity: item.quantity.toString(),
        price: item.product.price,
      );
    }).toList();
    SubmitOrdersInput submitOrdersInput = SubmitOrdersInput(
      lat1: detailOrder.lat1,
      lng1: detailOrder.lng1,
      lat2: detailOrder.lat2,
      lng2: detailOrder.lng2,
      shopAddress: detailOrder.shopAddress,
      userAddress: detailOrder.userAddress,
      products: listProduct,
    );
    try {
      ShowToastDialog.showLoader('Đang đặt đơn');

      final response = await client.post(Uri.parse(API.submitOrder),
          headers: API.header, body: jsonEncode(submitOrdersInput.toJson()));
      Map<String, dynamic> responseBody = json.decode(response.body);
      ShowToastDialog.closeLoader();
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        ShowToastDialog.showToast('Đã đặt đơn thành công');
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
      } else {
        ShowToastDialog.showToast('Đã có lỗi xảy ra vui lòng thử lại sau!');
      }
    } on TimeoutException catch (e) {
      log("->1${e.message}");
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      log("->2${e.message}");

      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      log("->3$e");

      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      log("->4$e");
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    await getCart();
    return null;
  }

  Future<dynamic> getCart() async {
    try {
      final response =
          await client.get(Uri.parse('${API.cart}'), headers: API.header);
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        CartData model = CartData.fromJson(responseBody['data']);
        print('MODEL: ${model}');
        cartData.value = model;
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
      } else {
        ShowToastDialog.showToast('Đã có lỗi xảy ra vui lòng thử lại sau!');
      }
    } on TimeoutException catch (e) {
      log("->1${e.message}");
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      log("->2${e.message}");

      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      log("->3$e");

      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      log("->4$e");
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  Future<dynamic> getListOrders() async {
    try {
      final response =
          await client.get(Uri.parse(API.listOrders), headers: API.header);
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        List<HistoryOrder> historyOrders =
            historyOrdersFromJson(jsonEncode(responseBody['data']));
        this.historyOrders = historyOrders.reversed.toList();
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
      } else {
        ShowToastDialog.showToast('Đã có lỗi xảy ra vui lòng thử lại sau!');
      }
    } on TimeoutException catch (e) {
      log("->1${e.message}");
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      log("->2${e.message}");

      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      log("->3$e");

      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      log("->4$e");
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  Future<DetailOrder?> getDetailOrder(int id) async {
    try {
      ShowToastDialog.showLoader("Vui lòng đợi");
      final response = await client.get(Uri.parse('${API.detailOrder}$id/show'),
          headers: API.header);
      log('getDetailOrder = ${response.body}');
      ShowToastDialog.closeLoader();
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        DetailOrder detailOrder =
            detailOrderFromJson(jsonEncode(responseBody['data']));
        return detailOrder;
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
      } else {
        ShowToastDialog.showToast('Đã có lỗi xảy ra vui lòng thử lại sau!');
      }
    } on TimeoutException catch (e) {
      log("->1${e.message}");
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      log("->2${e.message}");

      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      log("->3$e");

      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      log("->4$e");
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  Future<dynamic> deleteCard() async {
    try {
      final response =
          await client.get(Uri.parse(API.deleteCard), headers: API.header);
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        return null;
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
      } else {
        ShowToastDialog.showToast('Đã có lỗi xảy ra vui lòng thử lại sau!');
      }
    } on TimeoutException catch (e) {
      log("->1${e.message}");
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      log("->2${e.message}");

      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      log("->3$e");

      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      log("->4$e");
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }
}
