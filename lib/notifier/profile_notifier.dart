import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:hostessrestaurant/models/profile.dart';

class ProfileNotifier with ChangeNotifier {
  List<Profile> _profileList = [];

  UnmodifiableListView<Profile> get profileList =>
      UnmodifiableListView(_profileList);

  set profileList(List<Profile> profileList) {
    _profileList = profileList;
    notifyListeners();
  }
}
