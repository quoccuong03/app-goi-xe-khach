class NotificationModel {
  String? success;
  String? error;
  String? message;
  List<NotificationData>? data;

  NotificationModel({this.success, this.error, this.message, this.data});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    error = json['error'];
    message = json['message'];
    if (json['data'] != null) {
      data = <NotificationData>[];
      json['data'].forEach((v) {
        data!.add(NotificationData.fromJson(v));
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

class NotificationData {
  String? id;
  String? titre;
  String? message;
  String? creer;
  String? creerModify;

  NotificationData({
    this.id,
    this.titre,
    this.message,
    this.creer,
    this.creerModify,
  });

  NotificationData.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    titre = json['titre'].toString();
    message = json['message'].toString();
    creer = json['creer'].toString();
    creerModify = json['creer_modify'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['titre'] = titre;
    data['message'] = message;
    data['creer'] = creer;
    data['creer_modify'] = creerModify;

    return data;
  }
}
