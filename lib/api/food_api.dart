import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hostessrestaurant/models/food.dart';
import 'package:hostessrestaurant/notifier/food_notifier.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

getFoods(FoodNotifier foodNotifier, String uid, String address, String language,
    String category) async {
  QuerySnapshot snapshot = await Firestore.instance
      .collection(uid)
      .document(address)
      .collection(language)
      .document('Menu')
      .collection(category)
      .orderBy("createdAt", descending: false)
      .getDocuments();
  List<Food> _foodList = [];

  snapshot.documents.forEach((document) {
    Food food = Food.fromMap(document.data);
    _foodList.add(food);
  });

  foodNotifier.foodList = _foodList;
}

addFood(Food food, String uid, String address, String language, String category,
    File fileHigh, File fileLow, Function foodUploaded) async {
  if (fileHigh != null) {
    var uuid = Uuid().v4();

    ///
    var fileExtensionHigh = path.extension(fileHigh.path);
    var fileExtensionLow = path.extension(fileLow.path);

    ///
    final StorageReference firebaseStorageRefHigh = FirebaseStorage.instance
        .ref()
        .child('$uid/imageHigh/$uuid$fileExtensionHigh');

    final StorageReference firebaseStorageRefLow = FirebaseStorage.instance
        .ref()
        .child('$uid/imageLow/$uuid$fileExtensionLow');

    ///

    await firebaseStorageRefHigh
        .putFile(fileHigh)
        .onComplete
        .catchError((onError) {
      print(onError);
      return false;
    });

    await firebaseStorageRefLow
        .putFile(fileLow)
        .onComplete
        .catchError((onError) {
      print(onError);
      return false;
    });

    ///
    String _urlHigh = await firebaseStorageRefHigh.getDownloadURL();
    String _urlLow = await firebaseStorageRefLow.getDownloadURL();
    print('uploaded image successfully: $_urlHigh\n$_urlLow');

    ///
    _addFood(food, uid, address, language, category, _urlHigh, _urlLow,
        foodUploaded);
  } else {
    /// Uploading Food without Image
    _addFood(food, uid, address, language, category, null, null, foodUploaded);
  }
}

_addFood(
    Food food,
    String uid,
    String address,
    String language,
    String category,
    String imageUrlHigh,
    String imageUrlLow,
    Function foodUploaded) async {
  CollectionReference foodRef = Firestore.instance
      .collection(uid)
      .document(address)
      .collection(language)
      .document('Menu')
      .collection(category);

  if (imageUrlHigh != null && imageUrlLow != null) {
    food.imageHigh = imageUrlHigh;
    food.imageLow = imageUrlLow;
  }

  food.createdAt = Timestamp.now();

  DocumentReference documentRef = await foodRef.add(food.toMap());

  food.id = documentRef.documentID;

  print('uploaded food successfully: ${food.id}');

  await documentRef.setData(food.toMap(), merge: true);

  foodUploaded(food);
}

editFood(
    Food food,
    String uid,
    String address,
    String language,
    String category,
    bool imageExist,
    File fileHigh,
    File fileLow,
    Function foodUploaded) async {
  CollectionReference foodRef = Firestore.instance
      .collection(uid)
      .document(address)
      .collection(language)
      .document('Menu')
      .collection(category);

  if (fileHigh != null && fileLow != null) {
    if (imageExist == true) {
      ///
      StorageReference storageReferenceHigh =
          await FirebaseStorage.instance.getReferenceFromUrl(food.imageHigh);
      await storageReferenceHigh.delete();

      ///
      StorageReference storageReferenceLow =
          await FirebaseStorage.instance.getReferenceFromUrl(food.imageLow);
      await storageReferenceLow.delete();
    }

    var uuid = Uuid().v4();

    ///
    var fileExtensionHigh = path.extension(fileHigh.path);
    var fileExtensionLow = path.extension(fileLow.path);

    ///
    final StorageReference firebaseStorageRefHigh = FirebaseStorage.instance
        .ref()
        .child('$uid/imageHigh/$uuid$fileExtensionHigh');

    final StorageReference firebaseStorageRefLow = FirebaseStorage.instance
        .ref()
        .child('$uid/imageLow/$uuid$fileExtensionLow');

    ///

    await firebaseStorageRefHigh
        .putFile(fileHigh)
        .onComplete
        .catchError((onError) {
      print(onError);
      return false;
    });

    await firebaseStorageRefLow
        .putFile(fileLow)
        .onComplete
        .catchError((onError) {
      print(onError);
      return false;
    });

    ///
    String _urlHigh = await firebaseStorageRefHigh.getDownloadURL();
    String _urlLow = await firebaseStorageRefLow.getDownloadURL();
    print('uploaded image successfully: $_urlHigh\n$_urlLow');

    if (_urlHigh != null && _urlLow != null) {
      food.imageHigh = _urlHigh;
      food.imageLow = _urlLow;
    }
  }
  food.updatedAt = Timestamp.now();

  await foodRef.document(food.id).updateData(food.toMap());

  foodUploaded(food);
  print('edit food with id: ${food.id}');
}

deleteFood(Food food, String uid, String address, String language,
    String category, Function foodDeleted) async {
  if (food.imageHigh != null) {
    ///
    StorageReference storageReferenceHigh =
        await FirebaseStorage.instance.getReferenceFromUrl(food.imageHigh);
    await storageReferenceHigh.delete();

    ///
    StorageReference storageReferenceLow =
        await FirebaseStorage.instance.getReferenceFromUrl(food.imageLow);
    await storageReferenceLow.delete();

    print('image deleted');
  }

  await Firestore.instance
      .collection(uid)
      .document(address)
      .collection(language)
      .document('Menu')
      .collection(category)
      .document(food.id)
      .delete();

  foodDeleted(food);

  print('delete food successfully with id: ${food.id}');
}
