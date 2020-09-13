import 'package:flutter/material.dart';
import 'package:hostessrestaurant/notifier/auth_notifier.dart';
import 'package:hostessrestaurant/notifier/categories_notifier.dart';
import 'package:hostessrestaurant/notifier/food_notifier.dart';
import 'package:hostessrestaurant/notifier/profile_notifier.dart';
import 'package:hostessrestaurant/screens/home_screen.dart';
import 'package:hostessrestaurant/screens/login_screen.dart';
import 'package:provider/provider.dart';

void main() => runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => AuthNotifier(),
          ),
          ChangeNotifierProvider(
            create: (context) => ProfileNotifier(),
          ),
          ChangeNotifierProvider(
            create: (context) => CategoriesNotifier(),
          ),
          ChangeNotifierProvider(
            create: (context) => FoodNotifier(),
          ),
        ],
        child: MyApp(),
      ),
    );

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hostess Restaurant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: Consumer<AuthNotifier>(
        builder: (context, notifier, child) {
          return notifier.user != null ? HomeScreen() : Login();
        },
      ),
    );
  }
}

// flutter build apk --target-platform android-arm
