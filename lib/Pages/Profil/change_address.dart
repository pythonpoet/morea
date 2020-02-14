import 'package:flutter/material.dart';
import 'package:morea/morealayout.dart';

class ChangeAddress extends StatefulWidget {
  final String address, plz, ort;
  final Function _changeName;

  ChangeAddress(this.address, this.plz, this.ort, this._changeName);

  @override
  _ChangeAddressState createState() => _ChangeAddressState();
}

class _ChangeAddressState extends State<ChangeAddress> {
  TextEditingController addressController = TextEditingController();
  TextEditingController plzController = TextEditingController();
  TextEditingController ortController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    addressController.text = widget.address;
    plzController.text = widget.plz;
    ortController.text = widget.ort;
  }

  @override
  void dispose() {
    addressController.dispose();
    plzController.dispose();
    ortController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adresse'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        backgroundColor: MoreaColors.violett,
        onPressed: () {
          if (_validateAndSave()) {
            widget._changeName(
                addressController.text, plzController.text, ortController.text);
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
                      'Adresse ändern',
                      style: MoreaTextStyle.title,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                        'Adresse',
                        style: MoreaTextStyle.lable,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: TextFormField(
                        controller: addressController,
                        maxLines: 1,
                        keyboardType: TextInputType.text,
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
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                        'Postleitzahl',
                        style: MoreaTextStyle.lable,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: TextFormField(
                        controller: plzController,
                        maxLines: 1,
                        keyboardType: TextInputType.number,
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
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                        'Ort',
                        style: MoreaTextStyle.lable,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: TextFormField(
                        controller: ortController,
                        maxLines: 1,
                        keyboardType: TextInputType.text,
                        style: MoreaTextStyle.textField,
                        cursorColor: MoreaColors.violett,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
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
