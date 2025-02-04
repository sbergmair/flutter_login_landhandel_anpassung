import 'package:flutter/material.dart';
import 'package:flutter_login/src/models/recover_data_two_fields.dart';

import '../../flutter_login.dart';

enum AuthMode { signup, login }

enum AuthType { provider, userPassword }

/// The callback triggered after login
/// The result is an error message, callback successes if message is null
typedef LoginCallback = Future<String?>? Function(LoginData);

/// The callback triggered after recover password with 2 fields
/// The result is an error message, callback successes if message is null
typedef RecoverTwoFieldsCallback = Future<String?>? Function(
    RecoverDataTwoFields);

/// The callback triggered after signup
/// The result is an error message, callback successes if message is null
typedef SignupCallback = Future<String?>? Function(SignupData);

/// The additional fields are provided as an `HashMap<String, String>`
/// The result is an error message, callback successes if message is null
typedef AdditionalFieldsCallback = Future<String?>? Function(
    Map<String, String>);

/// If the callback returns true, the additional data card is shown
typedef ProviderNeedsSignUpCallback = Future<bool> Function();

/// The result is an error message, callback successes if message is null
typedef ProviderAuthCallback = Future<String?>? Function();

/// The result is an error message, callback successes if message is null
typedef ProviderDirectCallback = Future? Function();

/// The result is an error message, callback successes if message is null
typedef RecoverCallback = Future<String?>? Function(String);

/// The result is an error message, callback successes if message is null
typedef ConfirmSignupCallback = Future<String?>? Function(String, LoginData);

/// The result is an error message, callback successes if message is null
typedef ConfirmRecoverCallback = Future<String?>? Function(String, LoginData);

class Auth with ChangeNotifier {
  Auth(
      {this.loginProviders = const [],
      this.onLogin,
      this.onRecoverWithTwoFields,
      this.onSignup,
      this.onRecoverPassword,
      this.onConfirmRecover,
      this.onConfirmSignup,
      this.onResendCode,
      String email = '',
      String password = '',
      String confirmPassword = '',
      AuthMode initialAuthMode = AuthMode.login,
      this.termsOfService = const []})
      : _userName = email,
        _password = password,
        _confirmPassword = confirmPassword,
        _mode = initialAuthMode,
        assert(onRecoverWithTwoFields == null || onRecoverPassword == null);

  final LoginCallback? onLogin;
  final RecoverTwoFieldsCallback? onRecoverWithTwoFields;
  final SignupCallback? onSignup;
  final RecoverCallback? onRecoverPassword;
  final List<LoginProvider> loginProviders;
  final ConfirmRecoverCallback? onConfirmRecover;
  final ConfirmSignupCallback? onConfirmSignup;
  final SignupCallback? onResendCode;
  final List<TermOfService> termsOfService;

  AuthType _authType = AuthType.userPassword;

  /// Used to decide if the login/signup comes from a provider or normal login
  AuthType get authType => _authType;
  set authType(AuthType authType) {
    _authType = authType;
    notifyListeners();
  }

  AuthMode _mode = AuthMode.login;
  AuthMode get mode => _mode;
  set mode(AuthMode value) {
    _mode = value;
    notifyListeners();
  }

  bool get isLogin => _mode == AuthMode.login;
  bool get isSignup => _mode == AuthMode.signup;
  int currentCardIndex = 0;

  AuthMode opposite() {
    return _mode == AuthMode.login ? AuthMode.signup : AuthMode.login;
  }

  AuthMode switchAuth() {
    if (mode == AuthMode.login) {
      mode = AuthMode.signup;
    } else if (mode == AuthMode.signup) {
      mode = AuthMode.login;
    }
    return mode;
  }

  String _userName = '';
  String get userName => _userName;
  set userName(String user) {
    _userName = user;
    notifyListeners();
  }

  String _secondRecoveryField = '';
  String get secondRecoveryField => _secondRecoveryField;
  set secondRecoveryField(String secondRecovery) {
    _secondRecoveryField = secondRecovery;
    notifyListeners();
  }

  String _password = '';
  String get password => _password;
  set password(String password) {
    _password = password;
    notifyListeners();
  }

  String _confirmPassword = '';
  String get confirmPassword => _confirmPassword;
  set confirmPassword(String confirmPassword) {
    _confirmPassword = confirmPassword;
    notifyListeners();
  }

  Map<String, String>? _additionalSignupData;
  Map<String, String>? get additionalSignupData => _additionalSignupData;
  set additionalSignupData(Map<String, String>? additionalSignupData) {
    _additionalSignupData = additionalSignupData;
    notifyListeners();
  }

  List<TermOfServiceResult> getTermsOfServiceResults() {
    return termsOfService
        .map((e) => TermOfServiceResult(term: e, accepted: e.getStatus()))
        .toList();
  }
}
