import 'package:flutter/material.dart';
import 'package:seeds/screens/home_page.dart';
import 'package:seeds/splashscreen.dart';
void main() {
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
     theme: new ThemeData(primaryColor: Color.fromRGBO(22, 121, 92, 1),),
      home: SplashScreen(),
    );
  }
}
