import 'package:flutter/material.dart';
import 'package:morea/morealayout.dart';

class ChangeGrund extends StatefulWidget {
  final String grund;

  final Function speichern;

  ChangeGrund(this.grund, this.speichern);

  @override
  State<StatefulWidget> createState() {
    return _ChangeGrundState();
  }
}

class _ChangeGrundState extends State<ChangeGrund> {
  String grund;
  final _formKey = GlobalKey<FormState>();
  TextEditingController grundController = TextEditingController();

  @override
  void initState() {
    super.initState();
    this.grund = widget.grund;
    this.grundController.text = this.grund;
  }

  @override
  void dispose() {
    super.dispose();
    grundController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grund ändern'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: MoreaColors.violett,
        child: Icon(Icons.check),
        onPressed: () {
          if (saveAndSubmit()) {
            widget.speichern(this.grundController.text);
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
                            'Grund',
                            style: MoreaTextStyle.title,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0, bottom: 20),
                          child: TextFormField(
                            controller: grundController,
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
