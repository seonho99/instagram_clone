import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:instagram_clone/models/feed_model.dart';
import 'package:instagram_clone/models/user_model.dart';
import 'package:uuid/uuid.dart';

import '../exception/custom_exception.dart';

class FeedRepository {
  final FirebaseStorage firebaseStorage;
  final FirebaseFirestore firebaseFirestore;

  const FeedRepository({
    required this.firebaseStorage,
    required this.firebaseFirestore,
  });

  Future<List<FeedModel>> getFeedList({
    String? uid,
}) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await firebaseFirestore
          .collection('feeds')
          .where('uid', isEqualTo: uid)
          .orderBy('createAt', descending: true)
          .get(); // descending: true 최신 문서 순으로
      return await Future.wait(snapshot.docs.map((e) async {
        Map<String, dynamic> data = e.data();
        DocumentReference<Map<String, dynamic>> writerDocRef = data['writer'];
        DocumentSnapshot<Map<String, dynamic>> writerSnapshot = await writerDocRef.get();
        UserModel userModel = UserModel.fromMap(writerSnapshot.data()!);
        data['writer'] = userModel;
        return FeedModel.fromMap(data);
      }).toList());
    }on FirebaseException catch (e) {
      throw CustomException(
        code: e.code,
        message: e.message!,
      );
    } catch (e) {
      throw CustomException(
        code: 'Exception',
        message: e.toString(),
      );
    }
  }


  Future<FeedModel> uploadFeed({
    required List<String> files,
    required String desc,
    required String uid,
  }) async {
    List<String> imageUrls = [];
    // a-z 알파뱃
    // 0~9 숫자
    // - 4EA

    try {

      WriteBatch batch = firebaseFirestore.batch();

      String feedId = Uuid().v1();

      // firestore
      DocumentReference<Map<String, dynamic>> feedDocRef = firebaseFirestore
          .collection('feeds').doc(feedId);

      DocumentReference<Map<String, dynamic>> userDocRef = firebaseFirestore
          .collection('users').doc(uid);

      // storage 참조
      Reference ref = firebaseStorage.ref().child('feeds').child('feedId');

        imageUrls = await Future.wait(files.map((e) async {
        String imageId = Uuid().v1();
        TaskSnapshot taskSnapshot = await ref.child(imageId).putFile(File(e));
        return await taskSnapshot.ref.getDownloadURL();
      }).toList());

      DocumentSnapshot<Map<String, dynamic>> userSnapShot = await userDocRef
          .get();
      UserModel userModel = UserModel.fromMap(userSnapShot.data()!);

      FeedModel feedModel = FeedModel.fromMap({
        'uid': uid,
        'feedId': feedId,
        'desc': desc,
        'imageUrls': imageUrls,
        'likes': [],
        'likeCount': 0,
        'commentCount': 0,
        'createAt': Timestamp.now(),
        'writer': userModel,
      });


      // await feedDocRef.set(feedModel.toMap(userDocRef: userDocRef));
      batch.set(feedDocRef, feedModel.toMap(userDocRef: userDocRef));

      // await userDocRef.update({
      //   'feedCount': FieldValue.increment(1),
      // });
      batch.update(userDocRef,{
          'feedCount': FieldValue.increment(1),
    });

      batch.commit();

      return FeedModel;

    } on FirebaseException catch (e) {
      _deleteImage(imageUrls);
      throw CustomException(
        code: e.code,
        message: e.message!,
      );
    } catch (e) {
      _deleteImage(imageUrls);
      throw CustomException(
        code: 'Exception',
        message: e.toString(),
      );
    }
  }

  void _deleteImage(List<String> imageUrls){
    imageUrls.forEach((element) async {
      await firebaseStorage.refFromURL(element).delete();
    });
  }
}