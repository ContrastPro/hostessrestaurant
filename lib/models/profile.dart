import 'package:cloud_firestore/cloud_firestore.dart';

class Profile {
  String id;
  String title;
  String address;
  String image;
  List subTime = [];
  List subLanguages = [];
  Timestamp createdAt;
  Timestamp updatedAt;

  Profile();

  Profile.fromMap(Map<String, dynamic> data) {
    id = data['id'];
    title = data['title'];
    address = data['address'];
    image = data['image'];
    subTime = data['subTime'];
    subLanguages = data['subLanguages'];
    createdAt = data['createdAt'];
    updatedAt = data['updatedAt'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'address': address,
      'image': image,
      'subTime': subTime,
      'subLanguages': subLanguages,
      'createdAt': createdAt,
      'updatedAt': updatedAt
    };
  }
}
