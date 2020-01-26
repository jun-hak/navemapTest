import 'package:flutter/material.dart';
import 'package:naver_map_flutter/naver_map_flutter.dart';
import 'package:naver_map_flutter_example/typeMap.dart';

void main() => runApp(MaterialApp(
      home: TestMain(),
    ));

class TestMain extends StatefulWidget {
  @override
  _TestMainState createState() => _TestMainState();
}

class _TestMainState extends State<TestMain> {
  OverlayImage _icon;
  List<String> menus = [
    '타입별 지도 확인',
  ];

  @override
  Widget build(BuildContext context) {
    if (_icon == null) {
      ImageConfiguration config = createLocalImageConfiguration(context);
      OverlayImage.fromAssetImage(config, 'assets/icon.png').then((icon) {
        setState(() {
          _icon = icon;
        });
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '네이버 맵',
          style: TextStyle(color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: _body(),
    );
  }

  _body() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: menus.map((menu) {
          return GestureDetector(
            onTap: () => _onMenuTab(menu),
            child: Container(
              padding: EdgeInsets.all(8),
              child: Center(
                child: Text(menu),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  _onMenuTab(String menu) {
    switch (menu) {
      case '타입별 지도 확인':
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => TypeMap()));
        break;
    }
  }
}
