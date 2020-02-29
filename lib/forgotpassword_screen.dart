import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:race_counter/main_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const String id = "forgotpassword_screen";


  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

   String email;

  String warningText = "";

  bool isVisible = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Reset Password"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: TextField(
                  keyboardType: TextInputType.emailAddress,
//                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "Enter your email",
                    icon: Icon(Icons.email),
                  ),
                  onChanged: (value) {
                    email= value;
                  },
                ),
              ),
              Visibility(
                visible: isVisible,
                child: Text(warningText),
              ),
              SizedBox(
                height: 20,
              ),
              RaisedButton(
                child: Text(
                  "Reset",
                ),
                onPressed: () async {
                  try {
                    if (email.isNotEmpty) {
                      await _auth.sendPasswordResetEmail(email: email);

                      Navigator.pushNamed(context, MainScreen.id);
                    } else {
                      setState(() {
                        isVisible = true;
                        warningText = "Email is empty";
                      });

                    }
                  } catch (e) {
                    setState(() {
                      isVisible = true;
                      warningText = e;
                    });

                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
