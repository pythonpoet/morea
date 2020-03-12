import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

// generiert mit https://datenschutz-generator.de/
abstract class BaseDatenschutz {
  Future<void> moreaDatenschutzerklaerung(
      BuildContext context, String datenschutz);
}

class Datenschutz implements BaseDatenschutz {
  static Datenschutz _instance;

  factory Datenschutz() => _instance ??= new Datenschutz._();

  Datenschutz._();

  bool akzeptiert = false;
  bool expand = false;

  void expandpressed() {
    expand = !expand;
  }

  Future<void> moreaDatenschutzerklaerung(
      BuildContext context, String datenschutz) async {
    await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => Container(
              padding: EdgeInsets.all(10),
              child: new Card(
                  child: Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      flex: 7,
                      child: Text(
                        'Datenschutzerklährung',
                        style: new TextStyle(
                            fontSize: 24,
                            color: Color(0xff7a62ff),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: new Divider(),
                    ),
                    Expanded(
                        flex: 100,
                        child: Scrollbar(
                          child: new SingleChildScrollView(
                            controller: ScrollController(),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(
                                        height: 5,
                                      ),
                                    ],
                                  ),
                                ),
                                new Html(
                                  data: datenschutz,
                                )
                              ],
                            ),
                          ),
                        )),
                    Expanded(
                      flex: 1,
                      child: new Divider(),
                    ),
                    Expanded(
                      flex: 8,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: SizedBox(),
                          ),
                          Expanded(
                            flex: 3,
                            child: new FlatButton(
                                child: const Text('Ablehnen',
                                    style: TextStyle(color: Color(0xff7a62ff))),
                                onPressed: () {
                                  akzeptiert = false;
                                  Navigator.pop(context);
                                }),
                          ),
                          Expanded(
                            flex: 3,
                            child: new RaisedButton(
                                child: const Text(
                                  'Akzeptieren',
                                  style: TextStyle(color: Colors.white),
                                ),
                                color: Color(0xff7a62ff),
                                onPressed: () {
                                  akzeptiert = true;
                                  Navigator.pop(context);
                                }),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              )),
            ));
  }
}

