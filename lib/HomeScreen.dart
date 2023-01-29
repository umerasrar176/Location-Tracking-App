import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlng/latlng.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class Point {
  double x;
  double y;
  Point(this.x, this.y);
}

List<Point> points = [
  Point(0, 0),
  Point(0, 4),
  Point(4, 4),
  Point(4, 0),
];

//0.0 0.0,0.0 4.0,4.0 4.0,4.0 0.0

class Polygon {
  Polygon(this.points);
  List<Point> points;

  bool isPointInside(Point point, List<Point> points ) {
    //int i=0, j=0;
    bool c = false;
    int nvert = points.length;
    print("in function my point ${point.x} ${point.y}");
    print("in function overall point ${points[0].x} ${points[0].y} ${points[1].x} ${points[1].y} ${points[2].x} ${points[2].y} ${points[3].x} ${points[3].y}");
    for (int i = 0, j = nvert - 1; i < nvert; j = i++) {
      if (((points[i].y > point.y) != (points[j].y > point.y)) &&
          (point.x <
              (points[j].x - points[i].x) *
                      (point.y - points[i].y) /
                      (points[j].y - points[i].y) +
                  points[i].x)) {
        c = !c;
      }
    }
    return c;
  }
}

class _HomeScreenState extends State<HomeScreen> {
  List<LatLng> _polygonPoints = [];
  Point _userCoordinate = Point(0, 0);
  bool _isWithinPolygon = false;
  Polygon polygon = Polygon(points);
  List<String> attendence = [];
  String _locationMessage = "Loading location...";
  late Timer _timer;
  /*Point latitude = Point(0, 0);
  Point longitude = Point(0, 0);*/

  @override
  void initState() {
    super.initState();
    /*_timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      // Do your task here after every 1 minute
      _getCurrentLocation();
      _isWithinPolygon = polygon.isPointInside(_userCoordinate,points);
      setState(() {});
    });*/
    _getCurrentLocation();
    print("position is $_locationMessage");
  }

  /*@override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }*/

  void _getCurrentLocation() async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print("Latitude: ${position.latitude} \nLongitude: ${position.longitude}");
    setState(() {
      _locationMessage = "Latitude: ${position.latitude} \nLongitude: ${position.longitude}";
      //_userCoordinate = Point(position.latitude, position.longitude);
      _userCoordinate = Point(24.886, -70.268);
    });
  }


  @override
  Widget build(BuildContext context) {
    print("Build");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Checker'),
      ),
      body: Column(
        children: <Widget>[
          // Input field for polygon coordinates
          TextField(
      decoration: const InputDecoration(
          hintText: 'Enter GEO Location coordinates (lat long,lat long, ...)',
      ),
      onChanged: (value) {
        // Parse the input string and add the coordinates to the polygon points list
        points = value.split(',').map((coordinate) {
          List<double> coords = coordinate.split(' ').map(double.parse).toList();
          return Point(coords[0], coords[1]);
        }).toList();
        setState(() {
          print(points[1].y);
          points = points;
        });
      },
    ),
          // Input field for user's coordinate
          /*TextField(
            decoration: const InputDecoration(
                hintText: 'Enter your coordinate (lat long)'),
            onChanged: (value) {
              List<double> coords = value.split(' ').map(double.parse).toList();
              setState(() {
                //print("in set state ${coords[0]} ,${coords[1]}");
               // _userCoordinate = Point(coords[0], coords[1]);
              });
            },
          ),*/
          // Check if user's coordinate is within the polygon
          ElevatedButton(
            child: const Text('Set Location'),
            onPressed: () {
              _isWithinPolygon = polygon.isPointInside(_userCoordinate,points);
              if (_isWithinPolygon) {
                attendence.add("present ${TimeOfDay.now()}");
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                        'Attendance is Marked as You are within the Location!')));
              } else {
                attendence.add("OutOfLocation ${TimeOfDay.now()}");
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('You are not within the location!')));
              }
              setState(() {});
            },
          ),
          // Display result
          //Text("Office Location is ${points[0].x} ${points[0].y} ${points[1].x} ${points[1].y} ${points[2].x} ${points[2].y} ${points[3].x} ${points[3].y}"),
          Text(_isWithinPolygon ? 'Within Location' : 'Not within Location'),
          Text(_locationMessage),
          SizedBox(
            height: 100,
            child: ListView.builder(
                //padding: const EdgeInsets.all(8),
                itemCount: attendence.length,
                itemBuilder: (BuildContext context, int index) {
                  return Text(attendence[index]);
                }),
          )
        ],
      ),
    );
  }
}
