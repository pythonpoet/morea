import 'package:flutter/material.dart';
import 'package:morea/morealayout.dart';

class ChangeMitnehmen extends StatefulWidget {
  final List<String> mitnehmen;

  final Function speichern;

  ChangeMitnehmen(this.mitnehmen, this.speichern);

  @override
  State<StatefulWidget> createState() {
    return _ChangeMitnehmenState();
  }
}

class _ChangeMitnehmenState extends State<ChangeMitnehmen> {
  List<String> mitnehmen;
  List<TextEditingController> mitnehmenController =
      List<TextEditingController>();
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
    for(TextEditingController controller in mitnehmenController){
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
            List<String> neuMitnehmen = List<String>();
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
                                  child: RaisedButton.icon(
                                    onPressed: () {
                                      this.setState(() {
                                        mitnehmenController
                                            .add(TextEditingController());
                                      });
                                    },
                                    icon: Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    label: Text(
                                      "Element",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18),
                                    ),
                                    color: MoreaColors.violett,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5))),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(),
                                ),
                                Expanded(
                                  flex: 7,
                                  child: RaisedButton.icon(
                                      onPressed: () {
                                        this.setState(() {
                                          mitnehmenController.removeLast();
                                        });
                                      },
                                      icon: Icon(
                                        Icons.remove,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      label: Text(
                                        "Element",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18),
                                      ),
                                      color: MoreaColors.violett,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5)))),
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
      ));
    }
    return mitnehmenList;
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
