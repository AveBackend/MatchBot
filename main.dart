import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mapbox_gl/controller.dart';
import 'package:mapbox_gl/overlay.dart';

class CustomScreen extends StatefulWidget {
  @override
  _CustomScreenState createState() => _CustomScreenState();
}

class _CustomScreenState extends State<CustomScreen> {
  final MapboxOverlayController mapController = MapboxOverlayController();
  final random = Random();

  final List<Map<String, dynamic>> items = [
    {
      'name': 'User 1',
      'title': 'Title 1',
      'locations': [
        [12.976321, 77.591332],
        [12.966321, 77.591332],
        [12.965321, 77.592332],
        [12.985321, 77.592432],
        [12.976321, 77.581332],
        [12.966321, 77.571332],
        [12.965321, 77.598332],
        [12.985321, 77.593432]
      ],
      'image': 'https://example.com/image1.jpg',
    },
    {
      'name': 'User 2',
      'title': 'Title 2',
      'locations': [
        [12.966321, 77.571332],
        [12.965321, 77.598332]
      ],
      'image': 'https://example.com/image2.jpg',
    },
    {
      'name': 'User 3',
      'title': 'Title 3',
      'locations': [
        [12.976321, 77.591332],
        [12.966321, 77.591332],
        [12.965321, 77.592332],
      ],
      'image': 'https://example.com/image3.jpg',
    },
    {
      'name': 'User 4',
      'title': 'Title 4',
      'locations': [
        [12.985321, 77.593432]
      ],
      'image': 'https://example.com/image4.jpg',
    },
  ];

  final markersOnMap = <Widget>[];

  _initItems() {
    int maxLocations = 0;
    for (int i = 0; i < items.length; ++i) {
      maxLocations = max(maxLocations, (items[i]['locations'] as List).length);
    }
    for (int i = 0; i < maxLocations; ++i) {
      markersOnMap.add(AnimatedPositioned(
          child: AnimatedOpacity(
              child: Icon(Icons.location_on),
              opacity: .0,
              duration: Duration(milliseconds: 700)),
          duration: Duration(milliseconds: 100)));
    }
  }

  @override
  void initState() {
    super.initState();
    _initItems();
    Future.delayed(Duration(seconds: 3), () => _getMarkers(0));
  }

  Widget _buildProfileList() {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: PageView.builder(
        itemBuilder: (_, index) {
          return ListTile(
            title: Text(items[index]['name']),
            subtitle: Text(items[index]['title']),
            leading: Image.network(items[index]['image']),
          );
        },
        itemCount: items.length,
        onPageChanged: _getMarkers,
      ),
    );
  }

  Widget _buildImageOverlayGradient() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: const LinearGradient(
          begin: FractionalOffset.topCenter,
          end: FractionalOffset.bottomCenter,
          colors: const [
            Colors.white30,
            Colors.transparent,
          ],
          tileMode: TileMode.clamp,
        ),
      ),
      child: _buildProfileList(),
    );
  }

  Widget _buildMap() {
    return MapboxOverlay(
      controller: mapController,
      options: MapboxMapOptions(
        style: Style.light,
        camera: CameraPosition(
          target: LatLng(lat: 12.986321, lng: 77.591332),
          zoom: 12.0,
          bearing: 0.0,
          tilt: 0.0,
        ),
      ),
    );
  }

  Future<Null> _getMarkers(int page) async {
    int locationLength = (items[page]['locations'] as List).length;
    for (int i = 0; i < markersOnMap.length; ++i) {
      int index = i;
      if (i >= locationLength) index = random.nextInt(locationLength);
      List<double> c = items[page]['locations'][index];
      final offset =
          await mapController.getOffsetForLatLng(LatLng(lat: c[0], lng: c[1])) /
              window.devicePixelRatio;
      markersOnMap[i] = AnimatedPositioned(
        child: AnimatedOpacity(
          opacity: i < locationLength ? 1.0 : 0.0,
          duration: Duration(milliseconds: 600),
          child: Icon(Icons.location_on),
        ),
        left: offset.dx,
        top: offset.dy,
        duration: Duration(milliseconds: 700),
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          _buildMap(),
          _buildImageOverlayGradient(),
          Stack(
            children: markersOnMap,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.near_me),
        elevation: 20.0,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.score), label: "Stats"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Date"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Setting")
        ],
        currentIndex: 1,
      ),
    );
  }
}
