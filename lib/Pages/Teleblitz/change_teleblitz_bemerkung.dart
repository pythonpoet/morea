import 'package:flutter/material.dart';
import 'package:morea/morealayout.dart';

class ChangeBemerkung extends StatefulWidget {
  final String bemerkung;

  final Function speichern;

  ChangeBemerkung(this.bemerkung, this.speichern);

  @override
  State<StatefulWidget> createState() {
    return _ChangeBemerkungState();
  }
}

class _ChangeBemerkungState extends State<ChangeBemerkung> {
  String bemerkung;
  final _formKey = GlobalKey<FormState>();
  TextEditingController bemerkungController = TextEditingController();

  @override
  void initState() {
    super.initState();
    this.bemerkung = widget.bemerkung;
    this.bemerkungController.text = this.bemerkung;
  }

  @override
  void dispose() {
    super.dispose();
    bemerkungController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bemerkung ändern'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: MoreaColors.violett,
        child: Icon(Icons.check),
        onPressed: (){
          if (saveAndSubmit()) {
            widget.speichern(this.bemerkungController.text);
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
                            'Bemerkung',
                            style: MoreaTextStyle.title,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0, bottom: 20),
                          child: TextFormField(
                            controller: bemerkungController,
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
          );
        },
      ),
    );
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
