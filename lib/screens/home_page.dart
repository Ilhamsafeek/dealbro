import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:seeds/screens/create_product.dart';
import 'package:seeds/screens/product_detail.dart';
import 'package:seeds/screens/profile.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:device_info/device_info.dart';
import 'package:seeds/screens/users.dart';
import 'package:seeds/services/services.dart';
import 'package:seeds/utils/dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'dart:async';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ApiListener mApiListener;
  StreamController _messageController;
  Timer timer;

  Future<String> _getId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    // if (Theme.of(context).platform == TargetPlatform.android) {
    //   IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
    //   return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    // } else {
    //   AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
    //   return androidDeviceInfo.androidId; // unique ID on Android
    // }
    AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
    return androidDeviceInfo.androidId; // unique ID on Android
  }

  @override
  void initState() {
    super.initState();
    _messageController = new StreamController();
    timer = Timer.periodic(Duration(seconds: 1), (_) => loadPosts());
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  loadPosts() async {
    WebServices(this.mApiListener).getPostData().then((res) async {
      _messageController.add(res);
      // print("====>>> $res");
      return res;
    });
  }

  @override
  Widget build(BuildContext context) {
    _getId().then((id) async {
      String deviceId = id;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("device_id", deviceId);
    });
    Widget _image_carousel = new Container(
        child: CarouselSlider(
      items: [
        'https://www.subway.com/~/media/Base_English/Promotions/Marquees/Mobile/MenuNutrition/Evergreen_Marquees_veggies_mobile_585x305.png',
        'https://mir-s3-cdn-cf.behance.net/project_modules/max_1200/9ca3e369796585.5b8e2e319ed13.png',
        'https://www.vanillaluxury.sg/sites/default/files/field/image/banner_136.png',
        'https://safimex.com/wp-content/uploads/2018/07/banner-01.jpg'
      ].map((i) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
                width: MediaQuery.of(context).size.width,
                child: GestureDetector(
                    child: Image.network(i, fit: BoxFit.fill), onTap: () {}));
          },
        );
      }).toList(),
      options: CarouselOptions(
        autoPlay: true,
        // enlargeCenterPage: true,
        viewportFraction: 0.9,
        aspectRatio: 2.0,
        initialPage: 0,
      ),
    ));

    return Scaffold(
      appBar: AppBar(
          actions: <Widget>[
            IconButton(
                onPressed: () async {
                  Navigator.of(context).push(
                      CupertinoPageRoute<Null>(builder: (BuildContext context) {
                    return new Users();
                  }));
                },
                icon: Icon(Icons.supervised_user_circle, color: Colors.white)),
            IconButton(
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  var deviceId = prefs.getString("device_id");
                  var isRegistered = false;
                  isRegistered = prefs.getBool("is_registered");

                  if (isRegistered == false || isRegistered == null) {
                    showWaitingProgress(context, 'Configuring Account..');
                    await WebServices(this.mApiListener)
                        .createAccount(deviceId);
                    await prefs.setBool("is_registered", true);
                    Navigator.pop(context);
                  }

                  Navigator.of(context).push(
                      CupertinoPageRoute<Null>(builder: (BuildContext context) {
                    return new Profile(deviceId);
                  }));
                },
                icon: Icon(Icons.person, color: Colors.white)),
          ],
          title: Row(
            children: <Widget>[
              Image.asset(
                'assets/db-logo.png',
                height: 25,
                color: Colors.white60,
              ),
              Text(
                ' DealBro',
                style:
                    TextStyle(color: Colors.white60, fontWeight: FontWeight.bold),
              )
            ],
          )),
      body: StreamBuilder(
        stream: _messageController.stream,
        builder: (context, snapshot) {
          List<Widget> children;
          if (snapshot.hasError) {
            children = <Widget>[
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Error: ${snapshot.error}'),
              )
            ];
          } else {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                children = <Widget>[
                  Icon(
                    Icons.info,
                    color: Colors.blue,
                    size: 60,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text('No posts to display'),
                  )
                ];
                break;
              case ConnectionState.waiting:
                children = <Widget>[
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          child: SpinKitPulse(
                            color: Colors.grey,
                            size: 120.0,
                          ),
                          width: 50,
                          height: 50,
                        ),
                      ],
                    ),
                  )
                ];
                break;
              case ConnectionState.active:
                return _buildPostSection(snapshot.data);
                break;
              case ConnectionState.done:
                return _buildPostSection(snapshot.data);
                break;
            }
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: children,
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: () {
          Navigator.of(context)
              .push(CupertinoPageRoute<Null>(builder: (BuildContext context) {
            return new CreateProduct();
          }));
        },
        tooltip: 'Increment',
        child: Icon(
          Icons.add,
          color: Colors.black,
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  dynamic _buildPostSection(data) {
    return StaggeredGridView.countBuilder(
      crossAxisCount: 4,
      itemCount: data.length,
      itemBuilder: (BuildContext context, int index) =>
          _buildProduct(data[index]),
      staggeredTileBuilder: (int index) => new StaggeredTile.fit(2),
      mainAxisSpacing: 4.0,
      crossAxisSpacing: 4.0,
    );
  }

  Widget _buildProduct(data) {
    return new Card(
        child: GestureDetector(
      child: Column(
        children: <Widget>[
          Stack(children: <Widget>[
            Container(
              // color: Colors.green,
              child: CachedNetworkImage(
                imageUrl: data['image_url'],
                placeholder: (context, url) =>
                    Image.asset('assets/placeholder.png'),
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 5,
              left: 5,
              child: CircleAvatar(
                radius: 15,
                backgroundImage: CachedNetworkImageProvider(data['photo_url']),
                backgroundColor: Colors.indigoAccent,
                foregroundColor: Colors.white,
              ),
            ),
            Positioned(
              top: 5,
              left: 40,
              child: Text(
                data['username'],
                style: TextStyle(
                  fontFamily: "Exo2",
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.0,
                  shadows: <Shadow>[
                    Shadow(
                      offset: Offset(0.5, 0.5),
                      blurRadius: 3.0,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 20,
              left: 40,
              child: Text(
                data['address'],
                style: TextStyle(
                  fontFamily: "Exo2",
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10.0,
                  shadows: <Shadow>[
                    Shadow(
                      offset: Offset(0.5, 0.5),
                      blurRadius: 3.0,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
                bottom: 5,
                left: 5,
                child: Text(
                  data['date_time'],
                  style: TextStyle(
                    fontFamily: "Exo2",
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.0,
                    shadows: <Shadow>[
                      Shadow(
                        offset: Offset(0.5, 0.5),
                        blurRadius: 3.0,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ))
          ]),
          Container(
            color: Colors.blue,
            height: 20,
            width: double.infinity,
            // height: double.infinity,
            child: Center(
              child: Text("Rs.${data['price']}/${data['unit']}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  )),
            ),
          )
        ],
      ),
      onTap: () {
        Navigator.of(context)
            .push(CupertinoPageRoute<Null>(builder: (BuildContext context) {
          return new ProductDetail(data);
        }));
      },
    ));
  }
}
