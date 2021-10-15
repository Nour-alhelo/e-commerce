import 'package:e_commerce/homePage.dart';
import 'package:e_commerce/signUpPage.dart';
import 'package:e_commerce/splash.dart';
import 'package:e_commerce/welcomePage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(ECommerce());
}

class ECommerce extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: Splash.id,
      routes: {
        WelcomePage.id: (context) => WelcomePage(),
        SignUpPage.id: (context) => SignUpPage(),
        HomePage.id: (context) => HomePage(),
        Splash.id: (context) => Splash(),
      },
    );
  }
}
