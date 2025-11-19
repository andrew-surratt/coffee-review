import 'package:coffee_review/components/login.dart';
import 'package:coffee_review/components/scaffold.dart';
import 'package:coffee_review/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/forms.dart';

class UserProfile extends ConsumerStatefulWidget {
  const UserProfile({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UserProfile();
}

class _UserProfile extends ConsumerState<UserProfile> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController displayNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  bool isButtonDisabled = true;
  late void Function() displayNameListener;

  @override
  void initState() {
    setInitialProfileFields();
    super.initState();
  }

  @override
  void didUpdateWidget(UserProfile oldWidget) {
    cleanupProfileFields();
    setInitialProfileFields();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    cleanupProfileFields();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var inputForm = Padding(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text('Profile',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          ),
          buildForm(getFormFields(context)),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: FilledButton(
                onPressed: isButtonDisabled ? null : onUpdatePressed(context),
                child: const Text('Update'),
              )),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: FilledButton(
                onPressed: () {
                  setState(() {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => const Login()));
                  });
                },
                child: const Text('Logout'),
              )),
        ]));
    return ScaffoldBuilder(body: inputForm);
  }

  void setInitialProfileFields() {
    var user = getUser();
    var displayName = user?.displayName ?? '';
    displayNameController.text = displayName;
    displayNameListener = () {
      if (displayName != displayNameController.text) {
        setState(() {
          isButtonDisabled = false;
        });
      } else {
        setState(() {
          isButtonDisabled = true;
        });
      }
    };
    displayNameController.addListener(displayNameListener);
    emailController.text = user?.email ?? '';
  }

  void cleanupProfileFields() {
    displayNameController.removeListener(displayNameListener);
  }

  Form buildForm(List<Widget> formFields) {
    return Form(
      key: _formKey,
      child: Card(
          child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: formFields,
              ))),
    );
  }

  List<Widget> getFormFields(BuildContext context) {
    var theme = Theme.of(context);
    return [
      Padding(
          padding: const EdgeInsets.all(10),
          child: buildFormFieldText(
            controller: displayNameController,
            label: "Display Name",
            hint: 'First Last',
          )),
      Padding(
          padding: const EdgeInsets.all(10),
          child: buildFormFieldText(
            controller: emailController,
            label: "Email",
            hint: 'name@provider.com',
            readOnly: true,
            style: TextStyle(color: theme.disabledColor),
          )),
    ];
  }

  void Function() onUpdatePressed(BuildContext context) {
    return () {
      const snackBarSuccess = SnackBar(
        content: Text('Successfully updated user'),
      );
      const snackBarError = SnackBar(
        content: Text('Failed to update user'),
      );

      var name = displayNameController.text;
      if (name.isNotEmpty) {
        updateDisplayName(name).then((_) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(snackBarSuccess);
          }
          setState(() {
            isButtonDisabled = true;
            cleanupProfileFields();
            setInitialProfileFields();
          });
        }).catchError((e) {
          if (kDebugMode) {
            print({"Failed to update user: ", e});
          }
          if(context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(snackBarError);
          }
        });
      }
    };
  }
}
