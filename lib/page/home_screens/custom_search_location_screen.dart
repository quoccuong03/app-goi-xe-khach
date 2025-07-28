import 'dart:convert';
import 'dart:developer';

import 'package:citgroupvn_car/constant/constant.dart';
import 'package:citgroupvn_car/model/location_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../service/api.dart';
import '../../themes/constant_colors.dart';
import '../choose_location_on_map/choose_location_from_map_screen.dart';

class CustomSearchLocationView extends ModalRoute<dynamic> {
  CustomSearchLocationView({
    required this.onStartAndIgnoreDestination,
    required this.onSelectedPlace,
    required this.textEditingController,
    required this.onSelectPlaceFromMap,
    this.isDeparture = false,
    this.isSelectShipmentDestination = false,
    this.isSelectLocationFromMap = false,
  });
  final Function() onStartAndIgnoreDestination;
  final Function(dynamic placeInfo) onSelectedPlace;
  final Function(LocationInfo placeInfo) onSelectPlaceFromMap;

  final bool isDeparture;
  final bool isSelectShipmentDestination;
  final bool isSelectLocationFromMap;
  final TextEditingController textEditingController;
  @override
  Duration get transitionDuration => const Duration(milliseconds: 100);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.5);

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      ) {
    // This makes sure that text and other content follows the material style
    return Material(
      type: MaterialType.transparency,
      // make sure that the overlay content is not cut off
      child: SafeArea(
        child: _buildOverlayContent(context),
      ),
    );
  }

  Widget _buildOverlayContent(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
            width: MediaQuery.of(context).size.width - 16,
            child: CustomCardView(
              textEditingController: textEditingController,
              isDeparture: isDeparture,
              isSelectShipmentDestination: isSelectShipmentDestination,
              isSelectLocationFromMap: isSelectLocationFromMap,
              onSelectedPlace: onSelectedPlace,
              onStartAndIgnoreDestination: onStartAndIgnoreDestination,
              onSelectPlaceFromMap: onSelectPlaceFromMap,
            )),
      ),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // You can add your own animations for the overlay content
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        child: child,
      ),
    );
  }
}

class CustomCardView extends StatefulWidget {
  const CustomCardView(
      {super.key,
      required this.onStartAndIgnoreDestination,
      required this.onSelectedPlace,
      required this.isDeparture,
      required this.isSelectShipmentDestination,
      required this.isSelectLocationFromMap,
      required this.onSelectPlaceFromMap,
      required this.textEditingController});

  final Function() onStartAndIgnoreDestination;
  final Function(dynamic placeInfo) onSelectedPlace;
  final Function(LocationInfo locationIno) onSelectPlaceFromMap;
  final bool isDeparture;
  final bool isSelectShipmentDestination;
  final bool isSelectLocationFromMap;
  final TextEditingController textEditingController;

  @override
  State<CustomCardView> createState() => _CustomCardViewState();
}

class _CustomCardViewState extends State<CustomCardView> with TickerProviderStateMixin {

  late TabController _tabController;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    // KHoi tao TabController
    _tabController = TabController(length: 2, vsync: this,);
    _tabController.index = _selectedTabIndex;
    _tabController.addListener(handleTabSelection);
  }

  @override
  void dispose() {
    // Cancel listening when widget was removed
    _tabController.dispose();
    super.dispose();
  }

  void handleTabSelection() {
    // Update status of widget when tab was selected
    setState(() {
      _selectedTabIndex = _tabController.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 60),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      color: Colors.white,
      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
          child: Text(
            'Enter Address'.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),),
        Visibility(
          visible: widget.isSelectShipmentDestination == false &&
              widget.isSelectLocationFromMap == false,
          child: TabBar(
            controller: _tabController,
            tabAlignment: TabAlignment.fill,
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            indicator: const UnderlineTabIndicator(borderSide: BorderSide(width: 1, color: Colors.green)),
            indicatorSize: TabBarIndicatorSize.tab,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            unselectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black),
            labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: ConstantColors.primary),
            labelPadding:
            const EdgeInsets.only(bottom: 7.5),
            isScrollable: false,
            onTap: (index) {
              setState(() {
                _selectedTabIndex = index;
              });
            },
            tabs: [
              Text(
                widget.isDeparture
                    ? 'Bạn có thể chọn điểm đón'
                    : widget.isSelectShipmentDestination || widget.isSelectLocationFromMap
                        ? "Chọn địa điểm"
                        : 'Bạn có thể chọn điểm đến',
                textAlign: TextAlign.center,
              ),
              const Text(
                'Bạn có thể chọn điểm đến sau',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Visibility(
          visible: _selectedTabIndex == 0,
          child: ListPlaceWidget(
            textEditingController: widget.textEditingController,
            onSelectedPlace: widget.onSelectedPlace,
            onSelectPlaceFromMap: widget.onSelectPlaceFromMap,
            isSelectShipmentDestination: widget.isSelectShipmentDestination,
            isSelectLocationFromMap: widget.isSelectLocationFromMap,
          ),
        ),
        Visibility(
          visible: _selectedTabIndex == 1,
          child: InkWell(
            onTap: () {
              widget.onStartAndIgnoreDestination();
              Navigator.pop(context);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: ConstantColors.primary),
              child: const Text(
                'Đồng ý và bắt đầu',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.white),
              ),
            ),
          ),
        )
      ]),
    );
  }
}

