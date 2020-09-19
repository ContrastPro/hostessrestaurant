import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hostessrestaurant/models/profile.dart';
import 'package:hostessrestaurant/notifier/profile_notifier.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

getProfile(ProfileNotifier profileNotifier, String uid, String addressId) async {
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

addAddress(Profile profile, String uid, String title, String address) async {
  CollectionReference newAddress = Firestore.instance.collection(uid);

  profile.title = title;
  profile.address = address;
  profile.subTime = [
    "00:00 - 24:00",
    "00:00 - 24:00",
    "00:00 - 24:00",
    "00:00 - 24:00",
    "00:00 - 24:00",
    "00:00 - 24:00",
    "00:00 - 24:00",
  ];
  profile.createdAt = Timestamp.now();

  DocumentReference documentRef = await newAddress.add(profile.toMap());

  profile.id = documentRef.documentID;

  print('uploaded profile successfully: ${profile.id}');

  await documentRef.setData(profile.toMap());
}

editAddress(Profile profile, String uid, bool imageExist, File imageFile,
    Function profileUploaded) async {
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

  profileUploaded(profile);
  print('edit profile with id: ${profile.id}');
}
