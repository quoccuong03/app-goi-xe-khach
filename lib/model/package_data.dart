class PackageModel {
  String? success;
  String? error;
  String? message;
  List<PackageData>? data;

  PackageModel({this.success, this.error, this.message, this.data});

  PackageModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    error = json['error'];
    message = json['message'];
    if (json['data'] != null) {
      data = <PackageData>[];
      json['data'].forEach((v) {
        data!.add(PackageData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['error'] = error;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PackageData {
  String? id;
  String? name;
  String? totalDay;
  String? totalRequest;
  String? price;

  PackageData({
    this.id,
    this.name,
    this.totalDay,
    this.totalRequest,
    this.price,
  });

  PackageData.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    name = json['name'].toString();
    totalDay = json['total_days'].toString();
    totalRequest = json['total_requests'].toString();
    price = json['price'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['total_days'] = totalDay;
    data['total_requests'] = totalRequest;
    data['price'] = price;

    return data;
  }
}
