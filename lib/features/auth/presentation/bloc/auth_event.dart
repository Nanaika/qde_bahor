abstract class AuthEvent {
  const AuthEvent();
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  const LoginEvent(this.email, this.password);
}

class RegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String name;
  const RegisterEvent(this.email, this.password, this.name);
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

class RefreshUserEvent extends AuthEvent {}
