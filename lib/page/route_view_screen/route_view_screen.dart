import 'dart:convert' as math;
import 'dart:developer';

import 'package:citgroupvn_car/constant/constant.dart';
import 'package:citgroupvn_car/constant/show_toast_dialog.dart';
import 'package:citgroupvn_car/controller/dash_board_controller.dart';
import 'package:citgroupvn_car/controller/ride_details_controller.dart';
import 'package:citgroupvn_car/model/ride_model.dart';
import 'package:citgroupvn_car/page/chats_screen/conversation_screen.dart';
import 'package:citgroupvn_car/service/api.dart';
import 'package:citgroupvn_car/themes/button_them.dart';
import 'package:citgroupvn_car/themes/constant_colors.dart';
import 'package:citgroupvn_car/themes/custom_alert_dialog.dart';
import 'package:citgroupvn_car/themes/custom_dialog_box.dart';
import 'package:citgroupvn_car/utils/Preferences.dart';
import 'package:citgroupvn_car/widget/StarRating.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RouteViewScreen extends StatefulWidget {
  const RouteViewScreen({Key? key}) : super(key: key);

  @override
  State<RouteViewScreen> createState() => _RouteViewScreenState();
}

class _RouteViewScreenState extends State<RouteViewScreen>
    with TickerProviderStateMixin {
  dynamic argumentData = Get.arguments;
  static const _startedId = 'AnimatedMapController#MoveStarted';
  static const _inProgressId = 'AnimatedMapController#MoveInProgress';
  static const _finishedId = 'AnimatedMapController#MoveFinished';
  final MapController _controller = MapController();

  // Map<PolylineId, Polyline> polyLines = {};
  final LatLng _kInitialPosition = LatLng(20.989519, 105.807129);
  final double _initZoom = 14.0;
  bool _showDetail = true;

  List<LatLng> polylinePoints = [];

  String departureIcon = '';
  String destinationIcon = '';
  String taxiIcon = '';
  String stopIcon = '';

  late LatLng departureLatLong;
  LatLng? destinationLatLong;

  final Map<String, Marker> _markers = {};

  String? type;
  RideData? rideData;
  String driverEstimateArrivalTime = '';

  @override
  void initState() {
    setIcons();
    getArgumentData();

    super.initState();
  }

  final controllerRideDetails = Get.put(RideDetailsController());
  final controllerDashBoard = Get.put(DashBoardController());

  getArgumentData() {
    if (argumentData != null) {
      type = argumentData['type'];
      rideData = argumentData['data'];

      departureLatLong = LatLng(
          double.parse(rideData!.latitudeDepart.toString()),
          double.parse(rideData!.longitudeDepart.toString()));
      if(rideData!.latitudeArrivee != null && rideData!.longitudeArrivee != null) {
        destinationLatLong = LatLng(
            double.parse(rideData!.latitudeArrivee.toString()),
            double.parse(rideData!.longitudeArrivee.toString()));
      }
    }
  }

  updateRoute() async {
    if (rideData!.statut == "on ride" || rideData!.statut == 'confirmed') {
      String orderId = "";
      if (rideData!.rideType! == 'driver') {
        orderId =
            '${rideData!.idUserApp}-${rideData!.id}-${rideData!.idConducteur}';
      } else {
        orderId = (int.parse(rideData!.idUserApp.toString()) <
                int.parse(rideData!.idConducteur.toString()))
            ? '${rideData!.idUserApp}-${rideData!.id}-${rideData!.idConducteur}'
            : '${rideData!.idConducteur}-${rideData!.id}-${rideData!.idUserApp}';
      }
      Constant.location_update.doc(orderId).snapshots().listen((event) async {
        var latitude = event['driver_latitude'];
        var longLatitude = event['driver_longitude'];
        var rotation = event['rotation'];
        log('latitude = $latitude');
        log('longLatitude = $longLatitude');
        log('rideData!.latitudeDepart = ${rideData!.latitudeDepart}');
        if(longLatitude != null && latitude!= null) {
          try{
            var url = Uri.parse("https://rsapi.goong.io/DistanceMatrix?"
                "origins=${rideData!.latitudeDepart}%2C${rideData!.longitudeDepart}"
                "&destinations=$latitude%2C$longLatitude"
                "&vehicle=bike&api_key=${Constant.goongApiKey}");
            var response = await client.get(url);
            log('jsonResponse = ${response.body}');
            final jsonResponse = math.jsonDecode(response.body);
            driverEstimateArrivalTime = jsonResponse['rows'][0]['elements'][0]
            ['duration']['text']
                .toString();
          } catch(e) {
            log('error = $e');
          }
        }

        if (latitude != null && longLatitude != null) {
          departureLatLong = LatLng(double.parse(latitude.toString()),
              double.parse(longLatitude.toString()));
          // var rideSymbol = SymbolOptions(
          //     textField: rideData!.prenomConducteur.toString(),
          //     textColor: ConstantColors.violetColorStr,
          //     geometry: departureLatLong,
          //     iconImage: taxiIcon,
          //     iconSize: 1,
          //     iconRotate: rotation,
          //     textOffset: const Offset(0, 2));
          _markers[rideData!.id.toString()] = Marker(
            point: departureLatLong,
            builder: (context) {
              return Transform.rotate(
                  angle: rotation, child: Image.asset(taxiIcon));
            },
          );
        }

        // _markers[rideData!.id.toString()] = Marker(
        //     markerId: MarkerId(rideData!.id.toString()),
        //     infoWindow:
        //         InfoWindow(title: rideData!.prenomConducteur.toString()),
        //     position: departureLatLong,
        //     icon: taxiIcon!,
        //     rotation: rotation);
        getDirections(dLat: latitude, dLng: longLatitude);
      });
    } else {
      getDirections(dLat: 0.0, dLng: 0.0);
    }
  }

  setIcons() {
    departureIcon = "assets/icons/pickup.png";
    destinationIcon = "assets/icons/dropoff.png";
    taxiIcon = "assets/icons/ic_taxi.png";
    stopIcon = "assets/icons/location.png";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // MapboxMap(
          //   myLocationEnabled: false,
          //   initialCameraPosition: const CameraPosition(
          //     target: LatLng(48.8561, 2.2930),
          //     zoom: 15.0,
          //   ),
          //   styleString: MapboxStyles.MAPBOX_STREETS,
          //   accessToken: Constant.mapBoxAccessToken,
          //   onMapCreated: (MapboxMapController controller) async {
          //     _controller = controller;
          //     setupSymbolManager();
          //     _controller?.moveCamera(
          //         CameraUpdate.newLatLngZoom(departureLatLong, 12));
          //     _controller?.moveCamera(CameraUpdate.scrollBy(0, -50));
          //     controller.onSymbolTapped.add((argument) {
          //       _onSymbolTapped(argument);
          //     });
          //     await updateRoute();
          //   },
          // ),
          FlutterMap(
            mapController: _controller,
            options: MapOptions(
                center: _kInitialPosition,
                zoom: _initZoom,
                minZoom: 10,
                maxZoom: 17,
                onMapReady: () async {
                  await updateRoute();
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
                        var keyMarker = _markers.keys
                            .firstWhere((key) => _markers[key] == marker);
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(keyMarker.tr),
                          ),
                        );
                      })))
            ],
          ),
          Positioned(
            top: 10,
            left: 5,
            child: SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(4),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(Icons.arrow_back_ios_outlined,
                          color: Colors.black),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: SizedBox(
              height: _showDetail
                  ? rideData!.statut == "rejected" ||
                          rideData!.statut == "cancelled"
                      ? Get.height / 2 - 70
                      : Get.height / 2 - 20
                  : 82,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 10,
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 5),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _showDetail = !_showDetail;
                                      });
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.only(top: 0),
                                      child: Center(
                                        child: SizedBox(
                                            width: 30,
                                            child: Divider(
                                              color: Colors.grey,
                                              thickness: 4,
                                            )),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Thông tin địa chỉ',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                              if (_showDetail)
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                children: [
                                                  Image.asset(
                                                    "assets/icons/location.png",
                                                    height: 20,
                                                  ),
                                                  // Image.asset(
                                                  //   "assets/icons/line.png",
                                                  //   height: 30,
                                                  // ),
                                                ],
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Expanded(
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      rideData!.departName
                                                              ?.toString() ??
                                                          "No update location"
                                                              .tr,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    const Divider(),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount:
                                                  rideData!.stops!.length,
                                              itemBuilder:
                                                  (context, int index) {
                                                return Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Column(
                                                      children: [
                                                        Text(
                                                          String.fromCharCode(
                                                              index + 65),
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        // Image.asset(
                                                        //   "assets/icons/line.png",
                                                        //   height: 30,
                                                        //   color: ConstantColors
                                                        //       .hintTextColor,
                                                        // ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            rideData!
                                                                .stops![index]
                                                                .location
                                                                .toString(),
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                          const Divider(),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Image.asset(
                                                "assets/icons/round.png",
                                                height: 18,
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  Constant().getDestinationText(rideData!.destinationName?.toString()),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              if (rideData!.statut == 'confirmed' &&
                                  _showDetail)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Driver Estimate Arrival Time : '.tr,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      Text(
                                        driverEstimateArrivalTime,
                                        style: TextStyle(
                                            color: ConstantColors.yellow,
                                            fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              if (_showDetail)
                                Visibility(
                                  visible: Constant.rideOtp
                                                  .toString()
                                                  .toLowerCase() ==
                                              'yes'.toLowerCase() &&
                                          rideData!.statut == 'confirmed' &&
                                          rideData!.rideType != 'driver'
                                      ? true
                                      : false,
                                  child: Column(
                                    children: [
                                      Divider(
                                        color: Colors.grey.withOpacity(0.20),
                                        thickness: 1,
                                      ),
                                      Row(
                                        children: [
                                          const Text(
                                            'OTP : ',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          Text(
                                            rideData!.otp.toString(),
                                          ),
                                        ],
                                      ),
                                      Divider(
                                        color: Colors.grey.withOpacity(0.20),
                                        thickness: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              if (_showDetail)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // Expanded(
                                      //   child: Padding(
                                      //     padding:
                                      //         const EdgeInsets.only(left: 5.0),
                                      //     child: Container(
                                      //       height: 100,
                                      //       decoration: BoxDecoration(
                                      //           border: Border.all(
                                      //             color: Colors.black12,
                                      //           ),
                                      //           borderRadius:
                                      //               const BorderRadius.all(
                                      //                   Radius.circular(10))),
                                      //       child: Padding(
                                      //         padding: const EdgeInsets.symmetric(
                                      //             vertical: 20),
                                      //         child: Column(
                                      //           mainAxisAlignment:
                                      //               MainAxisAlignment.center,
                                      //           children: [
                                      //             Image.asset(
                                      //               'assets/icons/passenger.png',
                                      //               height: 22,
                                      //               width: 22,
                                      //               color: ConstantColors.yellow,
                                      //             ),
                                      //             Padding(
                                      //               padding:
                                      //                   const EdgeInsets.only(
                                      //                       top: 8.0),
                                      //               child: Text(
                                      //                   " ${rideData!.numberPoeple.toString()}",
                                      //                   //DateFormat('\$ KK:mm a, dd MMM yyyy').format(date),
                                      //                   style: const TextStyle(
                                      //                       fontWeight:
                                      //                           FontWeight.w800,
                                      //                       color:
                                      //                           Colors.black54)),
                                      //             ),
                                      //           ],
                                      //         ),
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),
                                      Expanded(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5.0),
                                          child: Container(
                                            height: 100,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.black12,
                                                ),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(10))),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 20),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                    'assets/icons/price.png',
                                                    height: 22,
                                                    width: 22,
                                                    color:
                                                        ConstantColors.yellow,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 8),
                                                    child: SizedBox(
                                                      width: double.infinity,
                                                      child: Text(
                                                        textAlign:
                                                            TextAlign.center,
                                                        Constant().amountShow(
                                                            amount: rideData!
                                                                .montant!
                                                                .toString()),
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          color: Colors.black54,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5.0),
                                          child: Container(
                                            height: 100,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.black12,
                                                ),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(10))),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 20),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                    'assets/icons/ic_distance.png',
                                                    height: 22,
                                                    width: 22,
                                                    color:
                                                        ConstantColors.yellow,
                                                  ),
                                                  SizedBox(
                                                    width: double.infinity,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 8.0),
                                                      child: Text(
                                                        textAlign:
                                                            TextAlign.center,
                                                        "${rideData!.distance.toString()} "
                                                        "${(rideData?.distanceUnit?.isNotEmpty == true) ? rideData?.distanceUnit! : "Km"}",
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          color: Colors.black54,
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
                                      Expanded(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5.0),
                                          child: Container(
                                            height: 100,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.black12,
                                                ),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(10))),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 20),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                    'assets/icons/time.png',
                                                    height: 22,
                                                    width: 22,
                                                    color:
                                                        ConstantColors.yellow,
                                                  ),
                                                  SizedBox(
                                                    width: double.infinity,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 8.0),
                                                      child: Text(
                                                        rideData!.duree
                                                            .toString(),
                                                        textAlign:
                                                            TextAlign.center,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          color: Colors.black54,
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
                              if (_showDetail)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10),
                                  child: InkWell(
                                    onTap: () {
                                      _showDriverInfoScreen(context, rideData!);
                                    },
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                rideData!.photoPath.toString(),
                                            height: 80,
                                            width: 80,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Constant.loader(),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    "${rideData!.prenomConducteur.toString()} ${rideData!.nomConducteur.toString()}",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        color: Colors.black87,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                                StarRating(
                                                    size: 18,
                                                    rating: rideData!.moyenne !=
                                                            "null"
                                                        ? double.parse(rideData!
                                                            .moyenne
                                                            .toString())
                                                        : 0.0,
                                                    color:
                                                        ConstantColors.yellow),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Row(
                                              children: [
                                                Visibility(
                                                  visible: rideData!.statut ==
                                                          "confirmed"
                                                      ? true
                                                      : false,
                                                  child: InkWell(
                                                      onTap: () {
                                                        Get.to(
                                                            ConversationScreen(),
                                                            arguments: {
                                                              'receiverId': int
                                                                  .parse(rideData!
                                                                      .idConducteur
                                                                      .toString()),
                                                              'orderId': int
                                                                  .parse(rideData!
                                                                      .id
                                                                      .toString()),
                                                              'receiverName':
                                                                  "${rideData!.prenomConducteur} ${rideData!.nomConducteur}",
                                                              'receiverPhoto':
                                                                  rideData!
                                                                      .photoPath
                                                            });
                                                      },
                                                      child: Image.asset(
                                                        'assets/icons/chat_icon.png',
                                                        height: 36,
                                                        width: 36,
                                                      )),
                                                ),
                                                // rideData!.statut != "completed"
                                                //     ? Padding(
                                                //   padding:
                                                //   const EdgeInsets.only(
                                                //       left: 10),
                                                //   child: InkWell(
                                                //       onTap: () async {
                                                //         ShowToastDialog
                                                //             .showLoader(
                                                //             "Vui lòng đợi"
                                                //                 .tr);
                                                //         final Location
                                                //         currentLocation =
                                                //         Location();
                                                //         LocationData
                                                //         location =
                                                //         await currentLocation
                                                //             .getLocation();
                                                //
                                                //         await FlutterShareMe()
                                                //             .shareToWhatsApp(
                                                //             msg:
                                                //             'https://www.google.com/maps/search/?api=1&query=${location
                                                //                 .latitude},${location
                                                //                 .longitude}');
                                                //       },
                                                //       child: Container(
                                                //           height: 36,
                                                //           width: 36,
                                                //           decoration:
                                                //           BoxDecoration(
                                                //             shape: BoxShape
                                                //                 .circle,
                                                //             color:
                                                //             ConstantColors
                                                //                 .blueColor,
                                                //           ),
                                                //           child: const Icon(
                                                //             Icons
                                                //                 .share_rounded,
                                                //             size: 26,
                                                //             color:
                                                //             Colors.white,
                                                //           ))),
                                                // )
                                                //     : const Offstage(),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10),
                                                  child: InkWell(
                                                      onTap: () {
                                                        Constant.makePhoneCall(
                                                            rideData!
                                                                .driverPhone
                                                                .toString());
                                                      },
                                                      child: Image.asset(
                                                        'assets/icons/call_icon.png',
                                                        height: 36,
                                                        width: 36,
                                                      )),
                                                ),
                                                Visibility(
                                                  visible: rideData!.statut ==
                                                          "on ride"
                                                      ? true
                                                      : false,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10),
                                                    child:
                                                        ButtonThem.buildButton(
                                                      context,
                                                      title: 'sos'.tr,
                                                      btnHeight: 35,
                                                      btnWidthRatio: 0.16,
                                                      btnColor: ConstantColors
                                                          .primary,
                                                      txtColor: Colors.white,
                                                      onPress: () async {
                                                        LocationData location =
                                                            await Location()
                                                                .getLocation();
                                                        Map<String, dynamic>
                                                            bodyParams = {
                                                          'lat':
                                                              location.latitude,
                                                          'lng': location
                                                              .longitude,
                                                          'ride_id':
                                                              rideData!.id,
                                                        };
                                                        controllerRideDetails
                                                            .sos(bodyParams)
                                                            .then((value) {
                                                          if (value != null) {
                                                            if (value[
                                                                    'success'] ==
                                                                "success") {
                                                              ShowToastDialog
                                                                  .showToast(value[
                                                                          'message']
                                                                      .toString()
                                                                      .tr);
                                                            }
                                                          }
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 5.0),
                                              child: Text(
                                                  Constant().formatDate(
                                                      rideData!.dateRetour
                                                          .toString()),
                                                  style: const TextStyle(
                                                      color: Colors.black26,
                                                      fontWeight:
                                                          FontWeight.w600)),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              if (_showDetail)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Row(
                                    children: [
                                      Visibility(
                                        visible: rideData!.statut == "on ride"
                                            ? true
                                            : false,
                                        child: Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 5),
                                            child: ButtonThem.buildButton(
                                              context,
                                              title: 'safe_message'.tr,
                                              btnHeight: 45,
                                              btnWidthRatio: 0.8,
                                              btnColor: ConstantColors.primary,
                                              txtColor: Colors.white,
                                              onPress: () async {
                                                LocationData location =
                                                    await Location()
                                                        .getLocation();
                                                Map<String, dynamic>
                                                    bodyParams = {
                                                  'lat': location.latitude,
                                                  'lng': location.longitude,
                                                  'ride_id': rideData?.id,
                                                };
                                                controllerRideDetails
                                                    .feelNotSafe(bodyParams)
                                                    .then((value) {
                                                  if (value != null) {
                                                    if (value['success'] ==
                                                        "success") {
                                                      ShowToastDialog.showToast(
                                                          "Đã gửi báo cáo".tr);
                                                    }
                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: rideData!.statut ==
                                                    "rejected" ||
                                                rideData!.statut == "cancelled"
                                            ? false
                                            : true,
                                        child: Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 5, left: 10),
                                            child: ButtonThem.buildBorderButton(
                                              context,
                                              title: 'Huỷ chuyến'.tr,
                                              btnHeight: 45,
                                              btnWidthRatio: 0.8,
                                              btnColor: Colors.white,
                                              txtColor: ConstantColors.primary,
                                              btnBorderColor:
                                                  ConstantColors.primary,
                                              onPress: () async {
                                                buildShowBottomSheet(context);
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  final resonController = TextEditingController();

  buildShowBottomSheet(BuildContext context) {
    return showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(15), topLeft: Radius.circular(15))),
        context: context,
        isDismissible: true,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
              child: Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "Cancel Trip".tr,
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        "Write a reason for trip cancellation".tr,
                        style: TextStyle(color: Colors.black.withOpacity(0.50)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TextField(
                        controller: resonController,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.0),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: ButtonThem.buildButton(
                                context,
                                title: 'Cancel Trip'.tr,
                                btnHeight: 45,
                                btnWidthRatio: 0.8,
                                btnColor: ConstantColors.primary,
                                txtColor: Colors.white,
                                onPress: () async {
                                  if (resonController.text.isNotEmpty) {
                                    Get.back();
                                    showDialog(
                                      barrierColor: Colors.black26,
                                      context: context,
                                      builder: (context) {
                                        return CustomAlertDialog(
                                          title:
                                              "Do you want to cancel this booking?"
                                                  .tr,
                                          onPressNegative: () {
                                            Get.back();
                                          },
                                          onPressPositive: () {
                                            Map<String, String> bodyParams = {
                                              'id_ride':
                                                  rideData!.id.toString(),
                                              'id_user': rideData!.idConducteur
                                                  .toString(),
                                              'name':
                                                  "${rideData!.prenom} ${rideData!.nom}",
                                              'from_id': Preferences.getInt(
                                                      Preferences.userId)
                                                  .toString(),
                                              'user_cat': controllerRideDetails
                                                  .userModel!.data!.userCat
                                                  .toString(),
                                              'reason': resonController.text
                                                  .toString(),
                                            };
                                            controllerRideDetails
                                                .canceledRide(bodyParams)
                                                .then((value) {
                                              Get.back();
                                              if (value != null) {
                                                showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return CustomDialogBox(
                                                        title:
                                                            "Huỷ chuyến thành công",
                                                        descriptions:
                                                            "Chuyến đi đã được huỷ.",
                                                        onPress: () {
                                                          Get.back();
                                                          controllerDashBoard
                                                              .onSelectItem(1);
                                                        },
                                                        img: Image.asset(
                                                            'assets/images/green_checked.png'),
                                                      );
                                                    });
                                              }
                                            });
                                          },
                                        );
                                      },
                                    );
                                  } else {
                                    ShowToastDialog.showToast(
                                        "Please enter a reason".tr);
                                  }
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 5, left: 10),
                              child: ButtonThem.buildBorderButton(
                                context,
                                title: 'Đóng'.tr,
                                btnHeight: 45,
                                btnWidthRatio: 0.8,
                                btnColor: Colors.white,
                                txtColor: ConstantColors.primary,
                                btnBorderColor: ConstantColors.primary,
                                onPress: () async {
                                  Get.back();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          });
        });
  }

  getDirections({required double? dLat, required double? dLng}) async {
    // List<LatLng> polylineCoordinates = [];
    RouteInfo? routeInfoResult;
    List<LatLng> wayPointList = [];
    for (var i = 0; i < rideData!.stops!.length; i++) {
      var stopLat = rideData!.stops![i].latitude;
      var stopLng = rideData!.stops![i].longitude;
      if (stopLat != null && stopLng != null) {}
      wayPointList.add(LatLng(double.parse(stopLat!), double.parse(stopLng!)));
    }

    /// Set Marker
    _markers['Departure'] = Marker(
        point: LatLng(double.parse(rideData!.latitudeDepart.toString()),
            double.parse(rideData!.longitudeDepart.toString())),
        builder: (context) {
          return Image.asset(departureIcon);
        });
    // var destinationSymbol = SymbolOptions(
    //     textField: 'Destination'.tr,
    //     textColor: ConstantColors.violetColorStr,
    //     geometry: destinationLatLong,
    //     iconImage: destinationIcon,
    //     iconSize: 1,
    //     zIndex: 10,
    //     textOffset: const Offset(0, 2));
    if(destinationLatLong != null) {
      _markers['Destination'] = Marker(
          point: destinationLatLong!,
          builder: (context) {
            return Image.asset(destinationIcon);
          });
    }
    for (var i = 0; i < rideData!.stops!.length; i++) {
      _markers['${rideData!.stops![i]}'] = Marker(
          anchorPos: AnchorPos.align(AnchorAlign.top),
          point: LatLng(double.parse(rideData!.stops![i].latitude!),
              double.parse(rideData!.stops![i].longitude!)),
          builder: (context) {
            return Image.asset(stopIcon);
          });
      // SymbolOptions(
      // textField: rideData!.stops![i].location!,
      // textColor: ConstantColors.violetColorStr,
      // geometry: LatLng(double.parse(rideData!.stops![i].latitude!),
      //     double.parse(rideData!.stops![i].longitude!)),
      // iconImage: stopIcon,
      // iconSize: 1,
      // textOffset: const Offset(0, 2));

      //     Marker(
      //   markerId: MarkerId('${rideData!.stops![i]}'),
      //   infoWindow: InfoWindow(title: rideData!.stops![i].location!),
      //   position: LatLng(double.parse(rideData!.stops![i].latitude!),
      //       double.parse(rideData!.stops![i].longitude!)),
      //   icon: stopIcon!,
      // );
    }
    setState(() {
      _markers;
    });

    if (rideData!.statut == "confirmed") {
      if(dLat != null && dLng != null) {
        routeInfoResult = await getRouteInfos(
            LatLng(double.parse(rideData!.latitudeDepart.toString()),
                double.parse(rideData!.longitudeDepart.toString())),
            LatLng(dLat, dLng),
            wayPointList);
      }
      // await polylinePoints.getRouteBetweenCoordinates(
      //   Constant.kGoogleApiKey.toString(),
      //   PointLatLng(double.parse(rideData!.latitudeDepart.toString()),
      //       double.parse(rideData!.longitudeDepart.toString())),
      //   PointLatLng(dLat, dLng),
      //   wayPoints: wayPointList,
      //   optimizeWaypoints: true,
      //   travelMode: TravelMode.driving,
      // );
    } else if (rideData!.statut == "on ride") {
      if(destinationLatLong != null && dLat != null && dLng != null) {
        routeInfoResult = await getRouteInfos(
            LatLng(dLat, dLng), destinationLatLong!, wayPointList);
      }
      // result = await polylinePoints.getRouteBetweenCoordinates(
      //   Constant.kGoogleApiKey.toString(),
      //   PointLatLng(dLat, dLng),
      //   PointLatLng(destinationLatLong.latitude, destinationLatLong.longitude),
      //   wayPoints: wayPointList,
      //   optimizeWaypoints: true,
      //   travelMode: TravelMode.driving,
      // );
    } else {
      if(destinationLatLong != null) {
        routeInfoResult = await getRouteInfos(
            departureLatLong, destinationLatLong!, wayPointList);
      }
      // result = await polylinePoints.getRouteBetweenCoordinates(
      //   Constant.kGoogleApiKey.toString(),
      //   PointLatLng(departureLatLong.latitude, departureLatLong.longitude),
      //   PointLatLng(destinationLatLong.latitude, destinationLatLong.longitude),
      //   wayPoints: wayPointList,
      //   optimizeWaypoints: true,
      //   travelMode: TravelMode.driving,
      // );
    }

    if (routeInfoResult?.polylinePoints.isNotEmpty == true) {
      addPolyLine(routeInfoResult!.polylinePoints);
      // for (var point in routeInfoResult.polylinePoints) {
      //   polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      // }
    } {
      _animatedMapMove(departureLatLong, null);
    }
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    setState(() {
      if (polylineCoordinates.isNotEmpty) {
        _animatedMapMove(polylineCoordinates.first, null);
      } else {
        _animatedMapMove(departureLatLong, null);
      }
      polylinePoints = polylineCoordinates;
    });
    // _controller?.addLine(
    //   LineOptions(
    //     draggable: false,
    //     lineColor: ConstantColors.blueColorStr,
    //     lineWidth: 5.0,
    //     lineOpacity: 1,
    //     geometry: polylineCoordinates,
    //   ),
    // );
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

  _showDriverInfoScreen(BuildContext context, RideData rideData) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  child: Text('Driver Info'.tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, color: Colors.black)),
                ),
                const SizedBox(
                  height: 16,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: rideData.photoPath.toString(),
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Constant.loader(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                    "${rideData.prenomConducteur.toString()} ${rideData.nomConducteur.toString()}",
                    style: const TextStyle(
                        color: Colors.black87, fontWeight: FontWeight.w500)),
                RichText(
                    text: TextSpan(
                        text: "${"Số điện thoại".tr}: ",
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                        children: [
                      TextSpan(
                        text: rideData.phone.toString(),
                        style: TextStyle(
                            color: ConstantColors.titleTextColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      )
                    ])),
                RichText(
                    text: TextSpan(
                        text: "${"Number Plate".tr}: ",
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                        children: [
                      TextSpan(
                        text: rideData.numberplate.toString().toUpperCase(),
                        style: TextStyle(
                            color: ConstantColors.titleTextColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      )
                    ])),
              ],
            ),
          );
        });
  }
}
