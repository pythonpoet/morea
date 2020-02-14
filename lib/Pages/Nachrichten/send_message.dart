import 'package:flutter/material.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/morea_firestore.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/morealayout.dart';

class SendMessages extends StatefulWidget {
  SendMessages({this.moreaFire, this.auth});

  final MoreaFirebase moreaFire;
  final Auth auth;

  @override
  State<StatefulWidget> createState() {
    return _SendMessagesState();
  }
}

class _SendMessagesState extends State<SendMessages> {
  MoreaFirebase moreaFire;
  String uid;
  bool loading = true;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  UniqueKey dropdownKey = UniqueKey();
  List<String> receivers = <String>[];
  TextEditingController titleController = TextEditingController();
  FocusNode titleFocus = FocusNode();
  TextEditingController inhaltController = TextEditingController();
  FocusNode inhaltFocus = FocusNode();
  TextEditingController vorschauController = TextEditingController();
  FocusNode vorschauFocus = FocusNode();

  bool biberCheckBox = false;
  bool woelfeCheckBox = false;
  bool meitliCheckBox = false;
  bool buebeCheckBox = false;

  @override
  void initState() {
    super.initState();
    moreaFire = widget.moreaFire;
    getUID();
  }

  void getUID() async{
    uid = await widget.auth.currentUser();
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    titleFocus.dispose();
    inhaltController.dispose();
    inhaltFocus.dispose();
    vorschauController.dispose();
    vorschauFocus.dispose();
  }

  _showDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Bitte Empfänger auswählen'),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (biberCheckBox ||
              woelfeCheckBox ||
              meitliCheckBox ||
              buebeCheckBox) {
            setState(() {
              if (_formKey.currentState.validate()) {
                Map<String, dynamic> data = {
                  'message': {
                    'title': titleController.text,
                    'body': inhaltController.text,
                    'sender': moreaFire.getPfandiName,
                    'read': List<String>(),
                    'receivers': receivers,
                  },
                  'receivers': receivers,
                  'snippet': vorschauController.text,
                  'title': titleController.text
                };
                moreaFire.uploadMessage(data);
                print('Successful: $data');
                Navigator.of(context).pop();
              }
            });
          } else {
            print('error');
            _showDialog(context);
          }
        },
        child: Icon(Icons.send),
        backgroundColor: MoreaColors.violett,
      ),
      appBar: AppBar(
        title: Text('Nachricht Senden'),
      ),
      body: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Empfänger',
                  style: MoreaTextStyle.lable,
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 15),
                ),
                CheckboxListTile(
                  value: biberCheckBox,
                  onChanged: (bool val) {
                    setState(() {
                      if (val) {
                        receivers.add(midatanamebiber);
                      } else {
                        receivers.remove(midatanamebiber);
                      }
                      biberCheckBox = val;
                    });
                  },
                  title: Text(
                    'Biber',
                    style: MoreaTextStyle.normal,
                  ),
                  controlAffinity: ListTileControlAffinity.platform,
                ),
                CheckboxListTile(
                  value: woelfeCheckBox,
                  onChanged: (bool val) {
                    setState(() {
                      if (val) {
                        receivers.add(midatanamewoelf);
                      } else {
                        receivers.remove(midatanamewoelf);
                      }
                      woelfeCheckBox = val;
                    });
                  },
                  title: Text(
                    'Wölfe',
                    style: MoreaTextStyle.normal,
                  ),
                  controlAffinity: ListTileControlAffinity.platform,
                ),
                CheckboxListTile(
                  value: meitliCheckBox,
                  onChanged: (bool val) {
                    setState(() {
                      if (val) {
                        receivers.add(midatanamemeitli);
                      } else {
                        receivers.remove(midatanamemeitli);
                      }
                      meitliCheckBox = val;
                    });
                  },
                  title: Text(
                    'Meitli',
                    style: MoreaTextStyle.normal,
                  ),
                  controlAffinity: ListTileControlAffinity.platform,
                ),
                CheckboxListTile(
                  value: buebeCheckBox,
                  onChanged: (bool val) {
                    setState(() {
                      if (val) {
                        receivers.add(midatanamebuebe);
                      } else {
                        receivers.remove(midatanamebuebe);
                      }
                      buebeCheckBox = val;
                    });
                  },
                  title: Text(
                    'Buebe',
                    style: MoreaTextStyle.normal,
                  ),
                  controlAffinity: ListTileControlAffinity.platform,
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 20),
                ),
                Text(
                  'Betreff',
                  style: MoreaTextStyle.lable,
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 15),
                ),
                TextFormField(
                  focusNode: titleFocus,
                  style: MoreaTextStyle.textField,
                  controller: titleController,
                  decoration: InputDecoration(
                    helperText: 'Bspw: Fama',
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (newValue) {
                    setState(() {
                      titleController.text = newValue;
                    });
                  },
                  onEditingComplete: () {
                    FocusScope.of(context).requestFocus(vorschauFocus);
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Bitte nicht leer lassen';
                    } else {
                      return null;
                    }
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 20),
                ),
                Text(
                  'Vorschau',
                  style: MoreaTextStyle.lable,
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 15),
                ),
                TextFormField(
                  keyboardType: TextInputType.text,
                  focusNode: vorschauFocus,
                  controller: vorschauController,
                  style: MoreaTextStyle.normal,
                  minLines: 2,
                  maxLines: 4,
                  decoration: InputDecoration(
                    helperText:
                        'Dieser Text wird in der Benachrichtigung angezeigt.',
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (newValue) {
                    setState(() {
                      vorschauController.text = newValue;
                    });
                  },
                  onEditingComplete: () {
                    FocusScope.of(context).requestFocus(inhaltFocus);
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Bitte nicht leer lassen';
                    } else {
                      return null;
                    }
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 20),
                ),
                Text(
                  'Inhalt',
                  style: MoreaTextStyle.lable,
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 15),
                ),
                TextFormField(
                  focusNode: inhaltFocus,
                  controller: inhaltController,
                  style: MoreaTextStyle.normal,
                  minLines: 5,
                  maxLines: 1000,
                  decoration: InputDecoration(
                    labelText: 'Nachricht',
                    alignLabelWithHint: true,
                    helperText:
                        'Dieser Text wird in der App beim Öffnen der Nachricht angezeigt.',
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (newValue) {
                    setState(() {
                      inhaltController.text = newValue;
                    });
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Bitte nicht leer lassen';
                    } else {
                      return null;
                    }
                  },
                ),
              ],
            ),
          )),
    );
  }
}
