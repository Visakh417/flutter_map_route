import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

import '../../services/math_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapController mapController = MapController();
  final Location _location = Location();

  listenLocationChange(){
    _location.onLocationChanged.listen((location) {
      setState(() {
        LatLng position = LatLng(location.latitude ?? 0, location.longitude ?? 0);
        currentPoint = correctLocation(position);
        debugPrint("Location : ${location.latitude}, ${location.longitude}");
      });
    });
  }

  void initLocationChangeListener()async{
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if(serviceEnabled){
      listenLocationChange();
    }
  }

  num calculateDistance(LatLng pointA, LatLng pointB){
    return pow(pointA.latitude - pointB.latitude, 2) + pow(pointA.longitude - pointB.longitude, 2); 
  }

  int biggestPosition(Map<int, num> values){
    num biggest = values.values.first;
    int position = 0;
    values.forEach((key, value) {
      if(value > biggest){
        biggest = value;
        position = key;
      }
    });
    return position;
  }


  
  LatLng correctLocation(LatLng position){
    Map<int, num> distPosition = {};
    for(int i =0; i< actualRoute.length; i++){
      distPosition.putIfAbsent(i, () => calculateDistance(position, actualRoute[i]));
    }

    int nearestPosition = biggestPosition(distPosition);
    LatLng near1 = actualRoute[nearestPosition];
    distPosition.removeWhere((key, value) => key == nearestPosition);

    userTraveledRoute = actualRoute.sublist(0, nearestPosition);

    nearestPosition = biggestPosition(distPosition);
    LatLng near2 = actualRoute[nearestPosition];

    LatLng correctedPosition = nearestPointOnLine(near1, near2, position);
    userTraveledRoute.add(correctedPosition);

    return correctedPosition;
  }

  List<LatLng> userTraveledRoute = [];
  final actualRoute = <LatLng>[
    LatLng(39.47962429748364, -8.536880728912754),
    LatLng(39.47996256045599, -8.537809819456992),
    LatLng(39.48040906506061, -8.538826560052572),
    LatLng(39.480402299860714, -8.539694295560867),
    LatLng(39.480530838546215, -8.54093892628994),
    LatLng(39.48000315190212, -8.541719011746892),
    LatLng(39.48098410464672, -8.542078376957399),
    LatLng(39.481667380797624, -8.542297502085757),
    LatLng(39.48274978474517, -8.54326165272046),
    LatLng(39.48319627146607, -8.544313453366675),
    LatLng(39.483744228512606, -8.5445501085053),
    LatLng(39.48430571089513, -8.544479988479273),
  ];

  LatLng currentPoint = LatLng(39.47944919916419, -8.540582686060697);

  
  @override
  void initState() {
    super.initState();
    initLocationChangeListener();
  }

  @override
  Widget build(BuildContext context) {
   

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
                          center: currentPoint,// LatLng(39.671962666484205, -8.68518646365095),
                          zoom: 17,
                          onTap: (tapPosition, point) {
                            debugPrint('onTap');
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName:
                                'dev.fleaflet.flutter_map.example',
                          ),
                          
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                  points: actualRoute,
                                  strokeWidth: 20,
                                  color: Colors.green),
                            ],
                          ),
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: userTraveledRoute,
                                strokeWidth: 20,
                                color: Colors.red
                                // gradientColors: [
                                //   const Color(0xffE40203),
                                //   const Color(0xffFEED00),
                                //   const Color(0xff007E2D),
                                // ],
                              ),
                            ],
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: currentPoint,
                                builder: (context) {
                                  return const Icon(
                                    Icons.account_circle,
                                    color: Colors.blue,
                                    size: 45,
                                  );
                                },
                              )
                            ],
                          ),
                          // PolylineLayer(
                          //   polylines: snapshot.data!,
                          //   polylineCulling: true,
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
        ));
  }
}
