import 'package:cloud_firestore/cloud_firestore.dart';

class Food {
  String id;
  String title;
  String description;
  String imageHigh;
  String imageLow;
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
      'subPrice': subPrice,
      'createdAt': createdAt,
      'updatedAt': updatedAt
    };
  }
}
