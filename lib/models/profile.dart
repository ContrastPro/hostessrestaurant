import 'package:cloud_firestore/cloud_firestore.dart';

class Profile {
  String id;
  String title;
  String address;
  String phone;
  String image;
  bool globalSearch;
  List subTime = [];
  List subLanguages = [];
  Timestamp createdAt;
  Timestamp updatedAt;

  Profile();

  Profile.fromMap(Map<String, dynamic> data) {
    id = data['id'];
    title = data['title'];
    address = data['address'];
    phone = data['phone'];
    image = data['image'];
    globalSearch = data['globalSearch'];
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
      'phone': phone,
      'image': image,
      'globalSearch': globalSearch,
      'subTime': subTime,
      'subLanguages': subLanguages,
      'createdAt': createdAt,
      'updatedAt': updatedAt
    };
  }
}

class GlobalProfile {
  String id;
  String globalId;
  String title;
  String address;
  Timestamp createdAt;

  GlobalProfile();

  GlobalProfile.fromMap(Map<String, dynamic> data) {
    id = data['id'];
    globalId = data['globalId'];
    title = data['title'];
    address = data['address'];
    createdAt = data['createdAt'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'globalId': globalId,
      'title': title,
      'address': address,
      'createdAt': createdAt,
    };
  }
}
