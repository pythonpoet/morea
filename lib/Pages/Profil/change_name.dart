import 'package:flutter/material.dart';
import 'package:morea/morealayout.dart';

class ChangeName extends StatefulWidget {
  final String vorname, nachname, pfadiname;

  ChangeName(this.vorname, this.nachname, this.pfadiname);

  @override
  _ChangeNameState createState() => _ChangeNameState();
}

class _ChangeNameState extends State<ChangeName> {
  TextEditingController vorname = TextEditingController();
  TextEditingController nachname = TextEditingController();
  TextEditingController pfadiname = TextEditingController();

  @override
  void initState() {
    super.initState();
    vorname.text = widget.vorname;
    nachname.text = widget.nachname;
    pfadiname.text = widget.pfadiname;
  }

  @override
  void dispose() {
    super.dispose();
    vorname.dispose();
    nachname.dispose();
    pfadiname.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Name'),
      ),
      body: MoreaBackgroundContainer(
        child: SingleChildScrollView(
          child: MoreaShadowContainer(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Name ändern',
                    style: MoreaTextStyle.title,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text(
                      'Vorname',
                      style: MoreaTextStyle.lable,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: TextFormField(
                      controller: vorname,
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
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text(
                      'Nachname',
                      style: MoreaTextStyle.lable,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: TextFormField(
                      controller: nachname,
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
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text(
                      'Pfadiname',
                      style: MoreaTextStyle.lable,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: TextFormField(
                      controller: pfadiname,
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
  }
}
