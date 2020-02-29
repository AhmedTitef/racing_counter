//import 'package:assets_audio_player/assets_audio_player.dart';
import 'dart:async';

import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/material.dart';
import 'package:race_counter/login_screen.dart';
import 'package:race_counter/registration_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  static const String id = "main_screen";

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool isChecked = false;

//  final assets = <String> [
//    "car_horn.mp3"
//  ];
//
//  final AssetsAudioPlayer _assetsAudioPlayer = AssetsAudioPlayer();
//  var _currentAssetPosition = -1;
//  void _open(int assetIndex) {
//    _currentAssetPosition = assetIndex % assets.length;
//    _assetsAudioPlayer.open(
//      AssetsAudio(
//        asset: assets[_currentAssetPosition],
//        folder: "assets/",
//      ),
//    );
//  }
//
//  void _playPause() {
//    _assetsAudioPlayer.playOrPause();
//  }
//
//  @override
//  void dispose() {
//    _assetsAudioPlayer.stop();
//    super.dispose();
//  }
//
//

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: Scaffold(
        backgroundColor: Colors.blue,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              RaisedButton(
                elevation: 20,
                onPressed: () {

                  Navigator.pushNamed(context, LoginScreen.id);
                },
                color: Colors.green,
                child: Text("Login"),
              ),
              SizedBox(
                height: 10,
              ),
              RaisedButton(
                elevation: 20.0,
                color: Colors.yellow,
                onPressed: () {
                  Navigator.pushNamed(context, RegisterScreen.id);
                },
                child: Text("Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
