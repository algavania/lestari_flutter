import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lestari_flutter/app/repositories/auth/base_auth_repository.dart';
import 'package:lestari_flutter/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/shared_code.dart';

class AuthRepository extends BaseAuthRepository {
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  final googleSignIn = GoogleSignIn();

  @override
  Future<void> loginWithPassword(String email, String password) async {
    try {
      final UserCredential credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      User user = credential.user!;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('uid', user.uid);
      prefs.setString('email', user.email!);

      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        data['uid'] = user.uid;
        UserModel userModel = UserModel.fromMap(data);

        if (userModel.role != 'user') throw 'not-user';
      } else {
        throw 'not-exist';
      }
    } on FirebaseAuthException catch (e) {
      throw SharedCode.handleAuthErrorCodes(e.code);
    }
  }

  @override
  Future<void> registerWithPassword(
      String email, String password, String displayName) async {
    try {
      final UserCredential credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User user = credential.user!;
      await user.updateDisplayName(displayName);
      await _setUser(user, displayName, email);
    } on FirebaseAuthException catch (e) {
      throw SharedCode.handleAuthErrorCodes(e.code);
    }
  }

  Future<void> _setUser(User user, String displayName, String email) async {
    UserModel userModel = UserModel(
        uid: user.uid,
        name: displayName,
        email: email,
        role: 'user',
        notifications: 0,
        imageUrl: user.photoURL ?? 'https://firebasestorage.googleapis.com/v0/b/lestari-42054.appspot.com/o/default%2Fdefault_profile.jpg?alt=media&token=2257a163-0f7b-4194-8c4e-333256db8ce1',
        updatedAt: DateTime.now());
    await addUser(userModel);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('uid', user.uid);
    prefs.setString('email', user.email!);
  }

  @override
  Future<void> addUser(UserModel model) async {
    Map<String, Object?> json = model.toMap();
    return await users.doc(model.uid).set(json);
  }

  Future<User?> socialAuth(
      {bool isLogin = false, required UserCredential userCredential}) async {
    await _checkNewUser(isLogin: isLogin, userCredential: userCredential);
    return userCredential.user;
  }

  Future<void> _checkNewUser(
      {bool isLogin = false, required UserCredential userCredential}) async {
    User? user = userCredential.user;
    // Check if user has registered and in login , if not, remove user and throw exception
    bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
    //debugPrint('is login $isLogin, isNewUser $isNewUser');
    if (isLogin && isNewUser) {
      await user?.delete();
      await SharedCode.logout();
      throw 'User tidak terdaftar';
    }

    // Check if user has registered and in register, if yes, throw exception
    if (!isLogin && !isNewUser) {
      await SharedCode.logout();
      throw 'User sudah terdaftar';
    }

    if (user != null) {
      await _setUser(user, user.displayName ?? '', user.email ?? '');
    }
  }

  Future<UserCredential> fetchGoogleUserCredential() async {
    await SharedCode.logout();
    UserCredential userCredential;
    if (kIsWeb) {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();

      googleProvider.addScope('profile').addScope('email');
      googleProvider.setCustomParameters(
          {'prompt': 'select_account', 'login_hint': 'user@example.com'});
      userCredential =
      await FirebaseAuth.instance.signInWithPopup(googleProvider);
    } else {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);
    }
    return userCredential;
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    final user = FirebaseAuth.instance.currentUser;
    final credential = EmailAuthProvider.credential(email: user!.email!, password: currentPassword);
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  Future<void> updateEmail(String email) async {
    await users.doc(FirebaseAuth.instance.currentUser!.uid).update({
      'email': email
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('email', email);
  }

  @override
  Future<void> changeEmail(String currentPassword, String email) async {
    final user = FirebaseAuth.instance.currentUser;
    final credential = EmailAuthProvider.credential(email: user!.email!, password: currentPassword);
    await user.reauthenticateWithCredential(credential);
    await user.updateEmail(email);
    await updateEmail(email);
  }
}
