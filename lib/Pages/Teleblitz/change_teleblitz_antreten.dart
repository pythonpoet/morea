import 'package:flutter/material.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:morea/Widgets/standart/buttons.dart';
import 'package:morea/Widgets/standart/moreaTextStyle.dart';
import 'package:morea/morealayout.dart';
import 'package:morea/services/utilities/moreaInputValidator.dart';

class ChangeAntreten extends StatefulWidget {
  final String antreten, mapAntreten;

  final Function speichern;

  ChangeAntreten(this.antreten, this.mapAntreten, this.speichern);

  @override
  State<StatefulWidget> createState() {
    return _ChangeAntretenState();
  }
}

class _ChangeAntretenState extends State<ChangeAntreten> {
  late String ortAntreten;
  late String zeitAntreten;
  late String urlMapAntreten;
  late String nameMapAntreten;
  final _formKey = GlobalKey<FormState>();
  TextEditingController ortAntretenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    var splitAntreten = widget.antreten.split(', ');
    this.ortAntreten = splitAntreten[1];
    this.zeitAntreten = splitAntreten[0].split(' ')[0];
    this.urlMapAntreten = widget.mapAntreten;
    this.nameMapAntreten = this.urlMapAntreten;
    ortAntretenController.text = ortAntreten;
  }

  @override
  void dispose() {
    ortAntretenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beginn ändern'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: MoreaColors.violett,
        child: Icon(Icons.check),
        onPressed: () {
          if (saveAndSubmit()) {
            widget.speichern(this.ortAntretenController.text, this.zeitAntreten,
                this.urlMapAntreten);
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
                            'Beginn',
                            style: MoreaTextStyle.title,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text(
                            'Uhrzeit',
                            style: MoreaTextStyle.caption,
                          ),
                        ),
                        TextButton(
                          child: Container(
                            constraints: BoxConstraints(
                                minWidth: viewportConstraints.maxWidth,
                                maxWidth: viewportConstraints.maxWidth),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                zeitAntreten + ' Uhr',
                                style: MoreaTextStyle.textField,
                              ),
                            ),
                          ),
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all<OutlinedBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      side: BorderSide(color: Colors.black45))),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.black),
                              padding: MaterialStateProperty.all<EdgeInsets>(
                                  EdgeInsets.only(
                                      top: 10, bottom: 10, left: 5, right: 5)),
                              overlayColor: MaterialStateProperty.resolveWith(
                                  (Set<MaterialState> states) {
                                if (states.contains(MaterialState.focused))
                                  return MoreaColors.violett;
                                return null;
                              })),
                          onPressed: () {
                            _selectTime(context);
                          },
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
                          child: TextFormField(
                            controller: ortAntretenController,
                            maxLines: 1,
                            keyboardType: TextInputType.text,
                            style: MoreaTextStyle.textField,
                            cursorColor: MoreaColors.violett,
                            decoration: InputDecoration(
                              errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red)),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: MoreaColors.violett)),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
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
                            style: MoreaTextStyle.caption,
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: moreaRaisedButton(this.nameMapAntreten, () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PlacePicker(
                                            apiKey:
                                                "AIzaSyBFvIWmgunjzx7l8TytZg4vPQ7Tgg2k6V0",
                                            initialPosition: LatLng(
                                                47.40548228527181,
                                                8.559394673386825),
                                            onPlacePicked: (result) {
                                              this.urlMapAntreten = result.url!;
                                              this.nameMapAntreten =
                                                  result.name!;
                                              Navigator.of(context).pop();
                                              setState(() {});
                                            },
                                            usePlaceDetailSearch: true,
                                            useCurrentLocation: false,
                                            onAutoCompleteFailed: (val) {
                                              print(val);
                                            },
                                          )));
                            })),
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
    String hour = zeitAntreten.split(':')[0];
    String minute = zeitAntreten.split(':')[1];
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: int.parse(hour), minute: int.parse(minute)),
    );
    if (picked != null) {
      setState(() {
        if (picked.minute.toString().length < 2 &&
            picked.hour.toString().length >= 2) {
          this.zeitAntreten =
              picked.hour.toString() + ":0" + picked.minute.toString();
        } else if (picked.hour.toString().length < 2 &&
            picked.minute.toString().length >= 2) {
          this.zeitAntreten =
              "0" + picked.hour.toString() + ":" + picked.minute.toString();
        } else if (picked.hour.toString().length < 2 &&
            picked.minute.toString().length < 2) {
          this.zeitAntreten = "0" +
              picked.hour.toString() +
              ":" +
              "0" +
              picked.minute.toString();
        } else {
          this.zeitAntreten =
              picked.hour.toString() + ":" + picked.minute.toString();
        }
      });
    }
  }

  bool saveAndSubmit() {
    final form = _formKey.currentState;
    if (form!.validate()) {
      if (MoreaInputValidator.url(this.urlMapAntreten)) {
        form.save();
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
              ),
              Padding(padding: EdgeInsets.only(right: 10)),
              Text(
                'Bitte Google Maps Ort wählen!',
                style: MoreaTextStyle.warningSnackbar,
              ),
            ],
          ),
          duration: Duration(seconds: 5),
          backgroundColor: Colors.red,
        ));
        return false;
      }
    } else {
      return false;
    }
  }
}
