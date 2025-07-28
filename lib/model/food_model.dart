import 'dart:convert';

class AddressData {
  String? id;
  String? name;
  String? detailAddress;
  double? lat;
  double? lng;

  AddressData({
    this.id,
    this.name,
    this.detailAddress,
    this.lat,
    this.lng,
  });

  AddressData.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    name = json['name'].toString();
    detailAddress = json['detailAddress'].toString();
    lat = json['lat'];
    lng = json['lng'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['detailAddress'] = detailAddress;
    data['lat'] = lat;
    data['lat'] = lat;

    return data;
  }
}

class FoodHomeData {
  List<ProductData>? featute_products;
  List<StoreData>? featute_stores;

  FoodHomeData({
    this.featute_products,
    this.featute_stores,
  });

  FoodHomeData.fromJson(Map<String, dynamic> json) {
    if (json['featute_products'] != null) {
      featute_products = <ProductData>[];
      json['featute_products'].forEach((v) {
        featute_products!.add(ProductData.fromJson(v));
      });
    }
    if (json['featute_stores'] != null) {
      featute_stores = <StoreData>[];
      json['featute_stores'].forEach((v) {
        featute_stores!.add(StoreData.fromJson(v));
      });
    }
  }
}

class CartData {
  String? total;
  StoreData? store;
  List<CartItemData>? cart_items;

  CartData({
    this.total,
    this.store,
    this.cart_items,
  });

  CartData.fromJson(Map<String, dynamic> json) {
    store = (json['store'] == null) ? StoreData() : StoreData.fromJson(json['store']);
    total = json['total'].toString();
    if (json['cart_items'] != null) {
      cart_items = <CartItemData>[];
      json['cart_items'].forEach((v) {
        cart_items!.add(CartItemData.fromJson(v));
      });
    }
  }
}

class CartItemData {
  String? id;
  String? amount;
  String? store_id;
  String? quantity;
  String? notes;
  ProductData? product;

  CartItemData({
    this.id,
    this.amount,
    this.store_id,
    this.quantity,
    this.notes,
    this.product,
  });

  CartItemData.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    amount = json['amount'].toString();
    store_id = json['store_id'].toString();
    quantity = json['quantity'].toString();
    notes = json['notes']?.toString();
    product = ProductData.fromJson(json['product']);
  }
}

class StoreData {
  String? id;
  String? name;
  String? banner;
  String? distance;
  String? latitude;
  String? longitude;
  String? address;

  StoreData({
    this.id,
    this.name,
    this.banner,
    this.distance,
    this.latitude,
    this.longitude,
    this.address,
  });

  StoreData.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    name = json['name'].toString();
    banner = json['banner'].toString();
    distance = json['distance'].toString();
    latitude = json['latitude'].toString();
    longitude = json['longitude'].toString();
    address = json['address'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['banner'] = banner;
    data['distance'] = distance;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['address'] = address;

    return data;
  }
}

class ProductData {
  String? id;
  String? name;
  String? price;
  String? image;
  String? description;
  String? storeId;
  String? distance;
  StoreData? store;

  ProductData({
    this.id,
    this.name,
    this.price,
    this.image,
    this.description,
    this.storeId,
    this.distance,
    this.store,
  });

  ProductData.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    name = json['name'].toString();
    price = json['price'].toString();
    image = json['image'].toString();
    description = json['description'].toString();
    storeId = json['store_id'].toString();
    distance = json['distance'].toString();
    if (json['store'] != null) store = StoreData.fromJson(json['store']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['price'] = price;
    data['image'] = image;
    data['description'] = description;
    data['distance'] = distance;
    data['store'] = store;
    data['store_id'] = storeId;

    return data;
  }
}

class SubmitOrdersInput {
  String lat1;
  String lng1;
  String lat2;
  String lng2;
  String shopAddress;
  String userAddress;
  List<Product> products;

  SubmitOrdersInput({
    required this.lat1,
    required this.lng1,
    required this.lat2,
    required this.lng2,
    required this.shopAddress,
    required this.userAddress,
    required this.products,
  });

