part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

class LoginWithPasswordEvent extends AuthEvent {
  final String email, password;

  const LoginWithPasswordEvent(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class RegisterWithPasswordEvent extends AuthEvent {
  final String email, password, displayName;

  const RegisterWithPasswordEvent(this.email, this.password, this.displayName);

  @override
  List<Object?> get props => [email, password];
}

class AuthWithGoogleEvent extends AuthEvent {
  final bool isLogin;

  const AuthWithGoogleEvent(this.isLogin);

  @override
  List<Object?> get props => [isLogin];
}
