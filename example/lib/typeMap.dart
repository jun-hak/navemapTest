import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:naver_map_flutter/naver_map_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class TypeMap extends StatefulWidget {
  @override
  _TypeMapState createState() => _TypeMapState();
}

class _TypeMapState extends State<TypeMap> {
  bool isSearch = false;
  String title = "주소 검색";
  String searchAddress = "";
  final searchController = TextEditingController();
  int _idx = 0;
  List<MapType> _types = [
    MapType.Basic,
    MapType.Navi,
    MapType.Hybrid,
    MapType.Satellite,
    MapType.Terrain,
  ];
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Completer<NaverMapController> completer = Completer();

  @override
  Widget build(BuildContext context) {
    return Kopo();
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //       appBar: AppBar(
  //         title: isSearch
  //             ? TextField(
  //                 textInputAction: TextInputAction.done,
  //                 controller: searchController,
  //                 autofocus: true,
  //                 style: Theme.of(context)
  //                     .textTheme
  //                     .display2
  //                     .apply(fontSizeDelta: 2),
  //                 onSubmitted: (v) async {
  //                   setState(() {
  //                     searchAddress = v;
  //                     isSearch = !isSearch;
  //                   });

  //                   await _searchNaverGeo();
  //                 },
  //                 decoration: InputDecoration(
  //                   border: InputBorder.none,
  //                   hintText: title,
  //                   hintStyle: TextStyle(
  //                       fontSize: 16,
  //                       color: Colors.black45,
  //                       fontWeight: FontWeight.w300),
  //                 ),
  //               )
  //             : InkWell(
  //                 onTap: () {
  //                   setState(() {
  //                     isSearch = !isSearch;
  //                   });
  //                 },
  //                 child: Row(
  //                   children: <Widget>[Text(searchAddress)],
  //                 ),
  //               ),
  //         actions: <Widget>[
  //           InkWell(
  //               onTap: () {
  //                 Navigator.of(context).pop();
  //               },
  //               child: Center(
  //                   child: Container(
  //                       padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
  //                       child: Text('확인'))))
  //         ],
  //       ),
  //       floatingActionButton: FloatingActionButton(
  //         onPressed: _tabFab,
  //         backgroundColor: Colors.white,
  //         child: Icon(
  //           Icons.cached,
  //           color: Colors.black54,
  //         ),
  //       ),
  //       body: Kopo(
  //         title: title,
  //       ) //isSearch ? Kopo() : _body(),
  //       );
  // }

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

  Future<void> _searchNaverGeo() async {
    final String queryString = "?query=$searchAddress";
    // final url = "https://naveropenapi.apigw.ntruss.com/map-place/v1/search" +
    //     queryString;
    final url =
        "https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js" +
            queryString;
    // final url =
    //     "https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query=분당구 불정로 6";

    http.Response res = await http.get(url, headers: {
      "X-NCP-APIGW-API-KEY-ID": "le8nlsvow9",
      "X-NCP-APIGW-API-KEY": "gbMQeQulUGUk1lyW1pIBAKex57mAkxPkAChySwh7",
      "Content-Type": "application/json"
    });

    print('response - ${queryString.length}');
    final response = jsonDecode(res.body);
    print('response - $response ${queryString.length}');
  }
}

class Kopo extends StatefulWidget {
  Kopo({
    Key key,
    this.title = '주소검색',
    this.colour = Colors.white,
  }) : super(key: key);

  @override
  KopoState createState() => KopoState();

  final String title;
  final Color colour;
}

class KopoState extends State<Kopo> {
  WebViewController _controller;
  WebViewController get controller => _controller;
  bool show = false;
  String lat, lan;
  final String url =
      'https://jun-hak.github.io/kakaoPostalAddress/assets/kakao.html';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
            height: 56.0,
            color: Colors.amber,
            child: (show)
                ? Flex(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    direction: Axis.horizontal,
                    children: <Widget>[
                      Flexible(
                        child: FlatButton(
                          child: Text('취소'),
                          onPressed: () {
                            setState(() {
                              show = false;
                              _controller.loadUrl(url);
                            });
                          },
                        ),
                      ),
                      Flexible(
                        child: FlatButton(
                          child: Text('확인'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      )
                    ],
                  )
                : Container(
                    child: Text('경기장 입력'),
                    color: Colors.black,
                  )),
        Expanded(
          child: WebView(
              initialUrl: url,
              javascriptMode: JavascriptMode.unrestricted,
              javascriptChannels: Set.from([
                JavascriptChannel(
                    name: 'onComplete',
                    onMessageReceived: (JavascriptMessage message) {
                      var msg = jsonDecode(message.message);

                      String fixedUrl =
                          url + "?lan=${msg["lan"]}&lat=${msg["lat"]}";

                      setState(() {
                        _controller.loadUrl(fixedUrl);
                        show = true;
                      });
                    }),
              ]),
              onWebViewCreated: (WebViewController webViewController) async {
                _controller = webViewController;
              }),
        ),
      ],
    );
  }
}

// class KopoState extends State<Kopo> {
//   WebViewController _controller;
//   WebViewController get controller => _controller;
//   String lat, lan;
//   final String url =
//       'https://jun-hak.github.io/kakaoPostalAddress/assets/kakao.html';

//   @override
//   Widget build(BuildContext context) {
//     return WebView(
//         initialUrl: url,
//         javascriptMode: JavascriptMode.unrestricted,
//         javascriptChannels: Set.from([
//           JavascriptChannel(
//               name: 'onComplete',
//               onMessageReceived: (JavascriptMessage message) {
//                 var msg = jsonDecode(message.message);

//                 String fixedUrl = url + "?lan=${msg["lan"]}&lat=${msg["lat"]}";

//                 setState(() {
//                   _controller.loadUrl(fixedUrl);
//                 });
//               }),
//         ]),
//         onWebViewCreated: (WebViewController webViewController) async {
//           _controller = webViewController;
//         });
//   }
// }
