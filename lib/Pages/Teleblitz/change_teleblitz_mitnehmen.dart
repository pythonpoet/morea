import 'package:flutter/material.dart';
import 'package:morea/Widgets/standart/buttons.dart';
import 'package:morea/Widgets/standart/moreaTextStyle.dart';
import 'package:morea/morealayout.dart';

class ChangeMitnehmen extends StatefulWidget {
  final List<dynamic> mitnehmen;

  final Function speichern;

  ChangeMitnehmen(this.mitnehmen, this.speichern);

  @override
  State<StatefulWidget> createState() {
    return _ChangeMitnehmenState();
  }
}

class _ChangeMitnehmenState extends State<ChangeMitnehmen> {
  late List<dynamic> mitnehmen;
  List<TextEditingController> mitnehmenController = <TextEditingController>[];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    this.mitnehmen = widget.mitnehmen;
    for (String u in this.mitnehmen) {
      mitnehmenController.add(TextEditingController(text: u));
    }
  }

  @override
  void dispose() {
    for (TextEditingController controller in mitnehmenController) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mitnehmen ändern'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: MoreaColors.violett,
        child: Icon(Icons.check),
        onPressed: () {
          if (saveAndSubmit()) {
            List<String> neuMitnehmen = <String>[];
            for (TextEditingController u in mitnehmenController) {
              neuMitnehmen.add(u.text);
            }
            widget.speichern(neuMitnehmen);
            Navigator.of(context).pop();
          }
        },
      ),
      body: LayoutBuilder(
        builder: (context, viewportConstraints) {
          return MoreaBackgroundContainer(
            constraints:
                BoxConstraints(maxHeight: viewportConstraints.maxHeight),
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
                            'Mitnehmen',
                            style: MoreaTextStyle.title,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Column(
                            children: buildMitnehmen(),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10, bottom: 20),
                          child: FractionallySizedBox(
                            widthFactor: 1,
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 7,
                                  child: moreaFlatIconButton(
                                      'ELEMENT',
                                      this.addElement,
                                      Icon(
                                        Icons.add,
                                        size: 15,
                                        color: MoreaColors.violett,
                                      )),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(),
                                ),
                                Expanded(
                                  flex: 7,
                                  child: moreaFlatIconButton(
                                      'ELEMENT',
                                      this.removeElement,
                                      Icon(
                                        Icons.remove,
                                        size: 14,
                                        color: MoreaColors.violett,
                                      )),
                                ),
                              ],
                            ),
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

  List<Widget> buildMitnehmen() {
    List<Widget> mitnehmenList = [];
    for (var u in mitnehmenController) {
      mitnehmenList.add(Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: TextFormField(
          controller: u,
          maxLines: 1,
          keyboardType: TextInputType.text,
          style: MoreaTextStyle.textField,
          cursorColor: MoreaColors.violett,
          decoration: InputDecoration(
            errorBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: MoreaColors.violett)),
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Bitte nicht leer lassen';
            } else {
              return null;
            }
          },
        ),
      ));
    }
    return mitnehmenList;
  }

  void addElement() {
    this.setState(() {
      mitnehmenController.add(TextEditingController());
    });
  }

  void removeElement() {
    this.setState(() {
      mitnehmenController.removeLast();
    });
  }

  bool saveAndSubmit() {
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }
}
