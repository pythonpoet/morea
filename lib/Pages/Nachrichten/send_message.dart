import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:morea/services/morea_firestore.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/morealayout.dart';

class SendMessages extends StatefulWidget {
  SendMessages({this.firestore});
  final Firestore firestore;
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
  String dropdownValue;
  TextEditingController titleController = TextEditingController();
  FocusNode titleFocus = FocusNode();
  TextEditingController inhaltController = TextEditingController();
  FocusNode inhaltFocus = FocusNode();
  TextEditingController vorschauController = TextEditingController();
  FocusNode vorschauFocus = FocusNode();



  @override
  void initState() {
    super.initState();
    _getUserInformation();
    moreaFire = new MoreaFirebase(widget.firestore);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (_formKey.currentState.validate()) {
              Map<String, dynamic> data = {
                'body': inhaltController.text,
                'read': Map<String, bool>(),
                'sender': userInfo['Pfadinamen'],
                'snippet': vorschauController.text,
                'title': titleController.text
              };
              moreaFire.uploadMessage(dropdownValue, data);
              print('Successful');
              Navigator.of(context).pop();
            }
          });
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
                DropdownButtonFormField(
                  value: dropdownValue,
                  key: dropdownKey,
                  items: [
                    DropdownMenuItem(
                        child: Text('Bitte Empfänger wählen'), value: null),
                    DropdownMenuItem(child: Text('Biber'), value: 'Biber'),
                    DropdownMenuItem(
                        child: Text('Wombat'), value: 'Wombat (Wölfe)'),
                    DropdownMenuItem(
                        child: Text('Nahani'), value: 'NahaniMeitli'),
                    DropdownMenuItem(
                        child: Text('Drason'), value: 'DrasonBuebe'),
                  ],
                  onChanged: (newValue) {
                    FocusScope.of(context).requestFocus(titleFocus);
                    setState(() {
                      dropdownValue = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Bitte Empfänger wählen';
                    }
                    return null;
                  },
                  decoration: InputDecoration(border: OutlineInputBorder()),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 20),
                ),
                Text(
                  'Betreff',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 15),
                ),
                TextFormField(
                  focusNode: titleFocus,
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: 'Bspw: Fama',
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 15),
                ),
                TextFormField(
                  keyboardType: TextInputType.text,
                  focusNode: vorschauFocus,
                  controller: vorschauController,
                  minLines: 1,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Text',
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
                  minLines: 3,
                  maxLines: 1000,
                  decoration: InputDecoration(
                    labelText: 'Text',
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
