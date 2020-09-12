import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:hostessrestaurant/models/categories.dart';

class CategoriesNotifier with ChangeNotifier {
  List<Categories> _categoriesList = [];
  Categories _currentCategories;

  UnmodifiableListView<Categories> get categoriesList => UnmodifiableListView(_categoriesList);

  Categories get currentCategories => _currentCategories;

  set categoriesList(List<Categories> categoriesList) {
    _categoriesList = categoriesList;
    notifyListeners();
  }

  set currentCategories(Categories categories) {
    _currentCategories = categories;
    notifyListeners();
  }

  addCategories(Categories categories) {
    _categoriesList.insert(0, categories);
    notifyListeners();
  }

  deleteCategories(Categories categories) {
    _categoriesList.removeWhere((_categories) => _categories.id == categories.id);
    notifyListeners();
  }
}
