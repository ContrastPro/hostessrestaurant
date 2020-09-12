import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hostessrestaurant/models/profile.dart';
import 'package:hostessrestaurant/notifier/profile_notifier.dart';

getProfile(
    ProfileNotifier profileNotifier, String restaurant, String address) async {
  QuerySnapshot snapshot = await Firestore.instance
      .collection(restaurant)
      .where('address', isEqualTo: address)
      .getDocuments();

  List<Profile> _profileList = [];

  snapshot.documents.forEach((element) {
    Profile profile = Profile.fromMap(element.data);
    _profileList.add(profile);
  });

  profileNotifier.profileList = _profileList;
}
