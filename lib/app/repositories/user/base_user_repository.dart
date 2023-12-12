import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lestari_flutter/models/user_model.dart';

abstract class BaseUserRepository {
  Future<UserModel?> getUserById(String uid);
  Future<void> listenToCurrentUser(ValueNotifier<UserModel?> userModel);
  Future<void> updateProfile(String name, String currentImageUrl, File imageFile);
  Future<void> updateUser(UserModel userModel);
}