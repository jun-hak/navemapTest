import 'dart:async';

import 'package:flutter/material.dart';

import 'package:naver_map_flutter/naver_map_flutter.dart';

class TypeMap extends StatefulWidget {
  @override
  _TypeMapState createState() => _TypeMapState();
}

class _TypeMapState extends State<TypeMap> {
  int _idx = 0;
  List<MapType> _types = [
    MapType.Basic,
    MapType.Navi,
    MapType.Hybrid,
    MapType.Satellite,
    MapType.Terrain,
  ];

  Completer<NaverMapController> completer = Completer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '타입별 지도 확인',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tabFab,
        backgroundColor: Colors.white,
        child: Icon(
          Icons.cached,
          color: Colors.black54,
        ),
      ),
      body: _body(),
    );
  }

  _body() {
    return Stack(
      children: <Widget>[
        NaverMap(
          mapType: _types[_idx],
          markers: [
            Marker(
              markerId: "1",
              position: LatLng(37.559746, 126.964482),
              onMarkerTab: (m, s) => print(m.markerId +
                  "\nwidth = ${s['width']} height = ${s['height']}"),
            ),
          ],
          onMapCreated: (cont) => completer.complete(cont),
        ),
      ],
    );
  }

  void _tabFab() {
    setState(() {
      _idx++;
      if (_idx > 4) _idx = 0;
    });
  }
}
