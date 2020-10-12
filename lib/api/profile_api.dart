import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hostessrestaurant/models/profile.dart';
import 'package:hostessrestaurant/notifier/profile_notifier.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

getProfile(
    ProfileNotifier profileNotifier, String uid, String addressId) async {
  QuerySnapshot snapshot = await Firestore.instance
      .collection(uid)
      .where('id', isEqualTo: addressId)
      .getDocuments();

  List<Profile> _profileList = [];

  snapshot.documents.forEach((element) {
    Profile profile = Profile.fromMap(element.data);
    _profileList.add(profile);
  });

  profileNotifier.profileList = _profileList;
}

editAddress(
    Profile profile, String uid, bool imageExist, File imageFile) async {
  CollectionReference foodRef = Firestore.instance.collection(uid);

  if (imageFile != null) {
    if (imageExist == true) {
      StorageReference storageReference =
          await FirebaseStorage.instance.getReferenceFromUrl(profile.image);
      await storageReference.delete();
    }

    var uuid = Uuid().v4();
    var fileExtension = path.extension(imageFile.path);
    final StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('$uid/$uuid$fileExtension');

    await firebaseStorageRef
        .putFile(imageFile)
        .onComplete
        .catchError((onError) {
      print(onError);
      return false;
    });

    String _url = await firebaseStorageRef.getDownloadURL();
    print('uploaded image successfully: $_url');

    if (_url != null) {
      profile.image = _url;
    }
  }
  profile.updatedAt = Timestamp.now();

  await foodRef.document(profile.id).updateData(profile.toMap());
  print('edit profile with id: ${profile.id}');
}

addToGlobalSearch(GlobalProfile globalProfile) async {
  CollectionReference globalSearch =
      Firestore.instance.collection('Global_Search');

  globalProfile.createdAt = Timestamp.now();

  await globalSearch.document(globalProfile.id).setData(globalProfile.toMap());
  print('uploaded to Global Search successfully: ${globalProfile.id}');
}

deleteFromGlobalSearch(GlobalProfile globalProfile) async {
  await Firestore.instance
      .collection('Global_Search')
      .document(globalProfile.id)
      .delete();
  print('delete from Global Search successfully with id: ${globalProfile.id}');
}
