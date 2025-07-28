class OtherServicesModel {
  String success;
  dynamic error;
  List<OtherServiceData> data;

  OtherServicesModel({
    required this.success,
    required this.error,
    required this.data,
  });

  factory OtherServicesModel.fromJson(Map<String, dynamic> json) => OtherServicesModel(
    success: json["success"],
    error: json["error"],
    data: List<OtherServiceData>.from(json["data"].map((x) => OtherServiceData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "error": error,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class OtherServiceData {
  int id;
  String name;
  String iconService;
  String link;

  OtherServiceData({
    required this.id,
    required this.name,
    required this.iconService,
    required this.link,
  });

  factory OtherServiceData.fromJson(Map<String, dynamic> json) => OtherServiceData(
    id: json["id"],
    name: json["name"],
    iconService: json["icon_service"],
    link: json["link"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "icon_service": iconService,
    "link": link,
  };
}
