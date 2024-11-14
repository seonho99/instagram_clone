import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthRepository {
  final FirebaseAuth firebaseAuth;
  final FirebaseStorage firebaseStorage;
  final FirebaseFirestore firebaseFirestore;

  const AuthRepository({
    required this.firebaseAuth,
    required this.firebaseStorage,
    required this.firebaseFirestore,
  });

  Future<void> signUp({
    required String email,
    required String name,
    required String password,
    required Uint8List? profileImage,
  }) async {
    UserCredential userCredential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    String uid = userCredential.user!.uid;

    await userCredential.user!.sendEmailVerification();

    String? downloadUrl = null;

    if(profileImage != null){
      Reference ref = firebaseStorage.ref().child('profile').child(uid);
      TaskSnapshot snapshot = await ref.putData(profileImage);
      downloadUrl = await snapshot.ref.getDownloadURL();
    }

    firebaseFirestore.collection('user').doc(uid).set(
      {
        'uid': uid,
        'email': email,
        'name': name,
        'profile': downloadUrl,
        'feedCount': 0,
        'likes':[],
        'followers':[],
        'following':[],
      }
    );
    firebaseAuth.signOut();

  }
}
