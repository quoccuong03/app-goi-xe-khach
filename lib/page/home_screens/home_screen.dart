import 'dart:convert';
import 'dart:developer';

import 'package:citgroupvn_car/constant/constant.dart';
import 'package:citgroupvn_car/constant/show_toast_dialog.dart';
import 'package:citgroupvn_car/controller/dash_board_controller.dart';
import 'package:citgroupvn_car/controller/home_controller.dart';
import 'package:citgroupvn_car/model/driver_model.dart';
import 'package:citgroupvn_car/model/location_info.dart';
import 'package:citgroupvn_car/model/vehicle_category_model.dart';
import 'package:citgroupvn_car/service/api.dart';
import 'package:citgroupvn_car/themes/button_them.dart';
import 'package:citgroupvn_car/themes/constant_colors.dart';
import 'package:citgroupvn_car/themes/custom_dialog_box.dart';
import 'package:citgroupvn_car/utils/Preferences.dart';
import 'package:citgroupvn_car/widget/StarRating.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart' as get_cord_address;
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'custom_search_location_screen.dart';

final TextEditingController departureController = TextEditingController();

enum InitHomeActionType {
  bookMotorbikeDriver,
  bookCarDriver,
  bookMotorbike,
  bookCar,
  bookDriver,
  bookVehicle,
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.initHomeActionType})
      : super(key: key);

  final InitHomeActionType initHomeActionType;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  static const _startedId = 'AnimatedMapController#MoveStarted';
  static const _inProgressId = 'AnimatedMapController#MoveInProgress';
  static const _finishedId = 'AnimatedMapController#MoveFinished';
  final LatLng _kInitialPosition = LatLng(20.989519, 105.807129);
  final double _initZoom = 14.0;

  final TextEditingController destinationController = TextEditingController();

  final controller = Get.put(HomeController());

  final MapController _mapController = MapController();
  final Location currentLocation = Location();
  late LatLng currentUserPosition;

  final Map<String, Marker> _markers = {};

  LatLng? departureLatLong;
  LatLng? destinationLatLong;
  Location? currentUserLocation;
  late InitHomeActionType currentHomeActionType;

  List<LatLng> polylinePoints = [];

  @override
  void initState() {
    // setIcons();
    controller.multiStopList.clear();
    controller.multiStopListNew.clear();
    controller.confirmWidgetVisible.value = false;
    currentHomeActionType = widget.initHomeActionType;
    super.initState();
  }

  setIcons() async {
    await controller.getTaxiData().then((value) async {
      if (value?.data != null) {
        if (value?.success == "success") {
          for (var element in value!.data!) {
            if (element.latitude != null &&
                element.longitude != null &&
                element.latitude!.isNotEmpty &&
                element.longitude!.isNotEmpty &&
                element.statut == "yes") {
              _markers[element.id.toString()] = Marker(
                  point: LatLng(
                      double.parse(element.latitude.toString().isNotEmpty
                          ? element.latitude.toString()
                          : "0.0"),
                      double.parse(element.longitude.toString().isNotEmpty
                          ? element.longitude.toString()
                          : "0.0")),
                  builder: (context) {
                    return Image.asset("assets/icons/ic_taxi.png");
                  });
            }
          }
        }
      }
    });
    await getCurrentLocation(true);
  }

  showDialogEitAddress(bool isDeparture, String text, onSelect) {
    final TextEditingController textFieldSearchController =
        TextEditingController();
    if (text.isNotEmpty) {
      fetchData(text);
      textFieldSearchController.text = text;
    }
    Navigator.of(context).push(CustomSearchLocationView(
        textEditingController: textFieldSearchController,
        isDeparture: isDeparture,
        onSelectPlaceFromMap: (locationInfo) {
          onSelect(locationInfo);
        },
        onStartAndIgnoreDestination: () async {
          if (departureLatLong == null) {
            ShowToastDialog.showLoader('Chưa cập nhật điểm đón');
            return;
          }
          destinationLatLong = null;
          passengerController.text = '1';
          controller.duration.value = "";
          controller.distance.value = 0;
          polylinePoints = [];
          destinationController.text = "";
          controller.multiStopList = [];
          controller.multiStopListNew = [];
          await chooseVehicle(isRouteWithoutDestination: true);
        },
        onSelectedPlace: (coordinate) async {
          if (coordinate == null) return;
          var placeId = coordinate['place_id'];
          if (placeId == null || placeId.toString().isEmpty) return;
          var url = Uri.parse(
              'https://rsapi.goong.io/Place/Detail?place_id=${placeId.toString()}&api_key=${Constant.goongApiKey}');
          var response = await client.get(url);
          final jsonResponse = jsonDecode(response.body);
          if (jsonResponse != null) {
            double mlat = jsonResponse['result']['geometry']['location']['lat'];
            double mlng = jsonResponse['result']['geometry']['location']['lng'];
            var name = jsonResponse['result']['name'].toString();
            var detailName =
            jsonResponse['result']['formatted_address'].toString();
            onSelect(LocationInfo(
                lat: mlat,
                lng: mlng,
                addressName: name,
                detailAddress: detailName));
          }
        }));
    // return showDialog(
    //   context: context,
    //   barrierDismissible: false,
    //   builder: (BuildContext context) {
    //     FocusScope.of(context).requestFocus(textFieldSearchNode);
    //     return AlertDialog(
    //       title: Text('Enter Address'.tr),
    //       backgroundColor: Colors.white,
    //       surfaceTintColor: Colors.transparent,
    //       buttonPadding: const EdgeInsets.all(0),
    //       shape: RoundedRectangleBorder(
    //         borderRadius: BorderRadius.circular(20.0),
    //       ),
    //       content: Container(
    //         height: 250,
    //         width: MediaQuery.of(context).size.width,
    //         padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
    //         decoration: const BoxDecoration(color: Colors.white),
    //         child: Column(
    //           mainAxisAlignment: MainAxisAlignment.start,
    //           children: [
    //             TextField(
    //               controller: textFieldSearchController,
    //               focusNode: textFieldSearchNode,
    //               onChanged: (text) {
    //                 if (text.isNotEmpty) {
    //                   fetchData(text);
    //                 }
    //               },
    //               decoration: InputDecoration(
    //                 prefixIcon: const Icon(Icons.search),
    //                 counterText: "",
    //                 contentPadding: const EdgeInsets.all(8),
    //                 fillColor: Colors.white,
    //                 filled: true,
    //                 focusedBorder: OutlineInputBorder(
    //                   borderSide: BorderSide(
    //                       color: ConstantColors.textFieldBoarderColor,
    //                       width: 0.7),
    //                 ),
    //                 enabledBorder: OutlineInputBorder(
    //                   borderSide: BorderSide(
    //                       color: ConstantColors.textFieldBoarderColor,
    //                       width: 0.7),
    //                 ),
    //                 errorBorder: OutlineInputBorder(
    //                   borderSide: BorderSide(
    //                       color: ConstantColors.textFieldBoarderColor,
    //                       width: 0.7),
    //                 ),
    //                 border: OutlineInputBorder(
    //                   borderSide: BorderSide(
    //                       color: ConstantColors.textFieldBoarderColor,
    //                       width: 0.7),
    //                 ),
    //                 hintText: "Bạn muốn đi đi đâu ?".tr,
    //                 hintStyle: TextStyle(
    //                   color: ConstantColors.hintTextColor,
    //                 ),
    //               ),
    //             ),
    //             Container(
    //               height: 180,
    //               width: MediaQuery.of(context).size.width - 0,
    //               padding: const EdgeInsets.all(0),
    //               child: _buildListView((value) {
    //                 setState(() {
    //                   places = [];
    //                 });
    //                 Navigator.of(context).pop();
    //                 onSelect(value);
    //                 textFieldSearchController.text = '';
    //               }),
    //             ),
    //           ],
    //         ),
    //       ),
    //       actions: <Widget>[
    //         ButtonThem.buildBorderButton(context,
    //             title: 'cancel'.tr,
    //             btnHeight: 50,
    //             isUpperCase: false,
    //             btnColor: Colors.white,
    //             txtColor: ConstantColors.primary, onPress: () {
    //           Navigator.of(context).pop();
    //           textFieldSearchController.text = '';
    //
    //           setState(() {
    //             places = [];
    //           });
    //         }, btnBorderColor: ConstantColors.primary, btnWidthRatio: 0.3),
    //       ],
    //     );
    //   },
    // );
  }

  Widget _buildListView(onSelect) {
    return ListView.builder(
      itemCount: places.length,
      itemBuilder: (context, index) {
        final coordinate = places[index];

        return ListTile(
          horizontalTitleGap: 5,
          title: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(
                Icons.location_on_outlined,
                color: ConstantColors.primary,
                size: 20,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width - 195,
                child: Text(
                  coordinate['description'],
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: const TextStyle(
                    color: Colors.black54,
                  ),
                ),
              )
            ],
          ),
          onTap: () async {
            final url = Uri.parse(
                'https://rsapi.goong.io/Place/Detail?place_id=${coordinate['place_id']}&api_key=${Constant.goongApiKey}');
            var response = await client.get(url);
            final jsonResponse = jsonDecode(response.body);
            onSelect(jsonResponse);
          },
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<dynamic> places = [];
  Future<void> fetchData(String input) async {
    try {
      final url = Uri.parse(
          'https://rsapi.goong.io/Place/AutoComplete?api_key=${Constant.goongApiKey}&input=$input');

      var response = await client.get(url);

      setState(() {
        final jsonResponse = jsonDecode(response.body);
        places = jsonResponse['predictions'] as List<dynamic>;
      });
    } catch (e) {
      // ignore: avoid_print
      print('$e');
    }
  }

  getCurrentLocation(bool isDepartureSet) async {
    if (isDepartureSet) {
      ShowToastDialog.showLoader("Vui lòng đợi");
      LocationData location = await Location().getLocation();
      List<get_cord_address.Placemark> placeMarks =
          await get_cord_address.placemarkFromCoordinates(
              location.latitude ?? 0.0, location.longitude ?? 0.0);

      final address = (placeMarks.first.subLocality!.isEmpty
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
      departureController.text = address;

      currentUserPosition =
          LatLng(location.latitude ?? 0.0, location.longitude ?? 0.0);
      await setDepartureMarker(currentUserPosition);
      ShowToastDialog.closeLoader();
    }
  }

  clearData() async {
    departureController.clear();
    destinationController.clear();
    polylinePoints = [];
    departureLatLong = null;
    destinationLatLong = null;
    passengerController.clear();
    _markers.clear();
    controller.clearData();
    controller.confirmWidgetVisible.value = false;
    //getDirections();
  }

  @override
  Widget build(BuildContext context) {
    if (currentHomeActionType != widget.initHomeActionType) {
      currentHomeActionType = widget.initHomeActionType;
      clearData();
      setIcons();
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // floatingActionButton: FloatingActionButton(
      //   onPressed: (){
      //     Get.to(PaymentSelectionScreen());
      //   },
      // ),
      backgroundColor: ConstantColors.background,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _kInitialPosition,
              zoom: _initZoom,
              minZoom: 10,
              maxZoom: 17,
              onMapReady: () async {
                await setIcons();
              },
            ),
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
              PolylineLayer(polylines: [
                Polyline(
                    points: polylinePoints,
                    strokeWidth: 5,
                    color: ConstantColors.blueColor)
              ]),
              PopupMarkerLayer(
                  options: PopupMarkerLayerOptions(
                      markers: _markers.values.toList(),
                      popupDisplayOptions: PopupDisplayOptions(
                          builder: (BuildContext context, Marker marker) {
                            if(_markers.isEmpty) return Container();
                            try{
                              var keyMarker = _markers.keys
                                  .firstWhere((key) => _markers[key] == marker);
                              return Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(keyMarker.tr),
                                ),
                              );
                            } catch (error) {
                              log('error = $error');
                              return Container(width: 0, height: 0,);
                            }

                      }))),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 10),
                    child: Column(
                      children: [
                        Builder(builder: (context) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 00),
                            child: Row(
                              children: [
                                Image.asset(
                                  "assets/icons/location.png",
                                  height: 25,
                                  width: 25,
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      showDialogEitAddress(
                                          true,
                                          departureController.text,
                                          (value) async {
                                        if (value != null) {
                                          var locationInfo = value as LocationInfo;
                                          departureController.text =
                                              locationInfo.detailAddress;
                                          await setDepartureMarker(LatLng(
                                              locationInfo.lat,
                                              locationInfo.lng));
                                        }
                                      });
                                    },
                                    child: buildTextField(
                                      title: "Departure".tr,
                                      textController: departureController,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    await getCurrentLocation(true);
                                  },
                                  autofocus: false,
                                  icon: const Icon(
                                    Icons.my_location_outlined,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        // ReorderableListView(
                        //   shrinkWrap: true,
                        //   physics: const NeverScrollableScrollPhysics(),
                        //   children: <Widget>[
                        //     for (int index = 0;
                        //         index < controller.multiStopListNew.length;
                        //         index += 1)
                        //       Container(
                        //         key: ValueKey(
                        //             controller.multiStopListNew[index]),
                        //         child: Column(
                        //           children: [
                        //             const Divider(),
                        //             InkWell(
                        //                 onTap: () async {
                        //                   showDialogEitAddress(
                        //                       controller
                        //                           .multiStopListNew[index]
                        //                           .editingController
                        //                           .text, (value) async {
                        //                     if (value != null) {
                        //                       controller
                        //                           .multiStopListNew[index]
                        //                           .editingController
                        //                           .text = value['result']
                        //                               ['formatted_address']
                        //                           .toString();
                        //                       var lat = value['result']
                        //                               ['geometry']['location']
                        //                           ['lat'];
                        //                       var lng = value['result']
                        //                               ['geometry']['location']
                        //                           ['lng'];
                        //                       controller.multiStopListNew[index]
                        //                           .latitude = lat.toString();
                        //                       controller.multiStopListNew[index]
                        //                           .longitude = lng.toString();
                        //                       await setStopMarker(
                        //                           LatLng(lat, lng), index);
                        //                     }
                        //                   });
                        //                 },
                        //                 child: Row(
                        //                     crossAxisAlignment:
                        //                         CrossAxisAlignment.center,
                        //                     children: [
                        //                       Text(
                        //                         String.fromCharCode(index + 65),
                        //                         style: TextStyle(
                        //                             fontSize: 16,
                        //                             color: ConstantColors
                        //                                 .hintTextColor),
                        //                       ),
                        //                       const SizedBox(
                        //                         width: 5,
                        //                       ),
                        //                       Expanded(
                        //                         child: buildTextField(
                        //                           title:
                        //                               "Where do you want to stop ?"
                        //                                   .tr,
                        //                           textController: controller
                        //                               .multiStopListNew[index]
                        //                               .editingController,
                        //                         ),
                        //                       ),
                        //                       const SizedBox(
                        //                         width: 5,
                        //                       ),
                        //                       InkWell(
                        //                         onTap: () async {
                        //                           controller.removeStops(index);
                        //                           _markers
                        //                               .remove("Stop $index");
                        //                           if (departureLatLong !=
                        //                                   null &&
                        //                               destinationLatLong !=
                        //                                   null) {
                        //                             getDirections();
                        //                           }
                        //                         },
                        //                         child: Icon(
                        //                           Icons.close,
                        //                           size: 25,
                        //                           color: ConstantColors
                        //                               .hintTextColor,
                        //                         ),
                        //                       )
                        //                     ])),
                        //           ],
                        //         ),
                        //       ),
                        //   ],
                        //   onReorder: (int oldIndex, int newIndex) {
                        //     setState(() {
                        //       if (oldIndex < newIndex) {
                        //         newIndex -= 1;
                        //       }
                        //       final AddStopModel item = controller
                        //           .multiStopListNew
                        //           .removeAt(oldIndex);
                        //       controller.multiStopListNew
                        //           .insert(newIndex, item);
                        //     });
                        //   },
                        // ),

                        const Divider(),
                        Row(
                          children: [
                            Image.asset(
                              "assets/icons/dropoff.png",
                              height: 25,
                              width: 25,
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  showDialogEitAddress(
                                      false,
                                      destinationController.text, (value) {
                                    if (value != null) {
                                      var locationInfo = value as LocationInfo;
                                      destinationController.text = locationInfo.detailAddress;

                                      setDestinationMarker(LatLng(
                                        locationInfo.lat,
                                        locationInfo.lng,
                                      ));
                                    }
                                  });
                                },
                                child: buildTextField(
                                  title: "Bạn muốn đi đâu?".tr,
                                  textController: destinationController,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // ListView.builder(
                        //     shrinkWrap: true,
                        //     itemCount: controller.multiStopList.length,
                        //     itemBuilder: (context, int index) {
                        //       return Draggable(
                        //         onDragEnd: (DraggableDetails details) {
                        //           print(
                        //               '\x1b[92m ====== ${details.velocity.pixelsPerSecond}');
                        //           print('\x1b[92m ====== ${details.offset}');
                        //         },
                        //         feedback: Material(
                        //           child: ConstrainedBox(
                        //             constraints: BoxConstraints(
                        //                 maxWidth:
                        //                     MediaQuery.of(context).size.width),
                        //             child: Column(
                        //               children: [
                        //                 const Divider(),
                        //                 InkWell(
                        //                   onTap: () async {
                        //                     await controller
                        //                         .placeSelectAPI(context)
                        //                         .then((value) {
                        //                       if (value != null) {
                        //                         controller
                        //                                 .multiStopList[index]
                        //                                 .editingController
                        //                                 .text =
                        //                             value
                        //                                 .result.formattedAddress
                        //                                 .toString();
                        //                         controller.multiStopList[index]
                        //                                 .latitude =
                        //                             value.result.geometry!
                        //                                 .location.lat
                        //                                 .toString();
                        //                         controller.multiStopList[index]
                        //                                 .longitude =
                        //                             value.result.geometry!
                        //                                 .location.lng
                        //                                 .toString();
                        //                         setStopMarker(
                        //                             LatLng(
                        //                                 value.result.geometry!
                        //                                     .location.lat,
                        //                                 value.result.geometry!
                        //                                     .location.lng),
                        //                             index);
                        //                       }
                        //                     });
                        //                   },
                        //                   child: Row(
                        //                     crossAxisAlignment:
                        //                         CrossAxisAlignment.center,
                        //                     children: [
                        //                       Icon(
                        //                         Icons.location_on_outlined,
                        //                         size: 25,
                        //                         color: ConstantColors
                        //                             .hintTextColor,
                        //                       ),
                        //                       SizedBox(
                        //                         width: 5,
                        //                       ),
                        //                       Expanded(
                        //                         child: buildTextField(
                        //                           title:
                        //                               "Where do you want to stop ?",
                        //                           textController: controller
                        //                               .multiStopList[index]
                        //                               .editingController,
                        //                         ),
                        //                       ),
                        //                       SizedBox(
                        //                         width: 5,
                        //                       ),
                        //                       InkWell(
                        //                         onTap: () {
                        //                           controller.removeStops(index);
                        //                           _markers
                        //                               .remove("Stop $index");
                        //                           getDirections();
                        //                         },
                        //                         child: Icon(
                        //                           Icons.close,
                        //                           size: 25,
                        //                           color: ConstantColors
                        //                               .hintTextColor,
                        //                         ),
                        //                       ),
                        //                     ],
                        //                   ),
                        //                 ),
                        //               ],
                        //             ),
                        //           ),
                        //         ),
                        // child: Column(
                        //   children: [
                        //     const Divider(),
                        //     InkWell(
                        //       onTap: () async {
                        //         await controller
                        //             .placeSelectAPI(context)
                        //             .then((value) {
                        //           if (value != null) {
                        //             controller.multiStopList[index]
                        //                     .editingController.text =
                        //                 value.result.formattedAddress
                        //                     .toString();
                        //             controller.multiStopList[index]
                        //                     .latitude =
                        //                 value.result.geometry!.location
                        //                     .lat
                        //                     .toString();
                        //             controller.multiStopList[index]
                        //                     .longitude =
                        //                 value.result.geometry!.location
                        //                     .lng
                        //                     .toString();
                        //             setStopMarker(
                        //                 LatLng(
                        //                     value.result.geometry!
                        //                         .location.lat,
                        //                     value.result.geometry!
                        //                         .location.lng),
                        //                 index);
                        //           }
                        //         });
                        //       },
                        //       child: Row(
                        //         crossAxisAlignment:
                        //             CrossAxisAlignment.center,
                        //         children: [
                        //           Icon(
                        //             Icons.location_on_outlined,
                        //             size: 25,
                        //             color: ConstantColors.hintTextColor,
                        //           ),
                        //           SizedBox(
                        //             width: 5,
                        //           ),
                        //           Expanded(
                        //             child: buildTextField(
                        //               title:
                        //                   "Where do you want to stop ?",
                        //               textController: controller
                        //                   .multiStopList[index]
                        //                   .editingController,
                        //             ),
                        //           ),
                        //           SizedBox(
                        //             width: 5,
                        //           ),
                        //           InkWell(
                        //             onTap: () {
                        //               controller.removeStops(index);
                        //               _markers.remove("Stop $index");
                        //               getDirections();
                        //             },
                        //             child: Icon(
                        //               Icons.close,
                        //               size: 25,
                        //               color:
                        //                   ConstantColors.hintTextColor,
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //   ],
                        //         ),
                        //       );
                        //     }),

                        // const Divider(),
                        // InkWell(
                        //   onTap: () {
                        //     controller.addStops();
                        //   },
                        //   child: Row(
                        //     children: [
                        //       Icon(
                        //         Icons.add_circle,
                        //         color: ConstantColors.hintTextColor,
                        //       ),
                        //       const SizedBox(
                        //         width: 5,
                        //       ),
                        //       Text(
                        //         'Add stop'.tr,
                        //         style: TextStyle(
                        //             color: ConstantColors.hintTextColor,
                        //             fontSize: 16),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Visibility(
            visible: controller.confirmWidgetVisible.value,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: confirmWidget(),
            ),
          ),
        ],
      ),
    );
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final latTween = Tween<double>(
        begin: _mapController.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: _mapController.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: _mapController.zoom, end: destZoom);

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

      hasTriggeredMove |= _mapController.move(
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

  setDepartureMarker(LatLng departure) async {
    _markers.remove("Departure");
    // var departureSymbol = SymbolOptions(
    //     textField: 'Departure'.tr,
    //     textColor: ConstantColors.violetColorStr,
    //     geometry: departure,
    //     iconImage: "assets/icons/location.png",
    //     iconSize: 2,
    //     iconColor: ConstantColors.blueColorStr,
    //     textOffset: const Offset(0, 2));
    setState(() {
      _markers['Departure'] = Marker(
          point: departure,
          anchorPos: AnchorPos.align(AnchorAlign.top),
          builder: (context) {
            return Image.asset("assets/icons/location.png");
          });
    });
    departureLatLong = departure;
    _animatedMapMove(
        LatLng(departure.latitude, departure.longitude), _initZoom);
    if (departureLatLong != null && destinationLatLong != null) {
      getDirections();
      controller.confirmWidgetVisible.value = true;
      // conformationBottomSheet(context);
    }
  }

  setDestinationMarker(LatLng destination) async {
    // var destinationSymbol = SymbolOptions(
    //     textField: 'Destination'.tr,
    //     textColor: ConstantColors.violetColorStr,
    //     geometry: destination,
    //     iconImage: "assets/icons/location.png",
    //     iconSize: 2,
    //     textOffset: const Offset(0, 2));

    setState(() {
      _markers['Destination'] = Marker(
          point: destination,
          anchorPos: AnchorPos.align(AnchorAlign.top),
          builder: (context) {
            return Image.asset("assets/icons/location.png");
          });
      destinationLatLong = destination;
      if (departureLatLong != null && destinationLatLong != null) {
        getDirections();
        controller.confirmWidgetVisible.value = true;
        // conformationBottomSheet(context);
      }
    });
  }

  setStopMarker(LatLng destination, int index) async {
    // final List<int> codeUnits = "Anand".codeUnits;
    // final Uint8List unit8List = Uint8List.fromList(codeUnits);
    // print('\x1b[97m ===== $unit8List =====');
    //   var stopSymbol = SymbolOptions(
    //       textField: 'Stop ${String.fromCharCode(index + 65)}',
    //       textColor: ConstantColors.violetColorStr,
    //       geometry: destination,
    //       iconImage: "assets/icons/location.png",
    //       iconSize: 2,
    //       textOffset: const Offset(0, 2));
    setState(() {
      _markers['Stop $index'] = Marker(
          point: destination,
          anchorPos: AnchorPos.align(AnchorAlign.top),
          builder: (context) {
            return Image.asset("assets/icons/location.png");
          }); //BitmapDescriptor.fromBytes(unit8List));
      // destinationLatLong = destination;

      if (departureLatLong != null && destinationLatLong != null) {
        getDirections();
        controller.confirmWidgetVisible.value = true;
        // conformationBottomSheet(context);
      }
    });
  }

  Widget buildTextField(
      {required title, required TextEditingController textController}) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: TextField(
        controller: textController,
        textInputAction: TextInputAction.done,
        style: TextStyle(color: ConstantColors.titleTextColor),
        decoration: InputDecoration(
          hintText: title,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabled: false,
        ),
      ),
    );
  }

  getDirections() async {
    // clean polyline and re-draw new polyline
    List<PolylineWayPoint> wayPointList = [];
    for (var i = 0; i < controller.multiStopList.length; i++) {
      wayPointList.add(PolylineWayPoint(
          location: controller.multiStopList[i].editingController.text));
    }

    List<LatLng> listStopPoint = [];
    for (var stopPoint in controller.multiStopListNew) {
      if (stopPoint.latitude.isNotEmpty && stopPoint.longitude.isNotEmpty) {
        listStopPoint.add(LatLng(double.parse(stopPoint.latitude),
            double.parse(stopPoint.longitude)));
      }
    }

    // zoomMapToCenter(departureLatLong!, destinationLatLong!);
    try {
      var routeInfo = await getRouteInfos(
          departureLatLong!, destinationLatLong!, listStopPoint);
      var totalDistance = routeInfo.distance ?? 0.0;
      var totalDuration = routeInfo.duration ?? 0.0;
      setDistanceAndDuration(totalDistance, totalDuration);
      addPolyLine(routeInfo.polylinePoints);
    } catch (e) {
      log('error = $e');
    }
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    setState(() {
      polylinePoints = polylineCoordinates;
    });
  }

  confirmWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ButtonThem.buildIconButton(context,
                iconSize: 16.0,
                icon: Icons.arrow_back_ios,
                iconColor: Colors.black,
                btnHeight: 40,
                btnWidthRatio: 0.25,
                title: "Back".tr,
                btnColor: ConstantColors.yellow,
                txtColor: Colors.black, onPress: () {
              // controller.confirmWidgetVisible.value = false;
            }),
          ),
          Expanded(
            child: ButtonThem.buildButton(context,
                btnHeight: 40,
                title: "Continue".tr,
                btnColor: ConstantColors.primary,
                txtColor: Colors.white, onPress: () async {
              if (controller.duration.isNotEmpty) {
                // await controller.getUserPendingPayment().then((value) async {
                //   if (value != null) {
                //     if (value['success'] == "success") {
                //       if (value['data']['amount'] != 0) {
                //         _pendingPaymentDialog(context);
                //       } else {
                //         Get.back();
                //         controller.confirmWidgetVisible.value = false;
                //         tripOptionBottomSheet(context);
                //       }
                //     } else {
                //       controller.confirmWidgetVisible.value = false;
                //       Get.back();
                //       tripOptionBottomSheet(context);
                //     }
                //   }
                // }
                // );
                //Now customer and driver will proactively pay each other without going through the app'
                passengerController.text = '1';
                await chooseVehicle();
              } else {
                passengerController.text = '1';
                await chooseVehicle(isRouteWithoutDestination: true);
              }
            }),
          ),
        ],
      ),
    );
  }

  chooseVehicle({bool isRouteWithoutDestination = false}) async {
    if (passengerController.text.isEmpty) {
      ShowToastDialog.showToast("Please Enter Passenger".tr);
    } else {
      await controller.getVehicleCategory().then((value) {
        if (value != null) {
          if (value.success == "Success") {
            Get.back();
            var vehicleCategoryModel = value;
            if (vehicleCategoryModel.data != null &&
                vehicleCategoryModel.data!.isNotEmpty) {
              var listSupportedVehicleData =
                  getListSupportedVehicleData(vehicleCategoryModel);
              controller.vehicleData = listSupportedVehicleData[0];
              controller.selectedVehicle.value =
                  listSupportedVehicleData[0].id.toString();
            }
            chooseVehicleBottomSheet(context, vehicleCategoryModel,
                isRouteWithoutDestination: isRouteWithoutDestination);
          }
        }
      });
    }
  }

  setDistanceAndDuration(double distance, double duration) {
    if (Constant.distanceUnit == "KM") {
      controller.distance.value = distance / 1000.00;
    } else {
      controller.distance.value = distance / 1609.34;
    }
    var durationTime = Duration(seconds: duration.toInt());
    String durationDay =
        (durationTime.inDays > 0) ? "${durationTime.inDays} ${"day".tr} " : "";
    String durationHour = (durationTime.inHours > 0)
        ? "${durationTime.inHours} ${"hour".tr} "
        : "";
    String durationMinute = (durationTime.inMinutes > 0)
        ? "${durationTime.inMinutes} ${"minute".tr} "
        : "0";
    controller.duration.value = durationDay + durationHour + durationMinute;
  }

  // conformationBottomSheet(BuildContext context) {
  //   return showModalBottomSheet(
  //       shape: const RoundedRectangleBorder(
  //           borderRadius: BorderRadius.only(
  //               topRight: Radius.circular(15), topLeft: Radius.circular(15))),
  //       context: context,
  //       isDismissible: false,
  //       barrierColor: Colors.transparent,
  //       backgroundColor: Colors.transparent,
  //       builder: (context) {
  //         return StatefulBuilder(builder: (context, setState) {
  //           return Padding(
  //             padding:
  //                 const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
  //             child: Row(
  //               children: [
  //                 Padding(
  //                   padding: const EdgeInsets.symmetric(horizontal: 10),
  //                   child: ButtonThem.buildIconButton(context,
  //                       iconSize: 16.0,
  //                       icon: Icons.arrow_back_ios,
  //                       iconColor: Colors.black,
  //                       btnHeight: 40,
  //                       btnWidthRatio: 0.25,
  //                       title: "Back".tr,
  //                       btnColor: ConstantColors.yellow,
  //                       txtColor: Colors.black, onPress: () {
  //                     Get.back();
  //                   }),
  //                 ),
  //                 Expanded(
  //                   child: ButtonThem.buildButton(context,
  //                       btnHeight: 40,
  //                       title: "Continue".tr,
  //                       btnColor: ConstantColors.primary,
  //                       txtColor: Colors.white, onPress: () async {
  //                     await controller
  //                         .getDurationDistance(
  //                             departureLatLong!, destinationLatLong!)
  //                         .then((durationValue) async {
  //                       if (durationValue != null) {
  //                         await controller
  //                             .getUserPendingPayment()
  //                             .then((value) async {
  //                           if (value != null) {
  //                             if (value['success'] == "success") {
  //                               if (value['data']['amount'] != 0) {
  //                                 _pendingPaymentDialog(context);
  //                               } else {
  //                                 if (Constant.distanceUnit == "KM") {
  //                                   controller.distance.value =
  //                                       durationValue['rows']
  //                                               .first['elements']
  //                                               .first['distance']['value'] /
  //                                           1000.00;
  //                                 } else {
  //                                   controller.distance.value =
  //                                       durationValue['rows']
  //                                               .first['elements']
  //                                               .first['distance']['value'] /
  //                                           1609.34;
  //                                 }

  //                                 controller.duration.value =
  //                                     durationValue['rows']
  //                                         .first['elements']
  //                                         .first['duration']['text'];
  //                                 Get.back();
  //                                 tripOptionBottomSheet(context);
  //                               }
  //                             } else {
  //                               if (Constant.distanceUnit == "KM") {
  //                                 controller.distance.value =
  //                                     durationValue['rows']
  //                                             .first['elements']
  //                                             .first['distance']['value'] /
  //                                         1000.00;
  //                               } else {
  //                                 controller.distance.value =
  //                                     durationValue['rows']
  //                                             .first['elements']
  //                                             .first['distance']['value'] /
  //                                         1609.34;
  //                               }
  //                               controller.duration.value =
  //                                   durationValue['rows']
  //                                       .first['elements']
  //                                       .first['duration']['text'];
  //                               Get.back();
  //                               tripOptionBottomSheet(context);
  //                             }
  //                           }
  //                         });
  //                       }
  //                     });
  //                   }),
  //                 ),
  //               ],
  //             ),
  //           );
  //         });
  //       });
  // }

  final passengerController = TextEditingController();

  @Deprecated('Currently, not use this bottom sheet')
  tripOptionBottomSheet(BuildContext context) {
    controller.addChildList = [
      AddChildModel(editingController: TextEditingController())
    ];
    passengerController.text = '1';
    return showModalBottomSheet(
        context: context,
        isDismissible: false,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(15))),
            margin: const EdgeInsets.all(10),
            child: StatefulBuilder(builder: (context, setState) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
                child: Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          "Trip option".tr,
                          style: const TextStyle(
                              fontSize: 18, color: Colors.black),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: passengerController,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            focusedBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 1.0),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 1.0),
                            ),
                            labelText: 'How many passenger'.tr,
                            hintText: 'How many passenger'.tr,
                          ),
                        ),
                      ),
                      ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: controller.addChildList.length,
                          itemBuilder: (_, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                controller: controller
                                    .addChildList[index].editingController,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey, width: 1.0),
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey, width: 1.0),
                                  ),
                                  hintText: 'Any children ? Age of child'.tr,
                                ),
                              ),
                            );
                          }),
                      Visibility(
                        visible: controller.addChildList.length < 3,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (controller.addChildList.length < 3) {
                                    controller.addChildList.add(AddChildModel(
                                        editingController:
                                            TextEditingController()));
                                  }
                                },
                                child: SizedBox(
                                  width: 80,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.add,
                                        color: ConstantColors.primary,
                                      ),
                                      Text("Add".tr),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: ButtonThem.buildIconButton(context,
                                  iconSize: 16.0,
                                  icon: Icons.arrow_back_ios,
                                  iconColor: Colors.black,
                                  btnHeight: 40,
                                  btnWidthRatio: 0.25,
                                  title: "Back".tr,
                                  btnColor: ConstantColors.yellow,
                                  txtColor: Colors.black, onPress: () {
                                Get.back();
                              }),
                            ),
                            Expanded(
                              child: ButtonThem.buildButton(context,
                                  btnHeight: 40,
                                  title: "Book Now".tr,
                                  btnColor: ConstantColors.primary,
                                  txtColor: Colors.white, onPress: () async {
                                if (passengerController.text.isEmpty) {
                                  ShowToastDialog.showToast(
                                      "Please Enter Passenger".tr);
                                } else {
                                  await controller
                                      .getVehicleCategory()
                                      .then((value) {
                                    if (value != null) {
                                      if (value.success == "Success") {
                                        Get.back();
                                        // List tripPrice = [];
                                        // for (int i = 0;
                                        //     i < value.vehicleData!.length;
                                        //     i++) {
                                        //   tripPrice.add(0.0);
                                        // }
                                        // if (value.vehicleData!.isNotEmpty) {
                                        //   for (int i = 0;
                                        //       i < value.vehicleData!.length;
                                        //       i++) {
                                        //     if (controller.distance.value >
                                        //         value.vehicleData![i]
                                        //             .minimumDeliveryChargesWithin!
                                        //             .toDouble()) {
                                        //       tripPrice.add((controller
                                        //                   .distance.value *
                                        //               value.vehicleData![i]
                                        //                   .deliveryCharges!)
                                        //           .toDouble()
                                        //           .toStringAsFixed(
                                        //               int.parse(Constant.decimal ?? "2")));
                                        //     } else {
                                        //       tripPrice.add(value
                                        //           .vehicleData![i]
                                        //           .minimumDeliveryCharges!
                                        //           .toDouble()
                                        //           .toStringAsFixed(
                                        //               int.parse(Constant.decimal ?? "2")));
                                        //     }
                                        //   }
                                        // }
                                        chooseVehicleBottomSheet(
                                          context,
                                          value,
                                        );
                                      }
                                    }
                                  });
                                }
                              }),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            }),
          );
        });
  }

  List<VehicleData> getListSupportedVehicleData(
      VehicleCategoryModel vehicleCategoryModel) {
    if (widget.initHomeActionType == InitHomeActionType.bookMotorbikeDriver ||
        widget.initHomeActionType == InitHomeActionType.bookMotorbike) {
      return vehicleCategoryModel.data
              ?.where((vehicle) => vehicle.id == '2')
              .toList() ??
          [];
    } else if (widget.initHomeActionType == InitHomeActionType.bookCarDriver ||
        widget.initHomeActionType == InitHomeActionType.bookCar) {
      return vehicleCategoryModel.data
              ?.where((vehicle) => vehicle.id != '2')
              .toList() ??
          [];
    } else {
      return vehicleCategoryModel.data ?? [];
    }
  }

  chooseVehicleBottomSheet(BuildContext context,
      VehicleCategoryModel vehicleCategoryModel,
      {bool isRouteWithoutDestination = false,}) {
    var listSupportedVehicleData =
        getListSupportedVehicleData(vehicleCategoryModel);
    return showModalBottomSheet(
        context: context,
        isDismissible: false,
        enableDrag: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
            margin: const EdgeInsets.all(10),
            child: StatefulBuilder(builder: (context, setState) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "Choose Your Vehicle Type".tr,
                        style:
                            const TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                    Divider(
                      color: Colors.grey.shade700,
                    ),
                    Visibility(
                      visible: isRouteWithoutDestination == false,
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Image.asset("assets/icons/ic_distance.png",
                                    height: 24, width: 24),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text("Distance".tr,
                                      style: const TextStyle(fontSize: 16)),
                                )
                              ],
                            ),
                          ),
                          Text(
                              "${controller.distance.value.toStringAsFixed(2)} ${Constant.distanceUnit}")
                        ],
                      ),
                    ),
                    Visibility(
                      visible: isRouteWithoutDestination == false,
                      child: Divider(
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                          itemCount: listSupportedVehicleData.length,
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Obx(
                              () => InkWell(
                                onTap: () {
                                  controller.vehicleData =
                                      listSupportedVehicleData[index];
                                  controller.selectedVehicle.value =
                                      listSupportedVehicleData[index]
                                          .id
                                          .toString();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: controller
                                                    .selectedVehicle.value ==
                                                listSupportedVehicleData[index]
                                                    .id
                                                    .toString()
                                            ? ConstantColors.primary
                                            : Colors.black.withOpacity(0.10),
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 10),
                                      child: Row(
                                        children: [
                                          CachedNetworkImage(
                                            imageUrl:
                                                listSupportedVehicleData[index]
                                                    .image
                                                    .toString(),
                                            fit: BoxFit.fill,
                                            width: 80,
                                            height: 50,
                                            placeholder: (context, url) =>
                                                Constant.loader(),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error),
                                          ),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10),
                                                    child: Text(
                                                      listSupportedVehicleData[
                                                              index]
                                                          .libelle
                                                          .toString(),
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color: controller
                                                                      .selectedVehicle
                                                                      .value ==
                                                                  listSupportedVehicleData[
                                                                          index]
                                                                      .id
                                                                      .toString()
                                                              ? Colors.white
                                                              : Colors.black,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 5),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        controller
                                                            .duration.value,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          color: controller
                                                                      .selectedVehicle
                                                                      .value ==
                                                                  listSupportedVehicleData[
                                                                          index]
                                                                      .id
                                                                      .toString()
                                                              ? Colors.white
                                                              : Colors.black,
                                                        ),
                                                      ),
                                                      Visibility(
                                                        visible: isRouteWithoutDestination == false,
                                                        child: Text(
                                                          Constant().amountShow(
                                                              amount:
                                                                  "${controller.calculateTripPrice(
                                                            distance: controller
                                                                .distance.value,
                                                            deliveryCharges: double.parse(
                                                                listSupportedVehicleData[
                                                                        index]
                                                                    .deliveryCharges!),
                                                            minimumDeliveryCharges:
                                                                double.parse(
                                                                    listSupportedVehicleData[
                                                                            index]
                                                                        .minimumDeliveryCharges!),
                                                            minimumDeliveryChargesWithin:
                                                                double.parse(
                                                                    listSupportedVehicleData[
                                                                            index]
                                                                        .minimumDeliveryChargesWithin!),
                                                          )}"),
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            color: controller
                                                                        .selectedVehicle
                                                                        .value ==
                                                                    listSupportedVehicleData[
                                                                            index]
                                                                        .id
                                                                        .toString()
                                                                ? Colors.white
                                                                : Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: ButtonThem.buildIconButton(context,
                                iconSize: 16.0,
                                icon: Icons.arrow_back_ios,
                                iconColor: Colors.black,
                                btnHeight: 40,
                                btnWidthRatio: 0.25,
                                title: "Back".tr,
                                btnColor: ConstantColors.yellow,
                                txtColor: Colors.black, onPress: () {
                              Get.back();
                              // tripOptionBottomSheet(context);
                            }),
                          ),
                          Expanded(
                            child: ButtonThem.buildButton(context,
                                btnHeight: 40,
                                title: "Book Now".tr,
                                btnColor: ConstantColors.primary,
                                txtColor: Colors.white, onPress: () async {
                              if (controller.selectedVehicle.value.isNotEmpty) {
                                double cout = 0.0;

                                if (controller.distance.value >
                                    double.parse(controller.vehicleData!
                                        .minimumDeliveryChargesWithin!)) {
                                  cout = (controller.distance.value *
                                          double.parse(controller
                                              .vehicleData!.deliveryCharges!))
                                      .toDouble();
                                } else {
                                  cout = double.parse(controller
                                      .vehicleData!.minimumDeliveryCharges
                                      .toString());
                                }

                                // double cout = double.parse(controller
                                //         .vehicleData!.prix
                                //         .toString()) *
                                //     controller.distance.value;

                                // if (controller.vehicleData!.statutCommission ==
                                //         "yes" &&
                                //     controller.vehicleData!
                                //             .statutCommissionPerc ==
                                //         "yes") {
                                //   double coutFixed = double.parse(controller
                                //       .vehicleData!.commission
                                //       .toString());
                                //   double coutPerc = cout +
                                //       (cout +
                                //           double.parse(controller
                                //               .vehicleData!.commissionPerc
                                //               .toString()));
                                //   cout = coutFixed + coutPerc;
                                // } else if (controller
                                //         .vehicleData!.statutCommission ==
                                //     "yes") {
                                //   cout = cout +
                                //       double.parse(controller
                                //           .vehicleData!.commission
                                //           .toString());
                                // } else {
                                //   cout = cout +
                                //       (cout +
                                //           double.parse(controller
                                //               .vehicleData!.commissionPerc
                                //               .toString()));
                                // }

                                await controller
                                    .getDriverDetails(
                                        controller.vehicleData!.id.toString(),
                                        departureLatLong!.latitude.toString(),
                                        departureLatLong!.longitude.toString())
                                    .then((value) {
                                  if (value != null) {
                                    if (value.success == "Success") {
                                      List<DriverData> driverData = [];
                                      for (var i = 0;
                                          i < value.data!.length;
                                          i++) {
                                        if (double.parse(
                                                Constant.driverRadius!) >=
                                            double.parse(
                                                value.data![i].distance!)) {
                                          driverData.add(value.data![i]);
                                        }
                                        driverData.add(value.data![i]);
                                      }
                                      if (driverData.isNotEmpty) {
                                        Get.back();
                                        conformDataBottomSheet(
                                            context, driverData[0], cout,
                                            isRouteWithoutDestination:
                                                isRouteWithoutDestination);
                                      } else {
                                        ShowToastDialog.showToast(
                                            "Driver not available".tr);
                                      }
                                    } else {
                                      ShowToastDialog.showToast(
                                          "Driver not available".tr);
                                    }
                                  }
                                });
                              } else {
                                ShowToastDialog.showToast(
                                    "Please select Vehicle Type".tr);
                              }
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          );
        });
  }

  String getBookingType() {
    if (widget.initHomeActionType == InitHomeActionType.bookVehicle ||
        widget.initHomeActionType == InitHomeActionType.bookCar ||
        widget.initHomeActionType == InitHomeActionType.bookMotorbike) {
      return 'book_car';
    } else {
      return 'call_driver';
    }
  }

  conformDataBottomSheet(
      BuildContext context, DriverData driverModel, double tripPrice,
      {bool isRouteWithoutDestination = false}) {
    final controllerDashBoard = Get.put(DashBoardController());
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(15))),
            margin: const EdgeInsets.all(10),
            child: StatefulBuilder(builder: (context, setState) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
                child: Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl: driverModel.photo.toString(),
                                fit: BoxFit.cover,
                                height: 72,
                                width: 72,
                                placeholder: (context, url) =>
                                    Constant.loader(),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  driverModel.prenom.toString(),
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: ConstantColors.titleTextColor,
                                      fontWeight: FontWeight.w800),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: StarRating(
                                      size: 18,
                                      rating: double.parse(
                                          driverModel.moyenne ?? '0'),
                                      color: ConstantColors.yellow),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: Text(
                                    "${"Total trips".tr} ${driverModel.totalCompletedRide.toString()}",
                                    style: TextStyle(
                                      color: ConstantColors.subTitleTextColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  if (driverModel.phone != null &&
                                      driverModel.phone!.isNotEmpty) {
                                    Constant.makePhoneCall(
                                        driverModel.phone.toString());
                                  } else {
                                    ShowToastDialog.showToast(
                                        "Driver do not have phone number".tr);
                                  }
                                },
                                child: ClipOval(
                                  child: Container(
                                    color: ConstantColors.primary,
                                    child: const Padding(
                                      padding: EdgeInsets.all(6.0),
                                      child: Icon(
                                        Icons.phone,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Padding(
                              //   padding: const EdgeInsets.only(top: 10),
                              //   child: InkWell(
                              //       onTap: () {
                              //         _favouriteNameDialog(context);
                              //       },
                              //       child: Image.asset(
                              //         'assets/icons/add_fav.png',
                              //         height: 32,
                              //         width: 32,
                              //       )),
                              // ),
                            ],
                          )
                        ],
                      ),
                      Visibility(
                        visible: isRouteWithoutDestination == false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Row(
                            children: [
                              //Now customer and driver will proactively pay each other without going through the app
                              // Expanded(
                              //   child: InkWell(
                              //     onTap: () {
                              //       _paymentMethodDialog(
                              //         context,
                              //       );
                              //     },
                              //     child: buildDetails(
                              //         title: controller.paymentMethodType.value,
                              //         value: 'Payment'.tr),
                              //   ),
                              // ),
                              // const SizedBox(
                              //   width: 10,
                              // ),
                              Expanded(
                                  child: buildDetails(
                                      title: controller.duration.value,
                                      value: 'Duration'.tr)),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                  child: buildDetails(
                                      title: Constant().amountShow(
                                          amount: tripPrice.toString()),
                                      value: 'Trip Price'.tr,
                                      txtColor: ConstantColors.primary)),
                            ],
                          ),
                        ),
                      ),
                      Divider(
                        color: Colors.grey.shade700,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Opacity(
                            opacity: 0.6,
                            child: Text(
                              "Cab Details:".tr,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        text:
                                            '${driverModel.model.toString()} | ${driverModel.brand.toString()} | ',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black),
                                        children: [
                                          TextSpan(
                                            text: driverModel.numberplate
                                                .toString(),
                                            style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black),
                                          )
                                        ],
                                      )),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Divider(
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: ButtonThem.buildIconButton(context,
                                iconSize: 16.0,
                                icon: Icons.arrow_back_ios,
                                iconColor: Colors.black,
                                btnHeight: 40,
                                btnWidthRatio: 0.25,
                                title: "Back".tr,
                                btnColor: ConstantColors.yellow,
                                txtColor: Colors.black, onPress: () async {
                              await controller
                                  .getVehicleCategory()
                                  .then((value) {
                                if (value != null) {
                                  if (value.success == "Success") {
                                    Get.back();
                                    Get.back();
                                    List tripPrice = [];
                                    for (int i = 0;
                                        i < value.data!.length;
                                        i++) {
                                      tripPrice.add(0.0);
                                    }
                                    if (value.data!.isNotEmpty) {
                                      for (int i = 0;
                                          i < value.data!.length;
                                          i++) {
                                        if (controller.distance.value >
                                            double.parse(value.data![i]
                                                .minimumDeliveryChargesWithin!)) {
                                          tripPrice.add((controller
                                                      .distance.value *
                                                  double.parse(value.data![i]
                                                      .deliveryCharges!))
                                              .toDouble()
                                              .toStringAsFixed(int.parse(
                                                  Constant.decimal ?? "2")));
                                        } else {
                                          tripPrice.add(double.parse(value
                                                  .data![i]
                                                  .minimumDeliveryCharges!)
                                              .toStringAsFixed(int.parse(
                                                  Constant.decimal ?? "2")));
                                        }
                                      }
                                    }
                                    chooseVehicleBottomSheet(
                                      context,
                                      value,
                                      isRouteWithoutDestination: isRouteWithoutDestination
                                    );
                                  }
                                }
                              });
                            }),
                          ),
                          Expanded(
                            child: ButtonThem.buildButton(context,
                                btnHeight: 40,
                                title: "Book Now".tr,
                                btnColor: ConstantColors.primary,
                                txtColor: Colors.white, onPress: () {
                              // if (controller.paymentMethodType.value ==
                              //     "Select Method") {
                              //   ShowToastDialog.showToast(
                              //       "Please select payment method".tr);
                              // } else {
                              List stopsList = [];
                              for (var i = 0;
                                  i < controller.multiStopListNew.length;
                                  i++) {
                                stopsList.add({
                                  "latitude": controller
                                      .multiStopListNew[i].latitude
                                      .toString(),
                                  "longitude": controller
                                      .multiStopListNew[i].longitude
                                      .toString(),
                                  "location": controller.multiStopListNew[i]
                                      .editingController.text
                                      .toString()
                                });
                              }
                              Map<String, dynamic> bodyParams = {
                                'type': getBookingType(),
                                'user_id':
                                    Preferences.getInt(Preferences.userId)
                                        .toString(),
                                'lat1': departureLatLong!.latitude.toString(),
                                'lng1': departureLatLong!.longitude.toString(),
                                'lat2': destinationLatLong?.latitude.toString(),
                                'lng2':
                                    destinationLatLong?.longitude.toString(),
                                'cout': tripPrice.toString(),
                                'distance': controller.distance.toString(),
                                'distance_unit':
                                    Constant.distanceUnit.toString(),
                                'duree': controller.duration.toString(),
                                'id_conducteur': driverModel.id.toString(),
                                'id_payment': '5',
                                // controller.paymentMethodId.value,
                                'depart_name': departureController.text,
                                'destination_name': destinationController.text,
                                'stops': stopsList,
                                'place': '',
                                'number_poeple': passengerController.text,
                                'image': '',
                                'image_name': "",
                                'statut_round': 'no',
                                'trip_objective':
                                    controller.tripOptionCategory.value,
                                'age_children1': controller
                                    .addChildList[0].editingController.text,
                                'age_children2':
                                    controller.addChildList.length == 2
                                        ? controller.addChildList[1]
                                            .editingController.text
                                        : "",
                                'age_children3':
                                    controller.addChildList.length == 3
                                        ? controller.addChildList[2]
                                            .editingController.text
                                        : "",
                              };

                              controller
                                  .bookRide(bodyParams)
                                  .then((value) async {
                                if (value != null) {
                                  if (value['success'] == "success") {
                                    tripPrice = 0.0;
                                    clearData();
                                    Get.back();
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CustomDialogBox(
                                            title: "",
                                            descriptions:
                                                "Chuyến đi của bạn đã được thêm thành công",
                                            onPress: () {
                                              Get.back();
                                              Get.back();
                                            },
                                            img: Image.asset(
                                                'assets/images/green_checked.png'),
                                          );
                                        });
                                    // go to all routes screen
                                    controllerDashBoard.onSelectItem(3);
                                  } else {
                                    var errorMsg = value['error'];
                                    if(errorMsg?.toString() != null && errorMsg.toString().isNotEmpty) {
                                      ShowToastDialog.showToast('$errorMsg');
                                    }
                                  }
                                }
                              });
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          );
        });
  }

  // final favouriteNameTextController = TextEditingController();

  // _favouriteNameDialog(BuildContext context) async {
  //   return showDialog(
  //       context: context,
  //       builder: (context) {
  //         return AlertDialog(
  //           title: const Text("Enter Favourite Name"),
  //           content: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               TextFieldThem.buildTextField(
  //                 title: 'Favourite name'.tr,
  //                 labelText: 'Favourite name'.tr,
  //                 controller: favouriteNameTextController,
  //                 textInputType: TextInputType.text,
  //                 contentPadding: EdgeInsets.zero,
  //               ),
  //               Padding(
  //                 padding: const EdgeInsets.only(top: 30),
  //                 child: Row(
  //                   mainAxisAlignment: MainAxisAlignment.end,
  //                   crossAxisAlignment: CrossAxisAlignment.end,
  //                   children: [
  //                     InkWell(
  //                         onTap: () {
  //                           Get.back();
  //                         },
  //                         child: Text("cancel".tr)),
  //                     InkWell(
  //                         onTap: () {
  //                           Map<String, String> bodyParams = {
  //                             'id_user_app':
  //                                 Preferences.getInt(Preferences.userId)
  //                                     .toString(),
  //                             'lat1': departureLatLong!.latitude.toString(),
  //                             'lng1': departureLatLong!.longitude.toString(),
  //                             'lat2': destinationLatLong!.latitude.toString(),
  //                             'lng2': destinationLatLong!.longitude.toString(),
  //                             'distance': controller.distance.value.toString(),
  //                             'distance_unit': Constant.distanceUnit.toString(),
  //                             'depart_name': departureController.text,
  //                             'destination_name': destinationController.text,
  //                             'fav_name': favouriteNameTextController.text,
  //                           };
  //                           controller
  //                               .setFavouriteRide(bodyParams)
  //                               .then((value) {
  //                             if (value['success'] == "Success") {
  //                               Get.back();
  //                             } else {
  //                               ShowToastDialog.showToast(value['error']);
  //                             }
  //                           });
  //                         },
  //                         child: Padding(
  //                           padding: const EdgeInsets.only(left: 20),
  //                           child: Text("Ok".tr),
  //                         )),
  //                   ],
  //                 ),
  //               )
  //             ],
  //           ),
  //         );
  //       });
  // }

  // _pendingPaymentDialog(BuildContext context) {
  //   // set up the button
  //   Widget okButton = TextButton(
  //     child: const Text("OK"),
  //     onPressed: () {
  //       Get.back();
  //     },
  //   );
  //
  //   // set up the AlertDialog
  //   AlertDialog alert = AlertDialog(
  //     title: const Text("Cab me"),
  //     content: Text(
  //         "You have pending payments. Please complete payment before book new trip."
  //             .tr),
  //     actions: [
  //       okButton,
  //     ],
  //   );
  //   // show the dialog
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return alert;
  //     },
  //   );
  // }
  //

  // _paymentMethodDialog(
  //   BuildContext context,
  // ) {
  //   return showModalBottomSheet(
  //       shape: const RoundedRectangleBorder(
  //           borderRadius: BorderRadius.only(
  //               topRight: Radius.circular(15), topLeft: Radius.circular(15))),
  //       context: context,
  //       isScrollControlled: true,
  //       isDismissible: false,
  //       builder: (context) {
  //         return StatefulBuilder(builder: (context, setState) {
  //           return SizedBox(
  //             height: MediaQuery.of(context).size.height * 0.9,
  //             child: Padding(
  //               padding:
  //                   const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
  //               child: SingleChildScrollView(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     const Text("Select Payment Method"),
  //                     Divider(
  //                       color: Colors.grey.shade700,
  //                     ),
  //                     Visibility(
  //                       visible:
  //                           controller.paymentSettingModel.value.cash != null &&
  //                                   controller.paymentSettingModel.value.cash!
  //                                           .isEnabled ==
  //                                       "true"
  //                               ? true
  //                               : false,
  //                       child: Padding(
  //                         padding: const EdgeInsets.symmetric(vertical: 3.0),
  //                         child: Card(
  //                           shape: RoundedRectangleBorder(
  //                             borderRadius: BorderRadius.circular(8),
  //                           ),
  //                           elevation: controller.cash.value ? 0 : 2,
  //                           child: RadioListTile(
  //                             shape: RoundedRectangleBorder(
  //                                 borderRadius: BorderRadius.circular(8),
  //                                 side: BorderSide(
  //                                     color: controller.cash.value
  //                                         ? ConstantColors.primary
  //                                         : Colors.transparent)),
  //                             controlAffinity: ListTileControlAffinity.trailing,
  //                             value: "Cash",
  //                             groupValue: controller.paymentMethodType.value,
  //                             onChanged: (String? value) {
  //                               controller.wallet = false.obs;
  //                               controller.cash = true.obs;
  //                               controller.pay9 = false.obs;
  //                               controller.paymentMethodType.value = value!;
  //                               controller.paymentMethodId = controller
  //                                   .paymentSettingModel
  //                                   .value
  //                                   .cash!
  //                                   .idPaymentMethod
  //                                   .toString()
  //                                   .obs;
  //                               Get.back();
  //                             },
  //                             selected: controller.cash.value,
  //                             contentPadding: const EdgeInsets.symmetric(
  //                               horizontal: 6,
  //                             ),
  //                             title: Row(
  //                               mainAxisAlignment: MainAxisAlignment.start,
  //                               children: [
  //                                 Container(
  //                                     decoration: BoxDecoration(
  //                                       color: Colors.blueGrey.shade50,
  //                                       borderRadius: BorderRadius.circular(8),
  //                                     ),
  //                                     child: Padding(
  //                                       padding: const EdgeInsets.symmetric(
  //                                           vertical: 4.0),
  //                                       child: SizedBox(
  //                                         width: 80,
  //                                         height: 35,
  //                                         child: Padding(
  //                                           padding: const EdgeInsets.symmetric(
  //                                               vertical: 6.0),
  //                                           child: Image.asset(
  //                                             "assets/images/cash.png",
  //                                           ),
  //                                         ),
  //                                       ),
  //                                     )),
  //                                 const SizedBox(
  //                                   width: 20,
  //                                 ),
  //                                 Text("Cash".tr),
  //                               ],
  //                             ),
  //                             //toggleable: true,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                     Visibility(
  //                       visible:
  //                           controller.paymentSettingModel.value.myWallet !=
  //                                       null &&
  //                                   controller.paymentSettingModel.value
  //                                           .myWallet!.isEnabled ==
  //                                       "true"
  //                               ? true
  //                               : false,
  //                       child: Padding(
  //                         padding: const EdgeInsets.symmetric(vertical: 3.0),
  //                         child: Card(
  //                           shape: RoundedRectangleBorder(
  //                             borderRadius: BorderRadius.circular(8),
  //                           ),
  //                           elevation: controller.wallet.value ? 0 : 2,
  //                           child: RadioListTile(
  //                             shape: RoundedRectangleBorder(
  //                                 borderRadius: BorderRadius.circular(8),
  //                                 side: BorderSide(
  //                                     color: controller.wallet.value
  //                                         ? ConstantColors.primary
  //                                         : Colors.transparent)),
  //                             controlAffinity: ListTileControlAffinity.trailing,
  //                             value: "Wallet",
  //                             groupValue: controller.paymentMethodType.value,
  //                             onChanged: (String? value) {
  //                               controller.wallet = true.obs;
  //                               controller.cash = false.obs;
  //                               controller.pay9 = false.obs;
  //                               controller.paymentMethodType.value = value!;
  //                               controller.paymentMethodId = controller
  //                                   .paymentSettingModel
  //                                   .value
  //                                   .myWallet!
  //                                   .idPaymentMethod
  //                                   .toString()
  //                                   .obs;
  //                               Get.back();
  //                             },
  //                             selected: controller.wallet.value,
  //                             contentPadding: const EdgeInsets.symmetric(
  //                               horizontal: 6,
  //                             ),
  //                             title: Row(
  //                               mainAxisAlignment: MainAxisAlignment.start,
  //                               children: [
  //                                 Container(
  //                                     decoration: BoxDecoration(
  //                                       color: Colors.blueGrey.shade50,
  //                                       borderRadius: BorderRadius.circular(8),
  //                                     ),
  //                                     child: Padding(
  //                                       padding: const EdgeInsets.symmetric(
  //                                           vertical: 4.0),
  //                                       child: SizedBox(
  //                                         width: 80,
  //                                         height: 35,
  //                                         child: Padding(
  //                                           padding: const EdgeInsets.symmetric(
  //                                               vertical: 6.0),
  //                                           child: Image.asset(
  //                                             "assets/icons/walltet_icons.png",
  //                                           ),
  //                                         ),
  //                                       ),
  //                                     )),
  //                                 const SizedBox(
  //                                   width: 20,
  //                                 ),
  //                                 Text("Wallet".tr),
  //                               ],
  //                             ),
  //                             //toggleable: true,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                     Visibility(
  //                       visible:
  //                           controller.paymentSettingModel.value.pay9 != null &&
  //                                   controller.paymentSettingModel.value.pay9!
  //                                           .isEnabled ==
  //                                       "true"
  //                               ? true
  //                               : false,
  //                       child: Padding(
  //                         padding: const EdgeInsets.symmetric(vertical: 3.0),
  //                         child: Card(
  //                           shape: RoundedRectangleBorder(
  //                             borderRadius: BorderRadius.circular(8),
  //                           ),
  //                           elevation: controller.pay9.value ? 0 : 2,
  //                           child: RadioListTile(
  //                             shape: RoundedRectangleBorder(
  //                                 borderRadius: BorderRadius.circular(8),
  //                                 side: BorderSide(
  //                                     color: controller.pay9.value
  //                                         ? ConstantColors.primary
  //                                         : Colors.transparent)),
  //                             controlAffinity: ListTileControlAffinity.trailing,
  //                             value: "9Pay",
  //                             groupValue: controller.paymentMethodType.value,
  //                             onChanged: (String? value) {
  //                               controller.wallet = false.obs;
  //                               controller.cash = false.obs;
  //                               controller.pay9 = true.obs;
  //                               controller.paymentMethodType.value = value!;
  //                               controller.paymentMethodId = controller
  //                                   .paymentSettingModel
  //                                   .value
  //                                   .pay9!
  //                                   .idPaymentMethod
  //                                   .toString()
  //                                   .obs;
  //                               Get.back();
  //                             },
  //                             selected: controller.pay9.value,
  //                             contentPadding: const EdgeInsets.symmetric(
  //                               horizontal: 6,
  //                             ),
  //                             title: Row(
  //                               mainAxisAlignment: MainAxisAlignment.start,
  //                               children: [
  //                                 Container(
  //                                     decoration: BoxDecoration(
  //                                       color: Colors.blueGrey.shade50,
  //                                       borderRadius: BorderRadius.circular(8),
  //                                     ),
  //                                     child: Padding(
  //                                       padding: const EdgeInsets.symmetric(
  //                                           vertical: 4.0),
  //                                       child: SizedBox(
  //                                         width: 80,
  //                                         height: 35,
  //                                         child: Padding(
  //                                           padding: const EdgeInsets.symmetric(
  //                                               vertical: 6.0),
  //                                           child: Image.asset(
  //                                             "assets/images/9pay_logo.png",
  //                                           ),
  //                                         ),
  //                                       ),
  //                                     )),
  //                                 const SizedBox(
  //                                   width: 20,
  //                                 ),
  //                                 Text("Payment".tr),
  //                               ],
  //                             ),
  //                             //toggleable: true,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                     // Visibility(
  //                     //   visible: controller.paymentSettingModel.value.strip !=
  //                     //               null &&
  //                     //           controller.paymentSettingModel.value.strip!
  //                     //                   .isEnabled ==
  //                     //               "true"
  //                     //       ? true
  //                     //       : false,
  //                     //   child: Padding(
  //                     //     padding: const EdgeInsets.symmetric(vertical: 3.0),
  //                     //     child: Card(
  //                     //       shape: RoundedRectangleBorder(
  //                     //         borderRadius: BorderRadius.circular(8),
  //                     //       ),
  //                     //       elevation: controller.stripe.value ? 0 : 2,
  //                     //       child: RadioListTile(
  //                     //         shape: RoundedRectangleBorder(
  //                     //             borderRadius: BorderRadius.circular(8),
  //                     //             side: BorderSide(
  //                     //                 color: controller.stripe.value
  //                     //                     ? ConstantColors.primary
  //                     //                     : Colors.transparent)),
  //                     //         controlAffinity: ListTileControlAffinity.trailing,
  //                     //         value: "Stripe",
  //                     //         groupValue: controller.paymentMethodType.value,
  //                     //         onChanged: (String? value) {
  //                     //           controller.stripe = true.obs;
  //                     //           controller.wallet = false.obs;
  //                     //           controller.cash = false.obs;
  //                     //           controller.razorPay = false.obs;
  //                     //           controller.payTm = false.obs;
  //                     //           controller.paypal = false.obs;
  //                     //           controller.payStack = false.obs;
  //                     //           controller.flutterWave = false.obs;
  //                     //           controller.mercadoPago = false.obs;
  //                     //           controller.payFast = false.obs;
  //                     //           controller.paymentMethodType.value = value!;
  //                     //           controller.paymentMethodId = controller
  //                     //               .paymentSettingModel
  //                     //               .value
  //                     //               .strip!
  //                     //               .idPaymentMethod
  //                     //               .toString()
  //                     //               .obs;
  //                     //           Get.back();
  //                     //         },
  //                     //         selected: controller.stripe.value,
  //                     //         contentPadding: const EdgeInsets.symmetric(
  //                     //           horizontal: 6,
  //                     //         ),
  //                     //         title: Row(
  //                     //           mainAxisAlignment: MainAxisAlignment.start,
  //                     //           children: [
  //                     //             Container(
  //                     //                 decoration: BoxDecoration(
  //                     //                   color: Colors.blueGrey.shade50,
  //                     //                   borderRadius: BorderRadius.circular(8),
  //                     //                 ),
  //                     //                 child: Padding(
  //                     //                   padding: const EdgeInsets.symmetric(
  //                     //                       vertical: 4.0),
  //                     //                   child: SizedBox(
  //                     //                     width: 80,
  //                     //                     height: 35,
  //                     //                     child: Padding(
  //                     //                       padding: const EdgeInsets.symmetric(
  //                     //                           vertical: 6.0),
  //                     //                       child: Image.asset(
  //                     //                         "assets/images/stripe.png",
  //                     //                       ),
  //                     //                     ),
  //                     //                   ),
  //                     //                 )),
  //                     //             const SizedBox(
  //                     //               width: 20,
  //                     //             ),
  //                     //             Text("Stripe".tr),
  //                     //           ],
  //                     //         ),
  //                     //         //toggleable: true,
  //                     //       ),
  //                     //     ),
  //                     //   ),
  //                     // ),
  //                     // Visibility(
  //                     //   visible:
  //                     //       controller.paymentSettingModel.value.payStack !=
  //                     //                   null &&
  //                     //               controller.paymentSettingModel.value
  //                     //                       .payStack!.isEnabled ==
  //                     //                   "true"
  //                     //           ? true
  //                     //           : false,
  //                     //   child: Padding(
  //                     //     padding: const EdgeInsets.symmetric(vertical: 3.0),
  //                     //     child: Card(
  //                     //       shape: RoundedRectangleBorder(
  //                     //         borderRadius: BorderRadius.circular(8),
  //                     //       ),
  //                     //       elevation: controller.payStack.value ? 0 : 2,
  //                     //       child: RadioListTile(
  //                     //         shape: RoundedRectangleBorder(
  //                     //             borderRadius: BorderRadius.circular(8),
  //                     //             side: BorderSide(
  //                     //                 color: controller.payStack.value
  //                     //                     ? ConstantColors.primary
  //                     //                     : Colors.transparent)),
  //                     //         controlAffinity: ListTileControlAffinity.trailing,
  //                     //         value: "PayStack",
  //                     //         groupValue: controller.paymentMethodType.value,
  //                     //         onChanged: (String? value) {
  //                     //           controller.stripe = false.obs;
  //                     //           controller.wallet = false.obs;
  //                     //           controller.cash = false.obs;
  //                     //           controller.razorPay = false.obs;
  //                     //           controller.payTm = false.obs;
  //                     //           controller.paypal = false.obs;
  //                     //           controller.payStack = true.obs;
  //                     //           controller.flutterWave = false.obs;
  //                     //           controller.mercadoPago = false.obs;
  //                     //           controller.payFast = false.obs;
  //                     //           controller.paymentMethodType.value = value!;
  //                     //           controller.paymentMethodId = controller
  //                     //               .paymentSettingModel
  //                     //               .value
  //                     //               .payStack!
  //                     //               .idPaymentMethod
  //                     //               .toString()
  //                     //               .obs;
  //                     //           Get.back();
  //                     //         },
  //                     //         selected: controller.payStack.value,
  //                     //         //selectedRadioTile == "strip" ? true : false,
  //                     //         contentPadding: const EdgeInsets.symmetric(
  //                     //           horizontal: 6,
  //                     //         ),
  //                     //         title: Row(
  //                     //           mainAxisAlignment: MainAxisAlignment.start,
  //                     //           children: [
  //                     //             Container(
  //                     //                 decoration: BoxDecoration(
  //                     //                   color: Colors.blueGrey.shade50,
  //                     //                   borderRadius: BorderRadius.circular(8),
  //                     //                 ),
  //                     //                 child: Padding(
  //                     //                   padding: const EdgeInsets.symmetric(
  //                     //                       vertical: 4.0),
  //                     //                   child: SizedBox(
  //                     //                     width: 80,
  //                     //                     height: 35,
  //                     //                     child: Padding(
  //                     //                       padding: const EdgeInsets.symmetric(
  //                     //                           vertical: 6.0),
  //                     //                       child: Image.asset(
  //                     //                         "assets/images/paystack.png",
  //                     //                       ),
  //                     //                     ),
  //                     //                   ),
  //                     //                 )),
  //                     //             const SizedBox(
  //                     //               width: 20,
  //                     //             ),
  //                     //             Text("PayStack".tr),
  //                     //           ],
  //                     //         ),
  //                     //         //toggleable: true,
  //                     //       ),
  //                     //     ),
  //                     //   ),
  //                     // ),
  //                     // Visibility(
  //                     //   visible:
  //                     //       controller.paymentSettingModel.value.flutterWave !=
  //                     //                   null &&
  //                     //               controller.paymentSettingModel.value
  //                     //                       .flutterWave!.isEnabled ==
  //                     //                   "true"
  //                     //           ? true
  //                     //           : false,
  //                     //   child: Padding(
  //                     //     padding: const EdgeInsets.symmetric(vertical: 3.0),
  //                     //     child: Card(
  //                     //       shape: RoundedRectangleBorder(
  //                     //         borderRadius: BorderRadius.circular(8),
  //                     //       ),
  //                     //       elevation: controller.flutterWave.value ? 0 : 2,
  //                     //       child: RadioListTile(
  //                     //         shape: RoundedRectangleBorder(
  //                     //             borderRadius: BorderRadius.circular(8),
  //                     //             side: BorderSide(
  //                     //                 color: controller.flutterWave.value
  //                     //                     ? ConstantColors.primary
  //                     //                     : Colors.transparent)),
  //                     //         controlAffinity: ListTileControlAffinity.trailing,
  //                     //         value: "FlutterWave",
  //                     //         groupValue: controller.paymentMethodType.value,
  //                     //         onChanged: (String? value) {
  //                     //           controller.stripe = false.obs;
  //                     //           controller.wallet = false.obs;
  //                     //           controller.cash = false.obs;
  //                     //           controller.razorPay = false.obs;
  //                     //           controller.payTm = false.obs;
  //                     //           controller.paypal = false.obs;
  //                     //           controller.payStack = false.obs;
  //                     //           controller.flutterWave = true.obs;
  //                     //           controller.mercadoPago = false.obs;
  //                     //           controller.payFast = false.obs;
  //                     //           controller.paymentMethodType.value = value!;
  //                     //           controller.paymentMethodId.value = controller
  //                     //               .paymentSettingModel
  //                     //               .value
  //                     //               .flutterWave!
  //                     //               .idPaymentMethod
  //                     //               .toString();
  //                     //           Get.back();
  //                     //         },
  //                     //         selected: controller.flutterWave.value,
  //                     //         contentPadding: const EdgeInsets.symmetric(
  //                     //           horizontal: 6,
  //                     //         ),
  //                     //         title: Row(
  //                     //           mainAxisAlignment: MainAxisAlignment.start,
  //                     //           children: [
  //                     //             Container(
  //                     //                 decoration: BoxDecoration(
  //                     //                   color: Colors.blueGrey.shade50,
  //                     //                   borderRadius: BorderRadius.circular(8),
  //                     //                 ),
  //                     //                 child: Padding(
  //                     //                   padding: const EdgeInsets.symmetric(
  //                     //                       vertical: 4.0),
  //                     //                   child: SizedBox(
  //                     //                     width: 80,
  //                     //                     height: 35,
  //                     //                     child: Padding(
  //                     //                       padding: const EdgeInsets.symmetric(
  //                     //                           vertical: 6.0),
  //                     //                       child: Image.asset(
  //                     //                         "assets/images/flutterwave.png",
  //                     //                       ),
  //                     //                     ),
  //                     //                   ),
  //                     //                 )),
  //                     //             const SizedBox(
  //                     //               width: 20,
  //                     //             ),
  //                     //             Text("FlutterWave".tr),
  //                     //           ],
  //                     //         ),
  //                     //         //toggleable: true,
  //                     //       ),
  //                     //     ),
  //                     //   ),
  //                     // ),
  //                     // Visibility(
  //                     //   visible:
  //                     //       controller.paymentSettingModel.value.razorpay !=
  //                     //                   null &&
  //                     //               controller.paymentSettingModel.value
  //                     //                       .razorpay!.isEnabled ==
  //                     //                   "true"
  //                     //           ? true
  //                     //           : false,
  //                     //   child: Padding(
  //                     //     padding: const EdgeInsets.symmetric(vertical: 3.0),
  //                     //     child: Card(
  //                     //       shape: RoundedRectangleBorder(
  //                     //         borderRadius: BorderRadius.circular(8),
  //                     //       ),
  //                     //       elevation: controller.razorPay.value ? 0 : 2,
  //                     //       child: RadioListTile(
  //                     //         shape: RoundedRectangleBorder(
  //                     //             borderRadius: BorderRadius.circular(8),
  //                     //             side: BorderSide(
  //                     //                 color: controller.razorPay.value
  //                     //                     ? ConstantColors.primary
  //                     //                     : Colors.transparent)),
  //                     //         contentPadding: const EdgeInsets.symmetric(
  //                     //           horizontal: 6,
  //                     //         ),
  //                     //         controlAffinity: ListTileControlAffinity.trailing,
  //                     //         value: "RazorPay",
  //                     //         groupValue: controller.paymentMethodType.value,
  //                     //         onChanged: (String? value) {
  //                     //           controller.stripe = false.obs;
  //                     //           controller.wallet = false.obs;
  //                     //           controller.cash = false.obs;
  //                     //           controller.razorPay = true.obs;
  //                     //           controller.payTm = false.obs;
  //                     //           controller.paypal = false.obs;
  //                     //           controller.payStack = false.obs;
  //                     //           controller.flutterWave = false.obs;
  //                     //           controller.mercadoPago = false.obs;
  //                     //           controller.payFast = false.obs;
  //                     //           controller.paymentMethodType.value = value!;
  //                     //           controller.paymentMethodId.value = controller
  //                     //               .paymentSettingModel
  //                     //               .value
  //                     //               .razorpay!
  //                     //               .idPaymentMethod
  //                     //               .toString();
  //                     //           Get.back();
  //                     //         },
  //                     //         selected: controller.razorPay.value,
  //                     //         title: Row(
  //                     //           mainAxisAlignment: MainAxisAlignment.start,
  //                     //           children: [
  //                     //             Container(
  //                     //                 decoration: BoxDecoration(
  //                     //                   color: Colors.blueGrey.shade50,
  //                     //                   borderRadius: BorderRadius.circular(8),
  //                     //                 ),
  //                     //                 child: Padding(
  //                     //                   padding: const EdgeInsets.symmetric(
  //                     //                       vertical: 3.0),
  //                     //                   child: SizedBox(
  //                     //                       width: 80,
  //                     //                       height: 35,
  //                     //                       child: Image.asset(
  //                     //                           "assets/images/razorpay_@3x.png")),
  //                     //                 )),
  //                     //             const SizedBox(
  //                     //               width: 20,
  //                     //             ),
  //                     //             Text("RazorPay".tr),
  //                     //           ],
  //                     //         ),
  //                     //         //toggleable: true,
  //                     //       ),
  //                     //     ),
  //                     //   ),
  //                     // ),
  //                     // Visibility(
  //                     //   visible: controller.paymentSettingModel.value.payFast !=
  //                     //               null &&
  //                     //           controller.paymentSettingModel.value.payFast!
  //                     //                   .isEnabled ==
  //                     //               "true"
  //                     //       ? true
  //                     //       : false,
  //                     //   child: Padding(
  //                     //     padding: const EdgeInsets.symmetric(vertical: 4.0),
  //                     //     child: Card(
  //                     //       shape: RoundedRectangleBorder(
  //                     //         borderRadius: BorderRadius.circular(8),
  //                     //       ),
  //                     //       elevation: controller.payFast.value ? 0 : 2,
  //                     //       child: RadioListTile(
  //                     //         shape: RoundedRectangleBorder(
  //                     //             borderRadius: BorderRadius.circular(8),
  //                     //             side: BorderSide(
  //                     //                 color: controller.payFast.value
  //                     //                     ? ConstantColors.primary
  //                     //                     : Colors.transparent)),
  //                     //         controlAffinity: ListTileControlAffinity.trailing,
  //                     //         value: "PayFast",
  //                     //         groupValue: controller.paymentMethodType.value,
  //                     //         onChanged: (String? value) {
  //                     //           controller.stripe = false.obs;
  //                     //           controller.wallet = false.obs;
  //                     //           controller.cash = false.obs;
  //                     //           controller.razorPay = false.obs;
  //                     //           controller.payTm = false.obs;
  //                     //           controller.paypal = false.obs;
  //                     //           controller.payStack = false.obs;
  //                     //           controller.flutterWave = false.obs;
  //                     //           controller.mercadoPago = false.obs;
  //                     //           controller.payFast = true.obs;
  //                     //           controller.paymentMethodType.value = value!;
  //                     //           controller.paymentMethodId.value = controller
  //                     //               .paymentSettingModel
  //                     //               .value
  //                     //               .payFast!
  //                     //               .idPaymentMethod
  //                     //               .toString();
  //                     //           Get.back();
  //                     //         },
  //                     //         selected: controller.payFast.value,
  //                     //         //selectedRadioTile == "strip" ? true : false,
  //                     //         contentPadding: const EdgeInsets.symmetric(
  //                     //           horizontal: 6,
  //                     //         ),
  //                     //         title: Row(
  //                     //           mainAxisAlignment: MainAxisAlignment.start,
  //                     //           children: [
  //                     //             Container(
  //                     //                 decoration: BoxDecoration(
  //                     //                   color: Colors.blueGrey.shade50,
  //                     //                   borderRadius: BorderRadius.circular(8),
  //                     //                 ),
  //                     //                 child: Padding(
  //                     //                   padding: const EdgeInsets.symmetric(
  //                     //                       vertical: 4.0),
  //                     //                   child: SizedBox(
  //                     //                     width: 80,
  //                     //                     height: 35,
  //                     //                     child: Padding(
  //                     //                       padding: const EdgeInsets.symmetric(
  //                     //                           vertical: 6.0),
  //                     //                       child: Image.asset(
  //                     //                         "assets/images/payfast.png",
  //                     //                       ),
  //                     //                     ),
  //                     //                   ),
  //                     //                 )),
  //                     //             const SizedBox(
  //                     //               width: 20,
  //                     //             ),
  //                     //             Text("Pay Fast".tr),
  //                     //           ],
  //                     //         ),
  //                     //         //toggleable: true,
  //                     //       ),
  //                     //     ),
  //                     //   ),
  //                     // ),
  //                     // Visibility(
  //                     //   visible: controller.paymentSettingModel.value.paytm !=
  //                     //               null &&
  //                     //           controller.paymentSettingModel.value.paytm!
  //                     //                   .isEnabled ==
  //                     //               "true"
  //                     //       ? true
  //                     //       : false,
  //                     //   child: Padding(
  //                     //     padding: const EdgeInsets.symmetric(vertical: 3.0),
  //                     //     child: Card(
  //                     //       shape: RoundedRectangleBorder(
  //                     //         borderRadius: BorderRadius.circular(8),
  //                     //       ),
  //                     //       elevation: controller.payTm.value ? 0 : 2,
  //                     //       child: RadioListTile(
  //                     //         shape: RoundedRectangleBorder(
  //                     //             borderRadius: BorderRadius.circular(8),
  //                     //             side: BorderSide(
  //                     //                 color: controller.payTm.value
  //                     //                     ? ConstantColors.primary
  //                     //                     : Colors.transparent)),
  //                     //         contentPadding: const EdgeInsets.symmetric(
  //                     //           horizontal: 6,
  //                     //         ),
  //                     //         controlAffinity: ListTileControlAffinity.trailing,
  //                     //         value: "PayTm",
  //                     //         groupValue: controller.paymentMethodType.value,
  //                     //         onChanged: (String? value) {
  //                     //           controller.stripe = false.obs;
  //                     //           controller.wallet = false.obs;
  //                     //           controller.cash = false.obs;
  //                     //           controller.razorPay = false.obs;
  //                     //           controller.payTm = true.obs;
  //                     //           controller.paypal = false.obs;
  //                     //           controller.payStack = false.obs;
  //                     //           controller.flutterWave = false.obs;
  //                     //           controller.mercadoPago = false.obs;
  //                     //           controller.payFast = false.obs;
  //                     //           controller.paymentMethodType.value = value!;
  //                     //           controller.paymentMethodId.value = controller
  //                     //               .paymentSettingModel
  //                     //               .value
  //                     //               .paytm!
  //                     //               .idPaymentMethod
  //                     //               .toString();
  //                     //           Get.back();
  //                     //         },
  //                     //         selected: controller.payTm.value,
  //                     //         title: Row(
  //                     //           mainAxisAlignment: MainAxisAlignment.start,
  //                     //           children: [
  //                     //             Container(
  //                     //                 decoration: BoxDecoration(
  //                     //                   color: Colors.blueGrey.shade50,
  //                     //                   borderRadius: BorderRadius.circular(8),
  //                     //                 ),
  //                     //                 child: Padding(
  //                     //                   padding: const EdgeInsets.symmetric(
  //                     //                       vertical: 3.0),
  //                     //                   child: SizedBox(
  //                     //                       width: 80,
  //                     //                       height: 35,
  //                     //                       child: Padding(
  //                     //                         padding:
  //                     //                             const EdgeInsets.symmetric(
  //                     //                                 vertical: 3.0),
  //                     //                         child: Image.asset(
  //                     //                           "assets/images/paytm_@3x.png",
  //                     //                         ),
  //                     //                       )),
  //                     //                 )),
  //                     //             const SizedBox(
  //                     //               width: 20,
  //                     //             ),
  //                     //             Text("Paytm".tr),
  //                     //           ],
  //                     //         ),
  //                     //         //toggleable: true,
  //                     //       ),
  //                     //     ),
  //                     //   ),
  //                     // ),
  //                     // Visibility(
  //                     //   visible:
  //                     //       controller.paymentSettingModel.value.mercadopago !=
  //                     //                   null &&
  //                     //               controller.paymentSettingModel.value
  //                     //                       .mercadopago!.isEnabled ==
  //                     //                   "true"
  //                     //           ? true
  //                     //           : false,
  //                     //   child: Padding(
  //                     //     padding: const EdgeInsets.symmetric(vertical: 4.0),
  //                     //     child: Card(
  //                     //       shape: RoundedRectangleBorder(
  //                     //         borderRadius: BorderRadius.circular(8),
  //                     //       ),
  //                     //       elevation: controller.mercadoPago.value ? 0 : 2,
  //                     //       child: RadioListTile(
  //                     //         shape: RoundedRectangleBorder(
  //                     //             borderRadius: BorderRadius.circular(8),
  //                     //             side: BorderSide(
  //                     //                 color: controller.mercadoPago.value
  //                     //                     ? ConstantColors.primary
  //                     //                     : Colors.transparent)),
  //                     //         controlAffinity: ListTileControlAffinity.trailing,
  //                     //         value: "MercadoPago",
  //                     //         groupValue: controller.paymentMethodType.value,
  //                     //         onChanged: (String? value) {
  //                     //           controller.stripe = false.obs;
  //                     //           controller.wallet = false.obs;
  //                     //           controller.cash = false.obs;
  //                     //           controller.razorPay = false.obs;
  //                     //           controller.payTm = false.obs;
  //                     //           controller.paypal = false.obs;
  //                     //           controller.payStack = false.obs;
  //                     //           controller.flutterWave = false.obs;
  //                     //           controller.mercadoPago = true.obs;
  //                     //           controller.payFast = false.obs;
  //                     //           controller.paymentMethodType.value = value!;
  //                     //           controller.paymentMethodId.value = controller
  //                     //               .paymentSettingModel
  //                     //               .value
  //                     //               .mercadopago!
  //                     //               .idPaymentMethod
  //                     //               .toString();
  //                     //           Get.back();
  //                     //         },
  //                     //         selected: controller.mercadoPago.value,
  //                     //         contentPadding: const EdgeInsets.symmetric(
  //                     //           horizontal: 6,
  //                     //         ),
  //                     //         title: Row(
  //                     //           mainAxisAlignment: MainAxisAlignment.start,
  //                     //           children: [
  //                     //             Container(
  //                     //                 decoration: BoxDecoration(
  //                     //                   color: Colors.blueGrey.shade50,
  //                     //                   borderRadius: BorderRadius.circular(8),
  //                     //                 ),
  //                     //                 child: Padding(
  //                     //                   padding: const EdgeInsets.symmetric(
  //                     //                       vertical: 4.0),
  //                     //                   child: SizedBox(
  //                     //                     width: 80,
  //                     //                     height: 35,
  //                     //                     child: Padding(
  //                     //                       padding: const EdgeInsets.symmetric(
  //                     //                           vertical: 6.0),
  //                     //                       child: Image.asset(
  //                     //                         "assets/images/mercadopago.png",
  //                     //                       ),
  //                     //                     ),
  //                     //                   ),
  //                     //                 )),
  //                     //             const SizedBox(
  //                     //               width: 20,
  //                     //             ),
  //                     //             Text("Mercado Pago".tr),
  //                     //           ],
  //                     //         ),
  //                     //         //toggleable: true,
  //                     //       ),
  //                     //     ),
  //                     //   ),
  //                     // ),
  //                     // Visibility(
  //                     //   visible: controller.paymentSettingModel.value.payPal !=
  //                     //               null &&
  //                     //           controller.paymentSettingModel.value.payPal!
  //                     //                   .isEnabled ==
  //                     //               "true"
  //                     //       ? true
  //                     //       : false,
  //                     //   child: Padding(
  //                     //     padding: const EdgeInsets.symmetric(vertical: 3.0),
  //                     //     child: Card(
  //                     //       shape: RoundedRectangleBorder(
  //                     //         borderRadius: BorderRadius.circular(8),
  //                     //       ),
  //                     //       elevation: controller.paypal.value ? 0 : 2,
  //                     //       child: RadioListTile(
  //                     //         shape: RoundedRectangleBorder(
  //                     //             borderRadius: BorderRadius.circular(8),
  //                     //             side: BorderSide(
  //                     //                 color: controller.paypal.value
  //                     //                     ? ConstantColors.primary
  //                     //                     : Colors.transparent)),
  //                     //         contentPadding: const EdgeInsets.symmetric(
  //                     //           horizontal: 6,
  //                     //         ),
  //                     //         controlAffinity: ListTileControlAffinity.trailing,
  //                     //         value: "PayPal",
  //                     //         groupValue: controller.paymentMethodType.value,
  //                     //         onChanged: (String? value) {
  //                     //           controller.stripe = false.obs;
  //                     //           controller.wallet = false.obs;
  //                     //           controller.cash = false.obs;
  //                     //           controller.razorPay = false.obs;
  //                     //           controller.payTm = false.obs;
  //                     //           controller.paypal = true.obs;
  //                     //           controller.payStack = false.obs;
  //                     //           controller.flutterWave = false.obs;
  //                     //           controller.mercadoPago = false.obs;
  //                     //           controller.payFast = false.obs;
  //                     //           controller.paymentMethodType.value = value!;
  //                     //           controller.paymentMethodId.value = controller
  //                     //               .paymentSettingModel
  //                     //               .value
  //                     //               .payPal!
  //                     //               .idPaymentMethod
  //                     //               .toString();
  //                     //           Get.back();
  //                     //         },
  //                     //         selected: controller.paypal.value,
  //                     //         title: Row(
  //                     //           mainAxisAlignment: MainAxisAlignment.start,
  //                     //           children: [
  //                     //             Container(
  //                     //                 decoration: BoxDecoration(
  //                     //                   color: Colors.blueGrey.shade50,
  //                     //                   borderRadius: BorderRadius.circular(8),
  //                     //                 ),
  //                     //                 child: Padding(
  //                     //                   padding: const EdgeInsets.symmetric(
  //                     //                       vertical: 3.0),
  //                     //                   child: SizedBox(
  //                     //                       width: 80,
  //                     //                       height: 35,
  //                     //                       child: Padding(
  //                     //                         padding:
  //                     //                             const EdgeInsets.symmetric(
  //                     //                                 vertical: 3.0),
  //                     //                         child: Image.asset(
  //                     //                             "assets/images/paypal_@3x.png"),
  //                     //                       )),
  //                     //                 )),
  //                     //             const SizedBox(
  //                     //               width: 20,
  //                     //             ),
  //                     //             Text("PayPal".tr),
  //                     //           ],
  //                     //         ),
  //                     //         //toggleable: true,
  //                     //       ),
  //                     //     ),
  //                     //   ),
  //                     // ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           );
  //         });
  //       });
  // }

  // _paymentMethodDialog(BuildContext context, List<PaymentMethodData>? data) {
  //   return showModalBottomSheet(
  //       shape: const RoundedRectangleBorder(
  //           borderRadius: BorderRadius.only(
  //               topRight: Radius.circular(15), topLeft: Radius.circular(15))),
  //       context: context,
  //       isScrollControlled: true,
  //       isDismissible: false,
  //       builder: (context) {
  //         return StatefulBuilder(builder: (context, setState) {
  //           return Padding(
  //             padding:
  //                 const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 const Text("Select Payment Method1"),
  //                 Divider(
  //                   color: Colors.grey.shade700,
  //                 ),
  //                 ListView.builder(
  //                   shrinkWrap: true,
  //                   itemCount: data!.length,
  //                   itemBuilder: (context, index) {
  //                     return InkWell(
  //                       onTap: () {
  //                         controller.paymentMethodData = data[index];
  //                         controller.paymentMethodType.value =
  //                             data[index].libelle.toString();
  //                         Get.back();
  //                       },
  //                       child: Padding(
  //                         padding: const EdgeInsets.all(8.0),
  //                         child: Row(
  //                           children: [
  //                             Padding(
  //                               padding: const EdgeInsets.symmetric(
  //                                   vertical: 8, horizontal: 5),
  //                               child: Container(
  //                                 decoration: BoxDecoration(
  //                                   color: Colors.blueGrey.shade50,
  //                                   borderRadius: BorderRadius.circular(8),
  //                                 ),
  //                                 child: Padding(
  //                                   padding: const EdgeInsets.symmetric(
  //                                       vertical: 4.0),
  //                                   child: SizedBox(
  //                                     width: 80,
  //                                     height: 35,
  //                                     child: Padding(
  //                                       padding: const EdgeInsets.symmetric(
  //                                           vertical: 6.0),
  //                                       child: CachedNetworkImage(
  //                                         imageUrl: data[index].image!,
  //                                         placeholder: (context, url) =>
  //                                             const CircularProgressIndicator(),
  //                                         errorWidget: (context, url, error) =>
  //                                             const Icon(Icons.error),
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ),
  //                             ),
  //                             Padding(
  //                               padding: const EdgeInsets.only(left: 10),
  //                               child: Text(
  //                                 data[index].libelle.toString(),
  //                                 style: const TextStyle(color: Colors.black),
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     );
  //                   },
  //                 )
  //               ],
  //             ),
  //           );
  //         });
  //       });
  // }

  buildDetails({title, value, Color txtColor = Colors.black}) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
          color: Colors.blueGrey.shade50,
          borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: 0.9,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 15, color: txtColor, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(
            height: 6,
          ),
          Opacity(
            opacity: 0.6,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
