import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hostessrestaurant/models/categories.dart';
import 'package:hostessrestaurant/notifier/categories_notifier.dart';

getCategories(CategoriesNotifier categoriesNotifier, String uid, String address,
    String language) async {
  QuerySnapshot snapshot = await Firestore.instance
      .collection(uid)
      .document(address)
      .collection(language)
      .document('Categories')
      .collection('Menu')
      .orderBy("createdAt", descending: false)
      .getDocuments();

  List<Categories> _categoriesList = [];

  snapshot.documents.forEach((document) {
    Categories food = Categories.fromMap(document.data);
    _categoriesList.add(food);
  });

  categoriesNotifier.categoriesList = _categoriesList;
}

addCategory(Categories categories, String uid, String address, String language,
    String category) async {
  CollectionReference categoryRef = Firestore.instance
      .collection(uid)
      .document(address)
      .collection(language)
      .document('Categories')
      .collection('Menu');

  categories.title = category;

  categories.createdAt = Timestamp.now();

  DocumentReference documentRef = await categoryRef.add(categories.toMap());

  categories.id = documentRef.documentID;

  print('uploaded category successfully: ${categories.id}');

  await documentRef.setData(categories.toMap(), merge: true);
}

deleteCategory(Categories categories, String uid, String address,
    String language) async {
  await Firestore.instance
      .collection(uid)
      .document(address)
      .collection(language)
      .document('Categories')
      .collection('Menu')
      .document(categories.id)
      .delete();

  print('delete categories successfully with id: ${categories.id}');
}
