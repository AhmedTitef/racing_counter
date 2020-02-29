import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:timer_builder/timer_builder.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class Counter extends AnimatedWidget {
  Counter({Key key, this.animation}) : super(key: key, listenable: animation);
  final Animation<int> animation;

  @override
  build(BuildContext context) {
    return new Text(
      animation.value.toString(),
      style: new TextStyle(fontSize: 200.0),
    );
  }
}

class CounterScreen extends StatefulWidget {
  CounterScreen(
      {this.combinedUID,
      this.combinedUIDreversed,
      this.opponentUID,
      this.myUID});

  String myUID;
  String opponentUID;
  String combinedUID;
  String combinedUIDreversed;
  static const String id = "counter_screen";

  @override
  _CounterScreenState createState() => _CounterScreenState(
      combinedUID: combinedUID,
      combinedUIDreversed: combinedUIDreversed,
      opponentUID: opponentUID,
      myUID: myUID);
}

class _CounterScreenState extends State<CounterScreen>
    with TickerProviderStateMixin {
  String myUID;
  String opponentUID;
  String combinedUID;
  String combinedUIDreversed;

  _CounterScreenState(
      {this.combinedUID,
      this.combinedUIDreversed,
      this.opponentUID,
      this.myUID});

  AnimationController _controller;

  Color readyButtonColor = Colors.grey;

  Color notReadyButtonColor = Colors.green;
  Color onlineButtonColor = Colors.grey;

  Color offlineButtonColor = Colors.green;
  bool isVisible = false;

  bool isSwitched;
  static const int startValue = 0;
  String readyButtonText = "Ready";

  var toStopAudio = false;

  var backgroundColor = Colors.white;

  Icon _back = new Icon(Icons.arrow_back_ios);
  Widget _appBarTitle = new Text("RollRacing Counter");

  String goStatus = "";
  var myUserName;
  var opponentUserName;

  @override
  void initState() {
    super.initState();

    _controller = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 3),
    );
  }

  var statusIcon; //clear or check icon

  var statusText; //offline text or online text

  checkIfOnlineOrNot() async {
    DocumentSnapshot ds = await Firestore.instance
        .collection("users")
        .document(combinedUIDreversed)
        .get();
    var userDocument = ds.data;
    if (userDocument['opponentStatus'] == "Online") {
      setState(() {
        statusText = "ONLINE";
        statusIcon = Icons.check;
      });
    } else {
      setState(() {
        statusText = "OFFLINE";
        statusIcon = Icons.clear;
      });
    }
    print(ds.exists);
    return ds.exists;
  }

  Widget getMyUserName(BuildContext context) {
    return new StreamBuilder(
      stream:
          Firestore.instance.collection("users").document(myUID).snapshots(),
      builder: (context, snapshot) {
        var userDocument = snapshot.data;

        myUserName = userDocument["username"];

        return Text(myUserName);
      },
    );
  }

  Widget getOpponentUsername(BuildContext context) {
    return new StreamBuilder(
      stream: Firestore.instance
          .collection("users")
          .document(opponentUID)
          .snapshots(),
      builder: (context, snapshot) {
        var userDocument = snapshot.data;

        opponentUserName = userDocument["username"];

        return Text(opponentUserName);
      },
    );
  }

  dispose() {
    _controller.dispose();

    super.dispose();
  }

  Widget _buildBar(BuildContext context) {
    return new AppBar(
      centerTitle: true,
      title: _appBarTitle,
      leading: new IconButton(
        icon: _back,
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  void changebackgroundColor() {
    setState(() {
      Timer(Duration(seconds: 1), () {
        backgroundColor = Colors.green;
      });
    });
    setState(() {
      Timer(Duration(seconds: 2), () {
        backgroundColor = Colors.white;
      });
    });

    setState(() {
      Timer(Duration(seconds: 3), () {
        backgroundColor = Colors.red;
      });
    });
  }

  final player = AudioCache();

  void startCarHorn() {
    Timer(Duration(seconds: 1), () => player.play("car_horn.mp3"));
    Timer(Duration(seconds: 2), () => player.play("car_horn.mp3"));
    Timer(Duration(seconds: 3), () => player.play("car_horn.mp3"));
  }

  FirebaseUser loggedInUser;

  var count;

  Widget speedValue(BuildContext context) {
    var geolocator = Geolocator();
    var locationOptions =
        LocationOptions(accuracy: LocationAccuracy.best, distanceFilter: 0);
if(onlineButtonColor == Colors.green) {
  return new StreamBuilder(
      stream: geolocator.getPositionStream(locationOptions),
      builder: (context, position) {
        if (!position.hasData) return Text("Nothing");
        speedInMPH = (position.data.speed * 2.237).toInt();
        return Text("My Speed is :  $speedInMPH mph");
      });
}
else{
  return Text ("Go Online to See Your Speed");
}
  }

  Widget startCounter(BuildContext context) {
    return new StreamBuilder(
        stream: Firestore.instance
            .collection('users')
            .document(combinedUIDreversed)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return new Text("Loading");
          }

          var userDocument = snapshot.data;
          if (userDocument['status'] == "online" &&
              userDocument['opponentStatus'] == "online" &&
              userDocument['ready'] == "Ready" &&
              userDocument['opponentReady'] == "Ready") {
            Timer(Duration(seconds: 3), () {
              _controller.forward();
              carHonkActivate();

              _controller.addStatusListener((status) {
                Timer(Duration(seconds: 2), () {
                  if (status == AnimationStatus.completed) {
                    _controller.stop();
                    _changeColorForNotReady();
                  }
                });
              });
            });

            return Counter(
              animation: new StepTween(
                begin: startValue,
                end: 3,
              ).animate(_controller),
            );
          } else {
            _controller.stop();
            _controller.reset();
            return new Text("Please GO ONLINE then READY to Start");
          }
        });
  }

  Widget onlineAndofflineButtons(BuildContext context) {
    return new StreamBuilder(
        stream: Firestore.instance
            .collection('users')
            .document(combinedUID)
            .snapshots(),
        builder: (context, snapshot) {
          return Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  onPressed: _changeColorForOnline,
                  child: Text("Go Online"),
                  color: onlineButtonColor,
                ),
                SizedBox(
                  width: 40,
                ),
                RaisedButton(
                  onPressed: _changeColorForOffline,
                  child: Text("Go Offline"),
                  color: offlineButtonColor,
                ),
              ],
            ),
          );
        });
  }

  Widget iconForOpponentStatus(BuildContext context) {
    return new StreamBuilder(
        stream: Firestore.instance
            .collection('users')
            .document(combinedUIDreversed)
            .snapshots(),
        builder: (context, snapshot) {
          var userDocument = snapshot.data;

          if (userDocument['status'] == "online") {
            statusIcon = Icons.check;

            return Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(statusIcon),
                ],
              ),
            );
          } else {
            statusIcon = Icons.clear;

            return Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(statusIcon),
                ],
              ),
            );
          }
        });
  }

  Widget textForOpponentStatus(BuildContext context) {
    return new StreamBuilder(
        stream: Firestore.instance
            .collection('users')
            .document(combinedUIDreversed)
            .snapshots(),
        builder: (context, snapshot) {
          var userDocument = snapshot.data;

          if (userDocument['status'] == "online") {
            statusText = "ONLINE";

            return Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(" is $statusText"),
                ],
              ),
            );
          } else {
            statusText = "OFFLINE";

            return Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(" is $statusText"),
                ],
              ),
            );
          }
        });
  }

  void _changeColorForReady() {
    setState(() {
      savedSpeedMPH = speedInMPH;
      print("Speed Run at : $savedSpeedMPH");
      readyButtonColor = Colors.green;

      notReadyButtonColor = Colors.grey;
      Firestore.instance
          .collection("users")
          .document(combinedUIDreversed)
          .updateData({"opponentReady": "Ready"});

      Firestore.instance
          .collection("users")
          .document(combinedUID)
          .updateData({"ready": "Ready"});
    });

    _controller.stop();
  }

  var savedSpeedMPH = 0;

  void _changeColorForOnline() {
    speedValue(context);
    // showAlertForJumping(context);
    setState(() {
      isVisible = true;

      onlineButtonColor = Colors.green;
      offlineButtonColor = Colors.grey;
      Firestore.instance
          .collection("users")
          .document(combinedUIDreversed)
          .updateData({"opponentStatus": "online"});

      Firestore.instance
          .collection("users")
          .document(combinedUID)
          .updateData({"status": "online"});
    });
    _controller.stop();
  }

  void _changeColorForOffline() {
    setState(() {
      isVisible = false;

      onlineButtonColor = Colors.grey;
      offlineButtonColor = Colors.green;
      Firestore.instance
          .collection("users")
          .document(combinedUIDreversed)
          .updateData({"opponentStatus": "offline"});

      Firestore.instance
          .collection("users")
          .document(combinedUID)
          .updateData({"status": "offline"});
    });

    _controller.stop();
  }

  void _changeColorForNotReady() {
    setState(() {
      readyButtonColor = Colors.grey;
      notReadyButtonColor = Colors.green;
      Firestore.instance
          .collection("users")
          .document(combinedUIDreversed)
          .updateData({"opponentReady": "Not Ready"});

      Firestore.instance
          .collection("users")
          .document(combinedUID)
          .updateData({"ready": "Not Ready"});
    });
    _controller.stop();
  }

  Widget readyAndnotreadyButtons(BuildContext context) {
    return new StreamBuilder(
        stream: Firestore.instance
            .collection('users')
            .document(combinedUID)
            .snapshots(),
        builder: (context, snapshot) {
          return Visibility(
            visible: isVisible,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    onPressed: _changeColorForReady,
                    child: Text("Ready"),
                    color: readyButtonColor,
                  ),
                  SizedBox(
                    width: 40,
                  ),
                  RaisedButton(
                    onPressed: _changeColorForNotReady,
                    child: Text("Not Ready"),
                    color: notReadyButtonColor,
                  ),
                ],
              ),
            ),
          );
        });
  }

  var speedInMPH = 0;

  showAlertForJumping(BuildContext context) {
    var geolocator = Geolocator();
    var locationOptions =
        LocationOptions(accuracy: LocationAccuracy.best, distanceFilter: 0);
    if (onlineButtonColor == Colors.green) {
      return new StreamBuilder(
          stream: geolocator.getPositionStream(locationOptions),
          builder: (context, position) {
            if (!position.hasData) return Text("");
            speedInMPH = (position.data.speed * 2.237).toInt();

            if (speedInMPH - savedSpeedMPH > 8 &&
                readyButtonColor == Colors.green) { // that means I jumped
              _controller.stop();

              _controller.addStatusListener((status) {
                Timer(Duration(seconds: 0), () {
                  if (status == AnimationStatus.dismissed) {
                    _changeColorForNotReady();
                  }
                });
              });

              //Then send data to firebase that i jumped and stop counting

              //_changeColorForNotReady();
              return Container(
                child: Expanded(
                  child: AlertDialog(
                    title: Text(
                      "You Are Ahead, Slow Down ",
                    ),
                    actions: <Widget>[],
                  ),
                ),
              );
            } else if (savedSpeedMPH - speedInMPH > 8 &&
                readyButtonColor == Colors.green) {
              _controller.addStatusListener((status) {
                Timer(Duration(seconds: 0), () {
                  if (status == AnimationStatus.dismissed) {
                    _changeColorForNotReady();
                  }
                });
              });
              return Container(
                child: Expanded(
                  child: AlertDialog(
                    title: Text(
                      "You Are Behind, Speed Up",
                    ),
                    actions: <Widget>[],
                  ),
                ),
              );;
            }
            else{
              return Text ("");
            }
            ;
          });
    } else {
      return Text("");
    }
  }

  void carHonkActivate() {
    if (readyButtonColor == Colors.green && _controller.isAnimating) {
      startCarHorn();
    }
  }

  @override
  Widget build(BuildContext context) {
    //checkIfOnlineOrNot();

//getCurrentSpeed();

    return SafeArea(
      child: Scaffold(
        appBar: _buildBar(context),
        backgroundColor: backgroundColor,
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("My Username is : "),
                getMyUserName(context),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                iconForOpponentStatus(context),
                getOpponentUsername(context),
                textForOpponentStatus(context),
              ],
            ),
            //getMyUserName(context),
            //getOpponentUsername(context),

            startCounter(context),
            //startCarHorn();
            readyAndnotreadyButtons(context),
            onlineAndofflineButtons(context),
            //Text(speedInMPs.toString()),
            speedValue(context),
            showAlertForJumping(context),
          ],
        )),
      ),
    );
  }
}