  factory SubmitOrdersInput.fromJson(Map<String, dynamic> json) => SubmitOrdersInput(
    lat1: json["lat1"],
    lng1: json["lng1"],
    lat2: json["lat2"],
    lng2: json["lng2"],
    shopAddress: json["shop_address"],
    userAddress: json["user_address"],
    products: List<Product>.from(json["products"].map((x) => Product.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "lat1": lat1,
    "lng1": lng1,
    "lat2": lat2,
    "lng2": lng2,
    "shop_address": shopAddress,
    "user_address": userAddress,
    "products": List<dynamic>.from(products.map((x) => x.toJson())),
  };
}

class Product {
  String productId;
  String storeId;
  String quantity;
  String price;
  String? notes;
  String? name;
  String? image;
  String? id;
  String? description;

  Product({
    required this.productId,
    required this.storeId,
    required this.quantity,
    required this.price,
    this.notes,
    this.name,
    this.image,
    this.id,
    this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    productId: json["product_id"].toString(),
    storeId: json["store_id"].toString(),
    quantity: json["quantity"].toString(),
    price: json["price"].toString(),
    notes: json["notes"]?.toString(),
    name: json["name"]?.toString(),
    image: json["image"]?.toString(),
    id: json["id"]?.toString(),
    description: json["description"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "product_id": productId,
    "store_id": storeId,
    "quantity": quantity,
    "price": price,
    "notes": notes,
    "name": name,
    "image": image,
    "id": id,
    "description": description,
  };
}

List<HistoryOrder> historyOrdersFromJson(String str) => List<HistoryOrder>.from(json.decode(str).map((x) => HistoryOrder.fromJson(x)));

String historyOrdersToJson(List<HistoryOrder> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class HistoryOrder {
  int id;
  String code;
  String lat1;
  String lng1;
  String lat2;
  String lng2;
  String shopAddress;
  String userAddress;
  int storeId;
  int userAppId;
  String status;
  String paymentStatus;
  dynamic deletedAt;
  DateTime createdAt;
  DateTime updatedAt;
  String total;
  Store store;

  HistoryOrder({
    required this.id,
    required this.code,
    required this.lat1,
    required this.lng1,
    required this.lat2,
    required this.lng2,
    required this.shopAddress,
    required this.userAddress,
    required this.storeId,
    required this.userAppId,
    required this.status,
    required this.paymentStatus,
    required this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.total,
    required this.store,
  });

  factory HistoryOrder.fromJson(Map<String, dynamic> json) => HistoryOrder(
    id: json["id"],
    code: json["code"],
    lat1: json["lat1"],
    lng1: json["lng1"],
    lat2: json["lat2"],
    lng2: json["lng2"],
    shopAddress: json["shop_address"],
    userAddress: json["user_address"],
    storeId: json["store_id"],
    userAppId: json["user_app_id"],
    status: json["status"],
    paymentStatus: json["payment_status"],
    deletedAt: json["deleted_at"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    total: json["total"].toString(),
    store: Store.fromJson(json["store"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "code": code,
    "lat1": lat1,
    "lng1": lng1,
    "lat2": lat2,
    "lng2": lng2,
    "shop_address": shopAddress,
    "user_address": userAddress,
    "store_id": storeId,
    "user_app_id": userAppId,
    "status": status,
    "payment_status": paymentStatus,
    "deleted_at": deletedAt,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "total": total,
    "store": store.toJson(),
  };
}

class Store {
  int id;
  String name;
  String owner;
  String phoneNumber;
  String banner;
  String address;
  int latitude;
  int longitude;
  int cityId;
  int status;
  int isFeatured;
  dynamic deletedAt;
  DateTime createdAt;
  DateTime updatedAt;

  Store({
    required this.id,
    required this.name,
    required this.owner,
    required this.phoneNumber,
    required this.banner,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.cityId,
    required this.status,
    required this.isFeatured,
    required this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Store.fromJson(Map<String, dynamic> json) => Store(
    id: json["id"],
    name: json["name"],
    owner: json["owner"],
    phoneNumber: json["phone_number"],
    banner: json["banner"],
    address: json["address"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    cityId: json["city_id"],
    status: json["status"],
    isFeatured: json["is_featured"],
    deletedAt: json["deleted_at"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "owner": owner,
    "phone_number": phoneNumber,
    "banner": banner,
    "address": address,
    "latitude": latitude,
    "longitude": longitude,
    "city_id": cityId,
    "status": status,
    "is_featured": isFeatured,
    "deleted_at": deletedAt,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}

DetailOrder detailOrderFromJson(String str) => DetailOrder.fromJson(json.decode(str));

String detailOrderToJson(DetailOrder data) => json.encode(data.toJson());

class DetailOrder {
  int id;
  String code;
  String lat1;
  String lng1;
  String lat2;
  String lng2;
  String shopAddress;
  String userAddress;
  int storeId;
  int userAppId;
  String status;
  String paymentStatus;
  dynamic deletedAt;
  DateTime createdAt;
  DateTime updatedAt;
  Store store;
  List<OrderItem> orderItems;

  DetailOrder({
    required this.id,
    required this.code,
    required this.lat1,
    required this.lng1,
    required this.lat2,
    required this.lng2,
    required this.shopAddress,
    required this.userAddress,
    required this.storeId,
    required this.userAppId,
    required this.status,
    required this.paymentStatus,
    required this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.store,
    required this.orderItems,
  });

  factory DetailOrder.fromJson(Map<String, dynamic> json) => DetailOrder(
    id: json["id"],
    code: json["code"],
    lat1: json["lat1"],
    lng1: json["lng1"],
    lat2: json["lat2"],
    lng2: json["lng2"],
    shopAddress: json["shop_address"],
    userAddress: json["user_address"],
    storeId: json["store_id"],
    userAppId: json["user_app_id"],
    status: json["status"],
    paymentStatus: json["payment_status"],
    deletedAt: json["deleted_at"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    store: Store.fromJson(json["store"]),
    orderItems: List<OrderItem>.from(json["order_items"].map((x) => OrderItem.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "code": code,
    "lat1": lat1,
    "lng1": lng1,
    "lat2": lat2,
    "lng2": lng2,
    "shop_address": shopAddress,
    "user_address": userAddress,
    "store_id": storeId,
    "user_app_id": userAppId,
    "status": status,
    "payment_status": paymentStatus,
    "deleted_at": deletedAt,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "store": store.toJson(),
    "order_items": List<dynamic>.from(orderItems.map((x) => x.toJson())),
  };
}

class OrderItem {
  int id;
  int orderId;
  int productId;
  int storeId;
  int quantity;
  int price;
  int total;
  DateTime createdAt;
  DateTime updatedAt;
  Product product;
  String? notes;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.storeId,
    required this.quantity,
    required this.price,
    required this.total,
    required this.createdAt,
    required this.updatedAt,
    required this.product,
    this.notes,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    id: json["id"],
    orderId: json["order_id"],
    productId: json["product_id"],
    storeId: json["store_id"],
    quantity: json["quantity"],
    price: json["price"],
    total: json["total"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    product: Product.fromJson(json["product"]),
    notes: json["notes"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_id": orderId,
    "product_id": productId,
    "store_id": storeId,
    "quantity": quantity,
    "price": price,
    "total": total,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "product": product.toJson(),
    "product": notes,
  };
}
