import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:lestari_flutter/app/repositories/user/base_user_repository.dart';
import 'package:lestari_flutter/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepository extends BaseUserRepository {
  @override
  Future<UserModel?> getUserById(String uid) async {
    try {
      UserModel? userModel;

      final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
      await docRef.get().then((DocumentSnapshot doc) {
          Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
          map['uid'] = doc.id;
          userModel = UserModel.fromMap(map);
      });

      return userModel;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<void> listenToCurrentUser(ValueNotifier<UserModel?> userModel) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String uid = prefs.getString('uid')!;

      final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
      docRef.snapshots().listen((event) {
        Map<String, dynamic> map = event.data() as Map<String, dynamic>;
        map['uid'] = event.id;
        userModel.value = UserModel.fromMap(map);
      });
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<void> updateProfile(String name, String currentImageUrl, File imageFile) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String uid = prefs.getString('uid')!;
      String email = prefs.getString('email')!;

      final Reference imageRef = FirebaseStorage.instance.ref().child('users/$uid/profile.png');

      try {
        UserModel updatedUser;
        if (imageFile.path != '') {
          await imageRef.putFile(imageFile);
          String updatedImageUrl = await imageRef.getDownloadURL();

          updatedUser = UserModel(uid: uid, name: name, email: email, role: 'user', notifications: 0, imageUrl: updatedImageUrl, updatedAt: DateTime.now());
        } else {
          updatedUser = UserModel(uid: uid, name: name, email: email, role: 'user', notifications: 0, imageUrl: currentImageUrl, updatedAt: DateTime.now());
        }

        final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
        await docRef.set(updatedUser.toMap());
      } catch (e) {
        throw e.toString();
      }
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<void> updateUser(UserModel userModel) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(userModel.uid);
    await docRef.set(userModel.toMap());
  }
}