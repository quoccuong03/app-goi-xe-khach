class LocationInfo {
  const LocationInfo({
    required this.lat,
    required this.lng,
    required this.addressName,
    required this.detailAddress,
  });

  final double lat;
  final double lng;
  final String addressName;
  final String detailAddress;
}
