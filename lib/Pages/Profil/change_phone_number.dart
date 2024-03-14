import 'package:flutter/material.dart';
import 'package:morea/Widgets/standart/moreaTextStyle.dart';
import 'package:morea/morealayout.dart';
import 'package:morea/services/utilities/moreaInputValidator.dart';

class ChangePhoneNumber extends StatefulWidget {
  final String phoneNumber;
  final Function _changePhoneNumber;

  ChangePhoneNumber(this.phoneNumber, this._changePhoneNumber);

  @override
  _ChangePhoneNumberState createState() => _ChangePhoneNumberState();
}

class _ChangePhoneNumberState extends State<ChangePhoneNumber> {
  TextEditingController phoneNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    phoneNumberController.text = widget.phoneNumber;
  }

  @override
  void dispose() {
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Handynummer'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        backgroundColor: MoreaColors.violett,
        onPressed: () {
          if (_validateAndSave()) {
            widget._changePhoneNumber(phoneNumberController.text);
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
                      'Handynummer ändern',
                      style: MoreaTextStyle.title,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                        'Handynummer',
                        style: MoreaTextStyle.caption,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: TextFormField(
                        controller: phoneNumberController,
                        maxLines: 1,
                        keyboardType: TextInputType.phone,
                        style: MoreaTextStyle.textField,
                        cursorColor: MoreaColors.violett,
                        decoration: InputDecoration(
                          helperText: 'Format "+4179xxxxxxx" oder "004179xxxxxxx"',
                          errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: MoreaColors.violett)),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Bitte nicht leer lassen';
                          } else if (!MoreaInputValidator.phoneNumber(value)) {
                            return 'Bitte gültige Telefonnummer wählen';
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
    if (form!.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }
}
