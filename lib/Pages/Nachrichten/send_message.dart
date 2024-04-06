import 'package:flutter/material.dart';
import 'package:morea/Widgets/standart/moreaTextStyle.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/crud.dart';
import 'package:morea/services/morea_firestore.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/morealayout.dart';

class SendMessages extends StatefulWidget {
  SendMessages(
      {required this.moreaFire,
      required this.auth,
      required this.crudMedthods});

  final MoreaFirebase moreaFire;
  final Auth auth;
  final CrudMedthods crudMedthods;

  @override
  State<StatefulWidget> createState() {
    return _SendMessagesState();
  }
}

class _SendMessagesState extends State<SendMessages> {
  late MoreaFirebase moreaFire;
  late CrudMedthods crudMedthods;
  late String uid;
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
  List<Map<String, dynamic>> subgroups = <Map<String, dynamic>>[];
  bool initDone = false;

  Map<String, bool> groupCheckbox = Map<String, bool>();

  @override
  void initState() {
    super.initState();
    moreaFire = widget.moreaFire;
    this.crudMedthods = widget.crudMedthods;
    getUID();
    initSubgroups();
  }

  void initSubgroups() async {
    Map<String, dynamic> data =
        (await this.crudMedthods.getDocument(pathGroups, moreaGroupID)).data()!
            as Map<String, dynamic>;
    data[groupMapGroupOption][groupMapGroupLowerClass]
        .forEach((key, value) => this.subgroups.add(value));
    this.groupCheckboxinit(this.subgroups);
    this.initDone = true;
    setState(() {});
  }

  void groupCheckboxinit(List<Map<String, dynamic>> subgroups) {
    for (Map<String, dynamic> groupMap in subgroups) {
      this.groupCheckbox[groupMap['groupID']] = false;
    }
  }

  void getUID() async {
    uid = await widget.auth.currentUser()!;
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
    if (!this.initDone) {
      return Container();
    } else {
      return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (groupCheckbox.containsValue(true)) {
              setState(() {
                if (_formKey.currentState!.validate()) {
                  groupCheckbox.forEach((key, value) {
                    if (value) {
                      this.receivers.add(key);
                    }
                  });
                  Map<String, dynamic> data = {
                    'message': {
                      'title': titleController.text,
                      'body': inhaltController.text,
                      'sender': moreaFire.getPfandiName,
                      'read': <String>[],
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
                  ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: subgroups.map((Map<dynamic, dynamic> group) {
                        return CheckboxListTile(
                          title: Text(
                            group[groupMapgroupNickName],
                            style: MoreaTextStyle.normal,
                          ),
                          value: groupCheckbox[group["groupID"]],
                          onChanged: (bool? value) {
                            setState(() {
                              groupCheckbox[group["groupID"]] = value!;
                            });
                          },
                        );
                      }).toList()),
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
                        titleController.text = newValue!;
                      });
                    },
                    onEditingComplete: () {
                      FocusScope.of(context).requestFocus(vorschauFocus);
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
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
                        vorschauController.text = newValue!;
                      });
                    },
                    onEditingComplete: () {
                      FocusScope.of(context).requestFocus(inhaltFocus);
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
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
                        inhaltController.text = newValue!;
                      });
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Bitte nicht leer lassen';
                      } else {
                        return null;
                      }
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 60),
                  )
                ],
              ),
            )),
      );
    }
  }
}
