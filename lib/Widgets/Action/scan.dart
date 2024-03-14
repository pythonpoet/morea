import 'dart:async';
import 'package:flutter/material.dart';
import 'package:morea/Widgets/standart/dialog.dart';
import 'package:morea/Widgets/standart/info.dart';
import 'package:morea/services/utilities/morea_functions.dart';
import 'package:morea/services/utilities/qr_code.dart';
import 'package:rxdart/rxdart.dart';

Future<dynamic> makeLeiterWidget(
    BuildContext context, String userID, String groupID) {
  QrCode qrCode = new QrCode();
  StreamController stream = new BehaviorSubject();
  bool buttonPressed = false;
  return scanDialog(context, [
    Text(
      'Teilnehmer koppeln',
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
    ),
    SizedBox(
      height: 30,
    ),
    Text(
      'Scanne den Qr-Code eines Teilnehmers um ihn zum Leiter machen. ',
      style: TextStyle(fontSize: 20),
    ),
    SizedBox(
      height: 30,
    ),
    StreamBuilder(
      stream: stream.stream,
      builder: (BuildContext context, asFunction) {
        if (!buttonPressed)
          return Column(
            children: <Widget>[
              new ElevatedButton(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.camera_alt),
                    SizedBox(
                      width: 5,
                    ),
                    new Text('Scannen', style: new TextStyle(fontSize: 20))
                  ],
                ),
                onPressed: () async {
                  buttonPressed = true;
                  await qrCode.germanScanQR();
                  stream.add(666);
                  print(qrCode.germanError);
                  if (qrCode.germanError ==
                      'Um den Kopplungsvorgang mit deinem Kind abzuschliessen, scanne den Qr-Code, der im Profil deines Kindes ersichtlich ist.') {
                    print('making Leiter');
                    makeLeiter(userID, qrCode.qrResult!, groupID)
                        .then((onValue) {
                      stream.add("nicht dicht!");
                    });
                  } else
                    buttonPressed = false;
                },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Color(0xff7a62ff)),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                ),
              ),
              ElevatedButton(
                child:
                    new Text('Abbrechen', style: new TextStyle(fontSize: 20)),
                onPressed: () async =>
                    {stream.close(), Navigator.of(context).pop()},
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Color(0xff7a62ff)),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                ),
              ),
            ],
          );
        if (!asFunction.hasData)
          return Container(
            child: simpleMoreaLoadingIndicator(),
            width: 100,
          );
        if (asFunction.data is int)
          return simpleMoreaLoadingIndicator();
        else
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.check_circle, size: 70, color: Colors.green),
              Text(
                "Hinzugefügt",
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(
                height: 200,
              ),
              ElevatedButton(
                child:
                    new Text('Abbrechen', style: new TextStyle(fontSize: 20)),
                onPressed: () async =>
                    {stream.close(), Navigator.of(context).pop()},
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Color(0xff7a62ff)),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                ),
              ),
            ],
          );
      },
    ),
  ]);
}
