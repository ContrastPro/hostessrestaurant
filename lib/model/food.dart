import 'package:cloud_firestore/cloud_firestore.dart';

class Food {
  String id;
  String title;
  String description;
  String imageHigh;
  String imageLow;
  List subIngredients = [];
  List subPrice = [];
  Timestamp createdAt;
  Timestamp updatedAt;

  Food();

  Food.fromMap(Map<String, dynamic> data) {
    id = data['id'];
    title = data['title'];
    description = data['description'];
    imageHigh = data['imageHigh'];
    imageLow = data['imageLow'];
    subIngredients = data['subIngredients'];
    subPrice = data['subPrice'];
    createdAt = data['createdAt'];
    updatedAt = data['updatedAt'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageHigh': imageHigh,
      'imageLow': imageLow,
      'subIngredients': subIngredients,
      'subPrice': subPrice,
      'createdAt': createdAt,
      'updatedAt': updatedAt
    };
  }
}
