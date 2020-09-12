import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:hostessrestaurant/models/profile.dart';

class ProfileNotifier with ChangeNotifier {
  List<Profile> _profileList = [];
  Profile _currentProfile;

  UnmodifiableListView<Profile> get profileList =>
      UnmodifiableListView(_profileList);

  Profile get currentProfile => _currentProfile;

  set profileList(List<Profile> profileList) {
    _profileList = profileList;
    notifyListeners();
  }

  set currentProfile(Profile profile) {
    _currentProfile = profile;
    notifyListeners();
  }
}
