import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:citgroupvn_car/model/location_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:location/location.dart';
import '../../constant/constant.dart';
import '../../constant/show_toast_dialog.dart';
import '../../service/api.dart';
import '../../themes/constant_colors.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart' as get_cord_address;

import '../home_screens/custom_search_location_screen.dart';

class ChooseLocationFromMapScreen extends StatefulWidget {
  const ChooseLocationFromMapScreen({super.key});

  @override
  State<ChooseLocationFromMapScreen> createState() => _ChooseLocationFromMapScreenState();
}

class _ChooseLocationFromMapScreenState
    extends State<ChooseLocationFromMapScreen> with TickerProviderStateMixin {
  final MapController _controller = MapController();
  final double _initZoom = 14.0;
  List<LatLng> polylinePoints = [];
  final Map<String, Marker> _markers = {};
  LatLng _referencePoint = LatLng(20.989519, 105.807129);
  LatLng _centerTargetPoint = LatLng(20.989519, 105.807129);
  final TextEditingController targetTextController = TextEditingController();
  String firstAddress = '';
  String detailAddress = '';
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  static const _startedId = 'AnimatedMapController#MoveStarted';
  static const _inProgressId = 'AnimatedMapController#MoveInProgress';
  static const _finishedId = 'AnimatedMapController#MoveFinished';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 70),
                    child: FlutterMap(
                      mapController: _controller,
                      options: MapOptions(
                          center: _centerTargetPoint,
                          zoom: _initZoom,
                          minZoom: 10,
                          maxZoom: 17,
                          onPositionChanged: (mapPosition, bool _) {
                            setState(() {
                              if(_centerTargetPoint != mapPosition.center && mapPosition.center != null) {
                                _centerTargetPoint = mapPosition.center!;
                                setMarker();
                                _onCenterPointChanged(mapPosition.center!);
                              }
                            });
                          },
                          onMapReady: () async {
                            await getCurrentLocation();
                          }),
                      children: [
                        TileLayer(
                          urlTemplate:
                          "https://api.mapbox.com/styles/v1/devteam2024/clvqqelwb01pf01qrgydg4inx/tiles/256/{z}/{x}/{y}@2x?access_token=${Constant.mapBoxAccessToken}",
                          additionalOptions: const {
                            'accessToken': Constant.mapBoxAccessToken,
                            'id': 'mapbox.mapbox-streets-v8'
                          },
                        ),
                        MarkerLayer(markers: _markers.values.toList()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(16),
                          topLeft: Radius.circular(16)
                      ),
                    color: Colors.white
                  ),
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: ConstantColors.primary,
                              ),
                              padding: const EdgeInsets.all(5),
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16,),
                            Column(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width - 90,
                                  child: Text(
                                    firstAddress,
                                    maxLines: 2,
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width - 90,
                                  child: Text(
                                    (detailAddress.isEmpty) ? "Chưa cập nhật điểm đến" : detailAddress,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          if (detailAddress.isNotEmpty) {
                            Get.back(
                                result: LocationInfo(
                              lat: _centerTargetPoint.latitude,
                              lng: _centerTargetPoint.longitude,
                              addressName: firstAddress,
                              detailAddress: detailAddress,
                            ));
                          } else {
                            ShowToastDialog.showLoader('Vui lòng chọn lại địa điểm');
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: ConstantColors.primary
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          margin: const EdgeInsets.only(bottom: 20, top: 8, left: 16, right: 16),
                          child: const Text('Chọn địa điểm này', textAlign: TextAlign.center, style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              child: SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        InkWell(
                          onTap: (){
                            Get.back();
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            margin: const EdgeInsets.only(left: 8, right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                            ),
                            child: const Center(
                              child: Icon(Icons.arrow_back_ios_outlined,
                                  color: Colors.black),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              showDialogEitAddress(firstAddress);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white,
                              ),
                              margin: const EdgeInsets.only(right: 8.0),
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: TextField(
                                controller: targetTextController,
                                textInputAction: TextInputAction.done,
                                style:
                                    TextStyle(color: ConstantColors.titleTextColor),
                                decoration: const InputDecoration(
                                  hintText: 'Chọn điểm tham chiếu',
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabled: false,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  showDialogEitAddress(String text) {
    final TextEditingController textFieldSearchController =
    TextEditingController();
    if (text.isNotEmpty) {
      textFieldSearchController.text = text;
    }
    Navigator.of(context).push(CustomSearchLocationView(
        textEditingController: textFieldSearchController,
        isSelectLocationFromMap: true,
        onSelectPlaceFromMap: (locationInfo) {},
        onStartAndIgnoreDestination: () {},
        onSelectedPlace: (coordinate) async {
          if (coordinate == null) return;
          var placeId = coordinate['place_id'];
          if (placeId == null || placeId.toString().isEmpty) return;
          try{
            var url = Uri.parse(
                'https://rsapi.goong.io/Place/Detail?place_id=${placeId.toString()}&api_key=${Constant.goongApiKey}');
            var response = await client.get(url);
            final jsonResponse = jsonDecode(response.body);
            var name = jsonResponse['result']['name'].toString();
            var detailName =
            jsonResponse['result']['formatted_address'].toString();
            setState(() {
              _centerTargetPoint = LatLng(
                  jsonResponse['result']['geometry']['location']['lat'],
                  jsonResponse['result']['geometry']['location']['lng']);
              _animatedMapMove(_centerTargetPoint, null);
              _referencePoint = _centerTargetPoint;
              targetTextController.text = name;
              firstAddress = name;
              detailAddress = detailName;
              setMarker();
            });
          } catch(e) {
            log('error = $e');
          }
        }));
  }

  void _animatedMapMove(LatLng destLocation, double? destZoom) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final latTween = Tween<double>(
        begin: _controller.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: _controller.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(
        begin: _controller.zoom, end: destZoom ?? _controller.zoom);

    // Create a animation controller that has a duration and a TickerProvider.
    final controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    final Animation<double> animation =
    CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    // Note this method of encoding the target destination is a workaround.
    // When proper animated movement is supported (see #1263) we should be able
    // to detect an appropriate animated movement event which contains the
    // target zoom/center.
    final startIdWithTarget =
        '$_startedId#${destLocation.latitude},${destLocation.longitude},$destZoom';
    bool hasTriggeredMove = false;

    controller.addListener(() {
      final String id;
      if (animation.value == 1.0) {
        id = _finishedId;
      } else if (!hasTriggeredMove) {
        id = startIdWithTarget;
      } else {
        id = _inProgressId;
      }

      hasTriggeredMove |= _controller.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
        id: id,
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  getCurrentLocation() async {
    ShowToastDialog.showLoader("Vui lòng đợi");
    LocationData location = await Location().getLocation();
    List<get_cord_address.Placemark> placeMarks =
        await get_cord_address.placemarkFromCoordinates(
            location.latitude ?? 0.0, location.longitude ?? 0.0);

    setAddressName(placeMarks);
    _referencePoint =
        LatLng(location.latitude ?? 0.0, location.longitude ?? 0.0);
    _centerTargetPoint = _referencePoint;
    setMarker();
    ShowToastDialog.closeLoader();
  }

  void _onCenterPointChanged(LatLng centerLocation) {
    if (_debounceTimer != null && _debounceTimer!.isActive) {
      _debounceTimer!.cancel();
    }
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      ShowToastDialog.showLoader("Vui lòng đợi");
      List<get_cord_address.Placemark> placeMarks =
      await get_cord_address.placemarkFromCoordinates(
          centerLocation.latitude, centerLocation.longitude);
      setAddressName(placeMarks);
      ShowToastDialog.closeLoader();
    });
  }

  setAddressName(List<get_cord_address.Placemark> placeMarks) {
    String firstName =
    // (placeMarks.first.subLocality?.isNotEmpty == true)
    //     ? '${placeMarks.first.subLocality}'
    //     :
    (placeMarks.first.street?.isNotEmpty == true)
        ? '${placeMarks.first.street}'
        : (placeMarks.first.name?.isNotEmpty == true)
        ? '${placeMarks.first.name}'
        : (placeMarks.first.subAdministrativeArea?.isNotEmpty == true)
        ? '${placeMarks.first.subAdministrativeArea}'
        : '';

    String address = (placeMarks.first.subLocality!.isEmpty
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
    setState(() {
      targetTextController.text = firstName;
      firstAddress = firstName;
      detailAddress = address;
    });
  }

  setMarker() {
    setState(() {
      _markers['Reference'] = Marker(
          point: _referencePoint,
          builder: (context) {
            return Image.asset("assets/icons/pickup.png");
          });

      _markers['CenterTargetPoint'] = Marker(
          point: _centerTargetPoint,
          anchorPos: AnchorPos.align(AnchorAlign.top),
          builder: (context) {
            return const ImageIcon(
                AssetImage("assets/icons/location.png"),
              color: Colors.red,
            );

          });
    });
  }
}
