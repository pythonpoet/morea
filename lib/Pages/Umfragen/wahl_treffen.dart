import 'package:flutter/material.dart';
import 'package:morea/Pages/Umfragen/edit_options.dart';
import 'package:morea/Widgets/standart/buttons.dart';
import 'package:morea/Widgets/standart/form_fields.dart';
import 'package:morea/Widgets/standart/moreaTextStyle.dart';
import 'package:morea/morealayout.dart';
import 'package:morea/classes/umfrage_settings.dart';

class WahlTreffen extends StatefulWidget {
  @override
  _WahlTreffenState createState() => _WahlTreffenState();
}

class _WahlTreffenState extends State<WahlTreffen> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _ortController = TextEditingController();
  final TextEditingController _notizController = TextEditingController();
  final UmfrageSettings umfrageSettings = UmfrageSettings();
  List<Map<String, dynamic>> options = [];

  @override
  void initState() {
    super.initState();
    options.addAll([
      {
        'limit': 1,
        'controller':
            TextEditingController.fromValue(TextEditingValue(text: 'test1'))
      },
      {
        'limit': 1,
        'controller':
            TextEditingController.fromValue(TextEditingValue(text: 'test2'))
      },
      {
        'limit': 1,
        'controller':
            TextEditingController.fromValue(TextEditingValue(text: 'test3'))
      },
      {
        'limit': 1,
        'controller':
            TextEditingController.fromValue(TextEditingValue(text: 'test4'))
      }
    ]);
    print(options);
    umfrageSettings.hidden = false;
    umfrageSettings.maybe = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Neue Umfrage'),
      ),
      floatingActionButton: moreaFloatingActionbutton(route: null, icon: Icon(Icons.check)),
      body: Form(
        key: _form,
        child: MoreaBackgroundContainer(
          child: SingleChildScrollView(
            child: MoreaShadowContainer(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text('Titel', style: MoreaTextStyle.caption),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: MoreaSingleLineTextField(
                        keyboardType: TextInputType.text,
                        controller: _titleController,
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
                      padding: EdgeInsets.only(top: 20),
                      child: Row(
                        children: <Widget>[
                          Text(
                            'Optionen',
                            style: MoreaTextStyle.caption,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: moreaSmallIconButton(
                                'ANPASSEN',
                                () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) => EditOptions(
                                            this.options, this._saveOptions))),
                                Icon(
                                  Icons.edit,
                                  color: MoreaColors.violett,
                                  size: 10,
                                )),
                          )
                        ],
                      ),
                    ),
                    Container(
                      constraints: BoxConstraints(maxHeight: 50),
                      padding: EdgeInsets.only(top: 10),
                      child: ListView.builder(
                          physics: AlwaysScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Chip(
                                label: Text(options[index]['controller'].text),
                              ),
                            );
                          },
                          scrollDirection: Axis.horizontal,
                          itemCount: options.length),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 30),
                      child: Text(
                        'Optional',
                        style: MoreaTextStyle.subtitle,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                        'Ort',
                        style: MoreaTextStyle.caption,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: MoreaSingleLineTextField(
                        keyboardType: TextInputType.text,
                        validator: null,
                        controller: _ortController,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                        'Notiz',
                        style: MoreaTextStyle.caption,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: MoreaSingleLineTextField(
                        keyboardType: TextInputType.text,
                        validator: null,
                        controller: _notizController,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 30),
                      child: Text(
                        'Einstellungen',
                        style: MoreaTextStyle.subtitle,
                      ),
                    ),
                    SwitchListTile(
                      title: Text(
                        '\"Vielleicht\" aktivieren',
                        style: MoreaTextStyle.lable,
                      ),
                      value: umfrageSettings.maybe,
                      onChanged: (val) {
                        setState(() {
                          umfrageSettings.maybe = val;
                        });
                      },
                    ),
                    SwitchListTile(
                      title: Text(
                        'Versteckte Umfrage',
                        style: MoreaTextStyle.lable,
                      ),
                      subtitle: Text(
                        'Teilnehmer können Namen, Abstimmungen und Kommentare der anderen nicht sehen.',
                        style: MoreaTextStyle.subtitle,
                      ),
                      value: umfrageSettings.hidden,
                      onChanged: (val) {
                        setState(() {
                          umfrageSettings.hidden = val;
                        });
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _saveOptions(List<Map<String, dynamic>> options) {
    this.options = options;
  }
}
