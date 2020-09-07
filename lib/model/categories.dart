import 'package:cloud_firestore/cloud_firestore.dart';

class Categories {
  String id;
  String title;
  Timestamp createdAt;

  Categories();

  Categories.fromMap(Map<String, dynamic> data) {
    id = data['id'];
    title = data['title'];
    createdAt = data['createdAt'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt,
    };
  }
}
