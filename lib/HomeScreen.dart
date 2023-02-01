import 'dart:async';
import 'dart:ffi';

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
  /*Point(0, 0),
  Point(0, 4),
  Point(4, 4),
  Point(4, 0),*/
];

//Polygon Coordinates for testing
//0.0 0.0,0.0 4.0,4.0 4.0,4.0 0.0
//25.774 -80.19,18.466 -66.118,32.321 -64.757,25.774 -80.19

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
  bool present = false;
  bool absent = false;
  String _locationMessage = "Loading location...";
  double latitude = 0;
  double longitude = 0;
  late Timer _timer;
  /*Point latitude = Point(0, 0);
  Point longitude = Point(0, 0);*/

  @override
  void initState() {
    super.initState();
    /*_timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      // Do your task here after every 1 minute
      _getCurrentLocation();
      //_isWithinPolygon = polygon.isPointInside(_userCoordinate,points);
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
      latitude = position.latitude;
      longitude = position.longitude;
      _locationMessage = "Latitude: ${position.latitude} \nLongitude: ${position.longitude}";
      _userCoordinate = Point(position.latitude, position.longitude);
      //Only for testing
      //_userCoordinate = Point(33.657639, 73.157733);
      //_userCoordinate = Point(73.157779, 33.657624); //in location
      //_userCoordinate = Point(73.157698, 33.657656); //out of location
      //should be inside coordinate and attendence should be added
    });
  }


  @override
  Widget build(BuildContext context) {
    print("Build");
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPS Based Attendence System',
          style: TextStyle(fontWeight: FontWeight.w800,
              fontSize: 20,
              color: Colors.black,
          ),)
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const Text("Coordinates of the Premises",
              style: TextStyle(decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w500,
                  fontSize: 20),),
            // Input field for polygon coordinates
            Center(
              child: TextField(
                maxLines: 4,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter GEO Location coordinates (Lat Long,Lat Long, ...)',
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
            ),
            // Input field for user's coordinate
            /*TextField(
              decoration: const InputDecoration(
                  hintText: 'Enter your custom coordinate (Late Long)'),
              onChanged: (value) {
                List<double> coords = value.split(' ').map(double.parse).toList();
                setState(() {
                  //print("in set state ${coords[0]} ,${coords[1]}");
                 //_userCoordinate = Point(coords[0], coords[1]);
                });
              },
            ),*/
            // Check if user's coordinate is within the polygon
            Padding(
              padding: const EdgeInsets.only(left: 55.0),
              child: Row(
                children: [
                  ElevatedButton(
                    child: const Text('Mark Attendance', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),),
                    onPressed: () {
                      /*_getCurrentLocation();
                      _userCoordinate = Point(33.657639, 73.157743); //in location
                      setState(() {});*/
                      print("in button${_userCoordinate.x} ${_userCoordinate.y}");

                      _isWithinPolygon = polygon.isPointInside(_userCoordinate,points);
                      if (_isWithinPolygon) {
                        present = true;
                        absent = false;
                        //attendence.add("InsideLocation ${TimeOfDay.now()}(${_userCoordinate.x}, ${_userCoordinate.y})");
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text(
                                'Attendance is Marked as You are within the Location!')));
                      } else {
                        present = false;
                        absent = true;
                        //attendence.add("OutOfLocation ${TimeOfDay.now()}(${_userCoordinate.x}, ${_userCoordinate.y})");
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('You are not within the location!')));
                      }
                      setState(() {});
                    },
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    child: const Text('Apply Coordinates', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      _getCurrentLocation();
                      /*latitude= 33.657639;
                      longitude= 73.157743; *///in location
                      setState(() {});
                    }
                  ),
                ],
              ),
            ),

            // Display result
            //Text("Office Location is ${points[0].x} ${points[0].y} ${points[1].x} ${points[1].y} ${points[2].x} ${points[2].y} ${points[3].x} ${points[3].y}"),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(_isWithinPolygon ? 'Within Location' : 'Not within Location'),
            ),

            //Text(_locationMessage),
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Text("Latitude: $latitude \nLongitude: $longitude"),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(padding:  EdgeInsets.only(top: 65.0, left: 15.0),
                  child: present ? RichText(
                    text: TextSpan(
                      text: 'Inside Location ',
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900 ,fontSize: 20),
                      children: <TextSpan>[
                        TextSpan(text: '(${_userCoordinate.x}, ${_userCoordinate.y})', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w400 ,fontSize: 17)),
                      ],
                    ),
                  )//,Text("Inside Location (${_userCoordinate.x}, ${_userCoordinate.y})", style: const TextStyle(fontWeight: FontWeight.w900 ,fontSize: 15),)
                      : RichText(
                    text: TextSpan(
                      text: 'Out of Location ',
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900 ,fontSize: 20),
                      children: <TextSpan>[
                        TextSpan(text: ' (${_userCoordinate.x}, ${_userCoordinate.y})', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w400 ,fontSize: 17)),
                      ],
                    ),
                  ) //Text("Out of Location (${_userCoordinate.x}, ${_userCoordinate.y})", style: const TextStyle(fontWeight: FontWeight.w900 ,fontSize: 15),),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0 , horizontal: 15.0),
                  child: SizedBox(
                    height: 25,
                    child: present ? const Text("Employee Attendance Time stamp", style: TextStyle(fontWeight: FontWeight.w900 ,fontSize: 20),)
                        : const Text("Attendance Failed", style: TextStyle(fontWeight: FontWeight.w900 ,fontSize: 20 ),),
                  ),
                ),
              ],
            ),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Text("Date:    ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} ", style: const TextStyle(fontWeight: FontWeight.w900 ,fontSize: 18 ),),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Text("Time:    ${TimeOfDay.now().hour}:${DateTime.now().minute} ${DateTime.now().timeZoneName}", style: const TextStyle(fontWeight: FontWeight.w900 ,fontSize: 18 ),),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
