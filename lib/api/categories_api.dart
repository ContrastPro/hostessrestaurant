import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hostessrestaurant/models/categories.dart';
import 'package:hostessrestaurant/notifier/categories_notifier.dart';

getCategories(CategoriesNotifier categoriesNotifier, String restaurant,
    String address) async {
  QuerySnapshot snapshot = await Firestore.instance
      .collection(restaurant)
      .document(address)
      .collection('ru')
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

addCategory(Categories categories, Function categoriesUploaded,
    String restaurant, String address, String category) async {
  CollectionReference categoryRef = Firestore.instance
      .collection(restaurant)
      .document(address)
      .collection('ru')
      .document('Categories')
      .collection('Menu');

  categories.title = category;

  categories.createdAt = Timestamp.now();

  DocumentReference documentRef = await categoryRef.add(categories.toMap());

  categories.id = documentRef.documentID;

  print('uploaded food successfully: ${categories.id}');

  await documentRef.setData(categories.toMap(), merge: true);

  categoriesUploaded(categories);
}

deleteCategory(Categories categories, Function categoriesDeleted,
    String restaurant, String address, String category) async {
  await Firestore.instance
      .collection(restaurant)
      .document(address)
      .collection('ru')
      .document('Categories')
      .collection('Menu')
      .document(categories.id)
      .delete();

  categoriesDeleted(categories);

  print('delete categories successfully with id: ${categories.id}');
}
