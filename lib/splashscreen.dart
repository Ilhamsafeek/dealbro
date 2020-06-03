import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:seeds/screens/home_page.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => new SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  var _visible = true;

  AnimationController animationController;
  Animation<double> animation;
  startTime() async {
    var _duration = new Duration(seconds: 2);
    return new Timer(_duration, navigateFromSplash);
  }

  @override
  void initState() {
    super.initState();
    animationController = new AnimationController(
      vsync: this,
      duration: new Duration(milliseconds: 800),
    );
    animation =
        new CurvedAnimation(parent: animationController, curve: Curves.easeOut);

    animation.addListener(() => this.setState(() {}));
    animationController.forward();

    setState(() {
      _visible = !_visible;
    });
    startTime();
  }

  navigateFromSplash() {
    Navigator.of(context).pushReplacement(
        CupertinoPageRoute<Null>(builder: (BuildContext context) {
      return new HomePage(title: '',);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          new Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(bottom: 30.0),
                  child: Text(
                    'Your Business Partner', style: TextStyle(fontSize:15, color: Colors.blue, fontWeight: FontWeight.bold),
                  ))
            ],
          ),
          new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset("assets/db-logo.png", height: 70,),
              Text(
                'DealBro',
                style: TextStyle(color: Colors.green, fontSize: 24),
              )
            ],
          ),
        ],
      ),
    );
  }
}
