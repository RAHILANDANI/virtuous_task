import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task/screens/home_screen.dart';
import 'package:task/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
    apiKey: 'AIzaSyDbFerFRi6ATBAAoPfqRDUTG21adPYiGLM',
    appId: '1:883171806015:android:841923d4bcb2558731618a',
    messagingSenderId: '883171806015',
    projectId: 'virtuous-task',
    storageBucket: 'virtuous-task.firebasestorage.app',
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Future<bool> isUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Virtuous Task',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FutureBuilder<bool>(
        future: isUserLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            return snapshot.data == true ? HomeScreen() : LoginScreen();
          }
        },
      ),
    );
  }
}