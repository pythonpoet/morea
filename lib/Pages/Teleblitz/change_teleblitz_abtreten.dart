import 'package:flutter/material.dart';
import 'package:morea/morealayout.dart';

class ChangeAbtreten extends StatefulWidget {
  final String antreten, mapAntreten;

  final Function speichern;

  ChangeAbtreten(this.antreten, this.mapAntreten, this.speichern);

  @override
  State<StatefulWidget> createState() {
    return _ChangeAbtretenState();
  }
}

class _ChangeAbtretenState extends State<ChangeAbtreten> {
  String ortAbtreten;
  String zeitAbtreten;
  String mapAbtreten;
  final _formKey = GlobalKey<FormState>();
  TextEditingController ortAbtretenController = TextEditingController();
  TextEditingController mapAbtretenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    var splitAntreten = widget.antreten.split(', ');
    this.ortAbtreten = splitAntreten[1];
    this.zeitAbtreten = splitAntreten[0].split(' ')[0];
    this.mapAbtreten = widget.mapAntreten;
    ortAbtretenController.text = ortAbtreten;
    mapAbtretenController.text = mapAbtreten;
  }

  @override
  void dispose() {
    ortAbtretenController.dispose();
    mapAbtretenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ende ändern'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: MoreaColors.violett,
        child: Icon(Icons.check),
        onPressed: () {
          if (saveAndSubmit()) {
            widget.speichern(this.ortAbtretenController.text, this.zeitAbtreten,
                this.mapAbtretenController.text);
            Navigator.of(context).pop();
          }
        },
      ),
      body: LayoutBuilder(
        builder: (context, viewportConstraints) {
          return MoreaBackgroundContainer(
            child: SingleChildScrollView(
              child: MoreaShadowContainer(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            'Schluss',
                            style: MoreaTextStyle.title,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text(
                            'Uhrzeit',
                            style: MoreaTextStyle.lable,
                          ),
                        ),
                        Container(
                          constraints: BoxConstraints(
                              minWidth: viewportConstraints.maxWidth),
                          alignment: Alignment.centerLeft,
                          margin:
                              EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                              border: Border.all(color: Colors.black45)),
                          child: FlatButton(
                            child: Text(
                              zeitAbtreten + ' Uhr',
                              style: MoreaTextStyle.textField,
                            ),
                            onPressed: () {
                              _selectTime(context);
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
                            controller: ortAbtretenController,
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
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Text(
                            'Google Maps',
                            style: MoreaTextStyle.lable,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: TextFormField(
                            controller: mapAbtretenController,
                            maxLines: 10,
                            minLines: 1,
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<Null> _selectTime(BuildContext context) async {
    String hour = zeitAbtreten.split(':')[0];
    String minute = zeitAbtreten.split(':')[1];
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: int.parse(hour), minute: int.parse(minute)),
    );
    if (picked != null) {
      setState(() {
        if (picked.minute.toString().length < 2 &&
            picked.hour.toString().length >= 2) {
          this.zeitAbtreten =
              picked.hour.toString() + ":0" + picked.minute.toString();
        } else if (picked.hour.toString().length < 2 &&
            picked.minute.toString().length >= 2) {
          this.zeitAbtreten =
              "0" + picked.hour.toString() + ":" + picked.minute.toString();
        } else if (picked.hour.toString().length < 2 &&
            picked.minute.toString().length < 2) {
          this.zeitAbtreten = "0" +
              picked.hour.toString() +
              ":" +
              "0" +
              picked.minute.toString();
        } else {
          this.zeitAbtreten =
              picked.hour.toString() + ":" + picked.minute.toString();
        }
      });
    }
  }

  bool saveAndSubmit() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }
}
