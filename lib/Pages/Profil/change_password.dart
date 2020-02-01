import 'package:flutter/material.dart';
import 'package:morea/morealayout.dart';

class ChangePassword extends StatefulWidget {
  final Function _changePassword;

  ChangePassword(this._changePassword);

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController verifyPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    passwordController.dispose();
    verifyPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Passwort'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        backgroundColor: MoreaColors.violett,
        onPressed: () {
          if (_validateAndSave() &&
              passwordController.text == verifyPasswordController.text) {
            widget._changePassword(passwordController.text);
            Navigator.of(context).pop();
          }
        },
      ),
      body: Form(
        key: _formKey,
        child: MoreaBackgroundContainer(
          child: SingleChildScrollView(
            child: MoreaShadowContainer(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Passwort ändern',
                      style: MoreaTextStyle.title,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                        'Neues Passwort',
                        style: MoreaTextStyle.lable,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        maxLines: 1,
                        keyboardType: TextInputType.visiblePassword,
                        style: MoreaTextStyle.textField,
                        cursorColor: MoreaColors.violett,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Bitte nicht leer lassen';
                          } else {
                            return null;
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: TextFormField(
                        controller: verifyPasswordController,
                        obscureText: true,
                        maxLines: 1,
                        keyboardType: TextInputType.visiblePassword,
                        style: MoreaTextStyle.textField,
                        cursorColor: MoreaColors.violett,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Bitte nicht leer lassen';
                          } else if (value != passwordController.text) {
                            return 'Die Passwörter stimmen nicht überein';
                          } else {
                            return null;
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }
}
