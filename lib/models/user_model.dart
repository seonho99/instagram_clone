import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? profileImage;
  final int feedCount;
  final List<String> followers;
  final List<String> following;
  final List<String> likes;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.profileImage,
    required this.feedCount,
    required this.followers,
    required this.following,
    required this.likes,
  });

  factory UserModel.init() {
    return UserModel(
      uid: '',
      name: '',
      email: '',
      profileImage: null,
      feedCount: 0,
      followers: [],
      following: [],
      likes: [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': this.uid,
      'name': this.name,
      'email': this.email,
      'profileImage': this.profileImage,
      'feedCount': this.feedCount,
      'followers': this.followers,
      'following': this.following,
      'likes': this.likes,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      profileImage: map['profileImage'],
      feedCount: map['feedCount'],
      followers: List<String>.from(map['followers']),
      following: List<String>.from(map['following']),
      likes: List<String>.from(map['likes']),
    );
  }

  @override
  String toString() {
    return 'UserModel{uid: $uid, name: $name, email: $email, profileImage: $profileImage, feedCount: $feedCount, followers: $followers, following: $following, likes: $likes}';
  }
}
