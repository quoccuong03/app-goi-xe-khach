class BannerModel {
  String? success;
  String? error;
  String? message;
  List<BannerData>? data;

  BannerModel({this.success, this.error, this.message, this.data});

  BannerModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    error = json['error'];
    message = json['message'];
    if (json['data'] != null) {
      data = <BannerData>[];
      json['data'].forEach((v) {
        data!.add(BannerData.fromJson(v));
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

class BannerData {
  String? id;
  String? name;
  String? bannerUrl;
  String? link;

  BannerData({
    this.id,
    this.name,
    this.link,
    this.bannerUrl,
  });

  BannerData.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    name = json['name'].toString();
    link = json['link'].toString();
    bannerUrl = json['banner_url'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['link'] = link;
    data['banner_url'] = bannerUrl;

    return data;
  }
}
