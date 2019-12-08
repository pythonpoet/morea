import 'package:flutter/material.dart';
import 'package:morea/morealayout.dart';

class ChangeEmail extends StatefulWidget {
  final String email;
  final Function _changeEmail;

  ChangeEmail(this.email, this._changeEmail);

  @override
  _ChangeEmailState createState() => _ChangeEmailState();
}

class _ChangeEmailState extends State<ChangeEmail> {
  TextEditingController email = TextEditingController();
  TextEditingController nachname = TextEditingController();
  TextEditingController pfadiname = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    email.text = widget.email;
  }

  @override
  void dispose() {
    super.dispose();
    email.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Name'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        backgroundColor: MoreaColors.violett,
        onPressed: (){
          if(_validateAndSave()){
            widget._changeEmail(email.text);
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
                      'Name ändern',
                      style: MoreaTextStyle.title,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                        'E-Mail',
                        style: MoreaTextStyle.lable,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: TextFormField(
                        controller: email,
                        maxLines: 1,
                        keyboardType: TextInputType.text,
                        style: TextStyle(fontSize: 18),
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
