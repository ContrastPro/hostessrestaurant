import 'package:flutter/material.dart';
import 'package:hostessrestaurant/notifier/categories_notifier.dart';
import 'package:hostessrestaurant/notifier/food_notifier.dart';
import 'package:hostessrestaurant/screens/home_screen.dart';
import 'package:provider/provider.dart';


void main() => runApp(
  MultiProvider(
    providers: [
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

// flutter build apk --target-platform android-arm

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hostess Restaurant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: HomeScreen(),
    );
  }
}

/*Consumer<AuthNotifier>(
        builder: (context, notifier, child) {
          return notifier.user != null ? HomeScreen() : Login();
        },
      ),*/