class ListPlaceWidget extends StatefulWidget {
  const ListPlaceWidget(
      {super.key,
      required this.onSelectedPlace,
      required this.onSelectPlaceFromMap,
      this.startPoint,
      required this.isSelectShipmentDestination,
      required this.isSelectLocationFromMap,
      required this.textEditingController});
  final Function(dynamic placeInfo) onSelectedPlace;
  final Function(LocationInfo locationInfo) onSelectPlaceFromMap;
  final LatLng? startPoint;
  final bool isSelectShipmentDestination;
  final bool isSelectLocationFromMap;
  final TextEditingController textEditingController;
  @override
  State<ListPlaceWidget> createState() => _ListPlaceWidgetState();
}

class _ListPlaceWidgetState extends State<ListPlaceWidget> {
  TextEditingController textFieldSearchController =
  TextEditingController();
  late List<dynamic> places;

  final textFieldSearchNode = FocusNode(debugLabel: 'textFieldSearchNode');

  Future<void> fetchData(String input) async {
    try {
      final url = Uri.parse(
          'https://rsapi.goong.io/Place/AutoComplete?api_key=${Constant.goongApiKey}&input=$input');

      var response = await client.get(url);
      setState(() {
        final jsonResponse = jsonDecode(response.body);
        places = jsonResponse['predictions'] as List<dynamic>? ?? [];
        log('places = $places');
      });
    } catch (e) {
      // ignore: avoid_print
      print('$e');
    }
  }
  @override
  void initState() {
    places = [];
    log('place = $places');
    textFieldSearchController = widget.textEditingController;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        /// search text field
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: TextField(
            controller: textFieldSearchController,
            focusNode: textFieldSearchNode,
            onChanged: (text) {
              if (text.isNotEmpty) {
                fetchData(text);
              }
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              counterText: "",
              contentPadding: const EdgeInsets.all(8),
              fillColor: Colors.white,
              filled: true,
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: ConstantColors.textFieldBoarderColor,
                    width: 0.7),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: ConstantColors.textFieldBoarderColor,
                    width: 0.7),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: ConstantColors.textFieldBoarderColor,
                    width: 0.7),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                    color: ConstantColors.textFieldBoarderColor,
                    width: 0.7),
              ),
              hintText: "Bạn muốn đi đi đâu ?".tr,
              hintStyle: TextStyle(
                color: ConstantColors.hintTextColor,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        //list suggest
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: places.length,
            itemBuilder: (BuildContext context, int index) {
              final coordinate = places[index];
              return Container(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: ConstantColors.dividerColor)
                  )
                ),
                child: InkWell(
                  onTap: () {
                    widget.onSelectedPlace(places[index]);
                    Navigator.pop(context);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Column(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: ConstantColors.primary,
                            size: 20,
                          ),
                          // Visibility(
                          //   visible: widget.startPoint != null,
                          //   child: FutureBuilder<String>(
                          //     future: getEstimateDistance(coordinate),
                          //     builder: (context, snapshot) {
                          //       if (snapshot.connectionState == ConnectionState.waiting || snapshot.hasError) {
                          //         // Hiển thị một thông báo lỗi nếu có lỗi xảy ra
                          //         return const Text(
                          //           '0Km',
                          //           style: TextStyle(
                          //               color: Colors.black54,
                          //               fontSize: 11,
                          //               fontWeight: FontWeight.normal),
                          //         );
                          //       } else {
                          //         return Text(
                          //           snapshot.data.toString(),
                          //           style: const TextStyle(
                          //               color: Colors.black54,
                          //               fontSize: 11,
                          //               fontWeight: FontWeight.normal),
                          //         );
                          //       }
                          //     }
                          //   ),
                          // ),
                        ],
                      ),
                      const SizedBox(width: 8,),
                      Column(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width - 90,
                            child: Text(
                              coordinate['structured_formatting']['main_text'],
                              overflow: TextOverflow.ellipsis,
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
                              coordinate['structured_formatting']['secondary_text'],
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
              );
            },
          ),
        ),
        Visibility(
          visible: widget.isSelectLocationFromMap == false,
          child: InkWell(
            onTap: () {
              Get.to(() => const ChooseLocationFromMapScreen())?.then((value) {
                if(value != null) {
                  widget.onSelectPlaceFromMap(value);
                }
                Get.back();
              });
            },
            child: const Padding(
              padding: EdgeInsets.only(top: 12, bottom: 12),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.map),
                    Text(
                      'Chọn từ bản đồ',
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(width: 1, color: Colors.green)
            ),
            child: Text(
              'Hủy',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: ConstantColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Future<String> getEstimateDistance(dynamic coordinate) async {
    var placeId = coordinate['place_id'];
    if (placeId == null ||
        placeId.toString().isEmpty ||
        widget.startPoint == null) return "0Km";
    try{
      var url = Uri.parse(
          'https://rsapi.goong.io/Place/Detail?place_id=${placeId.toString()}&api_key=${Constant.goongApiKey}');
      var response = await client.get(url);
      final jsonResponse = jsonDecode(response.body);
      var desLat = jsonResponse['result']['geometry']['location']['lat'];
      var desLng = jsonResponse['result']['geometry']['location']['lng'];
      if(desLat != null && desLng != null) {
        var distance = calculateDistance(widget.startPoint!, LatLng(desLat, desLng));
        return '${(distance/1000).toStringAsFixed(2)}Km';
      }
    } catch(e) {
      log('e = $e');
    }
    return "0Km";
  }
}

