import 'package:coffee_review/components/coffees.dart';
import 'package:coffee_review/components/scaffold.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth.dart';
import '../utils/forms.dart';

enum LoginAction {
  signup,
  login,
}

class Login extends ConsumerStatefulWidget {
  const Login({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginState();
}

class _LoginState extends ConsumerState<Login> {
  final _formKey = GlobalKey<FormState>();
  final usernameField = TextEditingController();
  final passwordField = TextEditingController();
  final signupButtonName = 'Signup';
  final loginButtonName = 'Login';

  String usernameError = '';
  String passwordError = '';
  LoginAction currentLoginAction = LoginAction.login;

  @override
  Widget build(BuildContext context) {
    var inputForm = Padding(
        padding: const EdgeInsets.all(10),
        child: Form(
          key: _formKey,
          child: AutofillGroup(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                  padding: const EdgeInsets.all(10),
                  child: buildFormFieldText(
                      controller: usernameField,
                      autofillHints: [AutofillHints.username],
                      label: 'Email',
                      hint: 'name@provider.com',
                      validationText: () => usernameError,
                      emptyValidationText: 'Email is required.',
                      textInputType: TextInputType.emailAddress,
                      isInvalid: (_) => usernameError.isNotEmpty)),
              Padding(
                  padding: const EdgeInsets.all(10),
                  child: buildFormFieldText(
                      controller: passwordField,
                      autofillHints: [AutofillHints.password],
                      label: 'Password',
                      hint: '***',
                      validationText: () => passwordError,
                      emptyValidationText: 'Password is required.',
                      textInputType: TextInputType.visiblePassword,
                      obscureText: true,
                      isInvalid: (_) => passwordError.isNotEmpty)),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: ElevatedButton(
                  onPressed: handleLoginAction,
                  child: Text(mapLoginActionToName(currentLoginAction)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: TextButton(
                  onPressed: handleSwitchLoginAction,
                  child: Text(
                      "Switch to ${mapLoginActionToName(currentLoginAction, reversed: true)}"),
                ),
              ),
            ],
          )),
        ));
    return ScaffoldBuilder(body: inputForm);
  }

  void handleSwitchLoginAction() {
    setState(() {
      switchCurrentLoginAction();
      if (kDebugMode) {
        print({'Updated login state', currentLoginAction});
      }
    });
  }

  void handleLoginAction() {
    final emailAddress = usernameField.value.text;
    final password = passwordField.value.text;
    clearLoginErrors();

    switch (currentLoginAction) {
      case LoginAction.signup:
        signup(emailAddress, password)
            .then(handleSignupSuccess, onError: handleSignupError);
      case LoginAction.login:
        login(emailAddress, password)
            .then(handleLoginSuccess, onError: handleLoginError);
    }
  }

  void navigateToHome() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Coffees()),
    );
  }

  void handleSignupError(e) {
    if (e is FirebaseAuthException) {
      if (e.code == 'weak-password') {
        passwordError = 'The password must be more than 6 characters.';
      } else if (e.code == 'email-already-in-use') {
        usernameError = 'The account already exists for that email.';
      } else {
        passwordError = 'Error signing up.';
      }
    } else {
      passwordError = 'Error handling sign up.';
    }
    runFormValidation();
  }

  void handleLoginError(e) {
    if (e is FirebaseAuthException) {
      if (e.code == 'user-not-found') {
        usernameError = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        passwordError = 'Wrong password provided for that user.';
      } else {
        passwordError = 'Error logging in.';
      }
    } else {
      passwordError = 'Error handling log in.';
    }
    runFormValidation();
  }

  void handleSignupSuccess(value) {
    if (kDebugMode) {
      print({'Created user ', value});
    }
    clearLoginErrors();
    navigateToHome();
  }

  void handleLoginSuccess(value) {
    if (kDebugMode) {
      print({'User logged in ', value});
    }
    clearLoginErrors();
    navigateToHome();
  }

  void clearLoginErrors() {
    usernameError = '';
    passwordError = '';
    runFormValidation();
  }

  void runFormValidation() {
    _formKey.currentState?.validate();
  }

  switchCurrentLoginAction() {
    currentLoginAction = reverseLoginAction(currentLoginAction);
  }

  String mapLoginActionToName(LoginAction loginAction,
      {bool reversed = false}) {
    return switch (reversed ? reverseLoginAction(loginAction) : loginAction) {
      LoginAction.signup => signupButtonName,
      LoginAction.login => loginButtonName,
    };
  }

  LoginAction reverseLoginAction(LoginAction loginAction) {
    return switch (loginAction) {
      LoginAction.signup => LoginAction.login,
      LoginAction.login => LoginAction.signup,
    };
  }
}
