
import 'package:flutter/material.dart';
import 'package:race_counter/counter_screen.dart';
import 'package:race_counter/forgotpassword_screen.dart';
import 'package:race_counter/login_screen.dart';
import 'package:race_counter/main_screen.dart';
import 'package:race_counter/registration_screen.dart';
import 'package:race_counter/search_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: MainScreen.id,
      routes: {
        MainScreen.id: (context) => MainScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegisterScreen.id: (context) => RegisterScreen(),
        CounterScreen.id: (context) => CounterScreen(),
        SearchScreen.id: (context) => SearchScreen(),
        ForgotPasswordScreen.id: (context) => ForgotPasswordScreen(),



      },
    );

  }
}

//TextField(
//decoration: InputDecoration(
//hintText: "Email",
//border: OutlineInputBorder(
//borderRadius: BorderRadius.circular(10),
//)
//),
//),
