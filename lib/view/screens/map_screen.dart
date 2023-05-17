import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

import '../../services/math_service.dart';
import '../widgets/location_pointer.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin{
  MapController mapController = MapController();
  final Location _location = Location();

  listenLocationChange() {
    _location.onLocationChanged.listen((location) {
      setState(() {
        LatLng position =
            LatLng(location.latitude ?? 0, location.longitude ?? 0);
        _previousLocation = _newLocation;
        _newLocation = correctLocation(position);
        _animationController.reset();
        _animationController.forward();
        debugPrint(
            "Assigned Location : ${_newLocation.latitude}, ${_newLocation.longitude}");
      });
    });
  }

  void initLocationChangeListener() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (serviceEnabled) {
      listenLocationChange();
    }
  }

  double calculateDistance(LatLng pointA, LatLng pointB) {
    const double earthRadius = 6371; // Radius of the Earth in kilometers
    final double lat1 = pointA.latitude * pi / 180.0;
    final double lon1 = pointA.longitude * pi / 180.0;
    final double lat2 = pointB.latitude * pi / 180.0;
    final double lon2 = pointB.longitude * pi / 180.0;

    final double dLat = lat2 - lat1;
    final double dLon = lon2 - lon1;

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final double distance = earthRadius * c;

    return distance; // Distance in kilometers
  }

  int biggestPosition(Map<int, double> values) {
    num smallest = values.values.first;
    int position = 0;
    values.forEach((key, value) {
      if (value < smallest) {
        smallest = value;
        position = key;
      }
    });
    return position;
  }

  LatLng correctLocation(LatLng position) {
    // debugPrint("Actual Location : ${position.latitude} ${position.longitude}");
    Map<int, double> distPosition = {};
    for (int i = 0; i < actualRoute.length; i++) {
      distPosition.putIfAbsent(
          i, () => calculateDistance(position, actualRoute[i]));
    }

    int nearestPosition = biggestPosition(distPosition);
    LatLng near1 = actualRoute[nearestPosition];
    distPosition.removeWhere((key, value) => key == nearestPosition);

    userTraveledRoute = actualRoute.sublist(0, nearestPosition);

    nearestPosition = biggestPosition(distPosition);
    LatLng near2 = actualRoute[nearestPosition];

    LatLng correctedPosition = nearestPointOnLine(near1, near2, position);
    userTraveledRoute.add(correctedPosition);
    // debugPrint("Corrected Location : ${correctedPosition.latitude} ${correctedPosition.longitude}");
    return correctedPosition;
  }

  LatLng calculateInterpolatedPosition() {
    final double latitude = _previousLocation.latitude +
        (_newLocation.latitude - _previousLocation.latitude) * _animationController.value;
    final double longitude = _previousLocation.longitude +
        (_newLocation.longitude - _previousLocation.longitude) * _animationController.value;
    return LatLng(latitude, longitude);
  }

  List<LatLng> userTraveledRoute = [];
  List<LatLng> actualRoute = <LatLng>[
    LatLng(8.684741650895619, 76.8243653881318),
    LatLng(8.6850392665589, 76.82436087211563),
    LatLng(8.685322001223184, 76.82435259275252),
    LatLng(8.685674675213987, 76.824354098092),
    LatLng(8.685843571713452, 76.82435861410934),
    LatLng(8.686159043384608, 76.82436237745702),
    LatLng(8.68636216533509, 76.82435560343248),
    LatLng(8.686598768786633, 76.8243533454251),
    LatLng(8.686910519645858, 76.824345818731),
    LatLng(8.687109921013892, 76.82435184008634),
    LatLng(8.687424982345087, 76.82432162353324),
    LatLng(8.687765028885567, 76.82430083641394),
    LatLng(8.68787970338031, 76.82427870818981),
    LatLng(8.688056023628548, 76.82420695910228),
    LatLng(8.688143520867524, 76.82415331491973),
    LatLng(8.688286035262502, 76.82401719281154),
    LatLng(8.688416618172687, 76.82388509401575),
    LatLng(8.688565098176237, 76.82374226638893),
    LatLng(8.688708938125314, 76.82359273323482),
    LatLng(8.6888202980482, 76.82348410376952),
    LatLng(8.688972755030782, 76.82337212154381),
    LatLng(8.689171611871634, 76.82321454176397),
    LatLng(8.689373782885502, 76.82309384235856),
    LatLng(8.689593188026238, 76.82296911963789),
    LatLng(8.689959083925968, 76.82277533003592),
    LatLng(8.690165231639833, 76.8226633478107),
    LatLng(8.690419104715078, 76.8225185085233),
    LatLng(8.69101898688477, 76.82218859681385),
    LatLng(8.691483646335039, 76.82199145445144),
    LatLng(8.691839597620042, 76.82186606118218),
    LatLng(8.69204707000207, 76.82176681944851),
    LatLng(8.692261170774938, 76.82162198016366),
    LatLng(8.692412300658562, 76.82149926909871),
    LatLng(8.692578013178167, 76.82133364269534),
    LatLng(8.69268738340188, 76.82122434267666),
    LatLng(8.692920043590787, 76.82095209845845),
    LatLng(8.69309238437663, 76.82072008737934),
    LatLng(8.693272679269517, 76.82048002966881),
    LatLng(8.693454962618524, 76.82021851429347),
    LatLng(8.693662434106487, 76.8199704099533),
    LatLng(8.693883162431746, 76.81978399642796),
    LatLng(8.694025674645017, 76.81969347187412),
    LatLng(8.69415758125033, 76.81960764118497),
    LatLng(8.694331247161497, 76.81948761233217),
    LatLng(8.69448303905623, 76.81937831231522),
    LatLng(8.694546009473566, 76.81934143194313),
  ];

  late AnimationController _animationController;
  LatLng _newLocation = LatLng(8.684741650895619, 76.8243653881318);
  LatLng _previousLocation = LatLng(8.684741650895619, 76.8243653881318);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
        setState(() {});
      });

    // Start the animation when the widget is first built
    _animationController.forward();
    initLocationChangeListener();
  }

  @override
  Widget build(BuildContext context) {
    final LatLng currentPosition = calculateInterpolatedPosition();
    return Scaffold(
        appBar: AppBar(title: const Text('Polylines')),
        body: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            children: [
              Flexible(
                child: FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    center:
                        _newLocation, // LatLng(39.671962666484205, -8.68518646365095),
                    zoom: 17,
                    onTap: (tapPosition, point) {
                      debugPrint('onTap');
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                            points: actualRoute,
                            strokeWidth: 10,
                            color: Colors.green),
                      ],
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                            points: userTraveledRoute,
                            strokeWidth: 10,
                            color: Colors.blue),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: currentPosition,
                          builder: (context) {
                            return const LocationPointer();
                          },
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
