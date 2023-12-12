import '../../../models/user_model.dart';

abstract class BaseAuthRepository {
  Future<void> loginWithPassword(String email, String password);
  Future<void> registerWithPassword(String email, String password, String displayName);
  Future<void> addUser(UserModel model);
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<void> changeEmail(String currentPassword, String email);
}