import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:hostessrestaurant/models/categories.dart';

class CategoriesNotifier with ChangeNotifier {
  List<Categories> _categoriesList = [];

  UnmodifiableListView<Categories> get categoriesList =>
      UnmodifiableListView(_categoriesList);

  set categoriesList(List<Categories> categoriesList) {
    _categoriesList = categoriesList;
    notifyListeners();
  }
}
