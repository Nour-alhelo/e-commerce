import 'dart:ui';

import 'package:e_commerce/welcomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'homePage.dart';

class Splash extends StatefulWidget {
  static const id = "Splash";
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    Firebase.initializeApp();

    Future.delayed(Duration(seconds: 3), () {
      final FirebaseAuth _auth = FirebaseAuth.instance;
      if (_auth.currentUser != null) {
        Navigator.pushNamed(context, HomePage.id);
      } else
        Navigator.pushNamed(context, WelcomePage.id);
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: width,
        height: height,
        child: Image.asset(
          'images/splash.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
