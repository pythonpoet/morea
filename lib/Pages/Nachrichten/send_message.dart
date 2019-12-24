import 'package:flutter/material.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/morea_firestore.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/morealayout.dart';

class SendMessages extends StatefulWidget {
  SendMessages({this.moreaFire});

  final MoreaFirebase moreaFire;

  @override
  State<StatefulWidget> createState() {
    return _SendMessagesState();
  }
}

class _SendMessagesState extends State<SendMessages> {
  MoreaFirebase moreaFire;
  Auth auth = Auth();
  String uid;
  var userInfo;
  bool loading = true;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  UniqueKey dropdownKey = UniqueKey();
  List<String> receiver = <String>[];
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
  bool pioCheckBox = false;

  @override
  void initState() {
    super.initState();
    _getUserInformation();
    moreaFire = widget.moreaFire;
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
              buebeCheckBox ||
              pioCheckBox) {
            setState(() {
              if (_formKey.currentState.validate()) {
                Map<String, dynamic> data = {
                  'body': inhaltController.text,
                  'read': List<String>(),
                  'sender': userInfo['Pfadinamen'],
                  'snippet': vorschauController.text,
                  'title': titleController.text
                };
                for (String i in receiver) {
                  moreaFire.uploadMessage(i, data);
                }
                print('Successful');
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 15),
                ),
                CheckboxListTile(
                  value: biberCheckBox,
                  onChanged: (bool val) {
                    setState(() {
                      if (val) {
                        receiver.add(midatanamebiber);
                      } else {
                        receiver.remove(midatanamebiber);
                      }
                      biberCheckBox = val;
                    });
                  },
                  title: Text(
                    'Biber',
                    style: TextStyle(fontSize: 20),
                  ),
                  controlAffinity: ListTileControlAffinity.platform,
                ),
                CheckboxListTile(
                  value: woelfeCheckBox,
                  onChanged: (bool val) {
                    setState(() {
                      if (val) {
                        receiver.add(midatanamewoelf);
                      } else {
                        receiver.remove(midatanamewoelf);
                      }
                      woelfeCheckBox = val;
                    });
                  },
                  title: Text(
                    'Wölfe',
                    style: TextStyle(fontSize: 20),
                  ),
                  controlAffinity: ListTileControlAffinity.platform,
                ),
                CheckboxListTile(
                  value: meitliCheckBox,
                  onChanged: (bool val) {
                    setState(() {
                      if (val) {
                        receiver.add(midatanamemeitli);
                      } else {
                        receiver.remove(midatanamemeitli);
                      }
                      meitliCheckBox = val;
                    });
                  },
                  title: Text(
                    'Meitli',
                    style: TextStyle(fontSize: 20),
                  ),
                  controlAffinity: ListTileControlAffinity.platform,
                ),
                CheckboxListTile(
                  value: buebeCheckBox,
                  onChanged: (bool val) {
                    setState(() {
                      if (val) {
                        receiver.add(midatanamebuebe);
                      } else {
                        receiver.remove(midatanamebuebe);
                      }
                      buebeCheckBox = val;
                    });
                  },
                  title: Text(
                    'Buebe',
                    style: TextStyle(fontSize: 20),
                  ),
                  controlAffinity: ListTileControlAffinity.platform,
                ),
                CheckboxListTile(
                  value: pioCheckBox,
                  onChanged: (bool val) {
                    setState(() {
                      if (val) {
                        receiver.add('Pios');
                      } else {
                        receiver.remove('Pios');
                      }
                      pioCheckBox = val;
                    });
                  },
                  title: Text(
                    'Pios',
                    style: TextStyle(fontSize: 20),
                  ),
                  controlAffinity: ListTileControlAffinity.platform,
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 20),
                ),
                TextFormField(
                  focusNode: titleFocus,
                  style: TextStyle(fontSize: 16),
                  controller: titleController,
                  decoration: InputDecoration(
                    helperText: 'Bspw: Fama',
                    border: OutlineInputBorder(),
                    labelText: 'Betreff',
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 15),
                ),
                TextFormField(
                  keyboardType: TextInputType.text,
                  focusNode: vorschauFocus,
                  controller: vorschauController,
                  style: TextStyle(fontSize: 20),
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 15),
                ),
                TextFormField(
                  focusNode: inhaltFocus,
                  controller: inhaltController,
                  style: TextStyle(fontSize: 20),
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

  void _getUserInformation() async {
    this.uid = await auth.currentUser();
    var userInfo = await moreaFire.getUserInformation(this.uid);
    this.userInfo = userInfo.data;
    print(uid);
    print(this.userInfo);
  }
}
