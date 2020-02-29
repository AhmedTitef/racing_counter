


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:race_counter/counter_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:race_counter/forgotpassword_screen.dart';
import 'package:race_counter/search_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  static const String id = "login_screen";

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var _controller = new TextEditingController();
  final storage = new FlutterSecureStorage();

  bool showSpinner = false;

  final _auth  = FirebaseAuth.instance;

  String email;

  String password;

  String username;

  String status = "Offline";


  Future <bool> saveEmailPreference(String email  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("email", email);
    return prefs.commit();

  }

  Future <bool> savePasswordPreference( String password ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("password", password);
    return prefs.commit();

  }

  Future <String> getEmailPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString("email");
    return email;

  }
  Future <String> getPasswordPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String password = prefs.getString("password");

    return password;

  }

  @override
  void initState() {
    super.initState();
    getPasswordPreference();
    getEmailPreference();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.green,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[

              SizedBox(
                height: 10,
              ),
              Text(
                "Welcome Back!",
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: TextField(
                  keyboardType: TextInputType.emailAddress,
//                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "Email",
                    icon: Icon(Icons.email),
                  ),
                  onChanged: (value){
                    email = value;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: TextField(
//                  controller: _controller,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Password",
                    icon: Icon(Icons.lock),
                  ),
                  onChanged: (value){
                    password = value;
                  },
                ),
              ),
              SizedBox(
                height: 20,
              ),
              RaisedButton(
                onPressed: () async {
//              saveEmailPreference(email);
//              savePasswordPreference(password);
////                  saveEmailAndPassword();
                  setState(() {
                    showSpinner = true;
                  });

                  try {
                    final user = await _auth.signInWithEmailAndPassword(
                        email: email, password: password);
                    if(user != null){


                      status = "Online";
                      Firestore.instance.collection("users").document().updateData({"status" : "$status"});


                      Navigator.pushNamed(context, SearchScreen.id);

                      setState(() {
                        showSpinner = false;
                      });
                    }
                  }catch(e){
                    print(e);
                  }

                },
                child: Text(
                  "Login",
                ),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pushNamed(context, ForgotPasswordScreen.id);
                },
                child: Text(
                  "Forgot passowrd?",
                  style: TextStyle(
                    color: Colors.black12,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );

  }
//  void saveEmailAndPassword() {
//    String name = _controller.text;
//    saveEmailPasswordPreference(email, password).then((bool commited){
//
//    });
//  }


}
