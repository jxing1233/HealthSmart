import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'login_page.dart';

class SplashPage extends StatelessWidget{


  @override
  Widget build(context){

    Future.delayed(
        const Duration(seconds: 3),
        (){

          bool userLoggedIn = FirebaseAuth.instance.currentUser != null;

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (builder) => userLoggedIn ? HomePage() : LoginPage()),
              (route) => false
          );
        }
    );

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "HealthSmart",
              style: Theme.of(context).textTheme.headlineLarge,
            ),

            const SizedBox(
              height: 10,
            ),

            const Image(
              image: AssetImage("assets/logo.png"),
              width: 250,
              height: 250,
            ),

          ],
        ),
      )
    );
  }

}