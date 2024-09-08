import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:morea/Widgets/Login/register.dart';
import 'package:morea/Widgets/standart/buttons.dart';
import 'package:morea/Widgets/standart/info.dart';
import 'package:morea/Widgets/standart/restartWidget.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/morealayout.dart';
import 'package:morea/services/mailchimp_api_manager.dart';

import 'package:morea/services/morea_firestore.dart';
import 'package:morea/services/crud.dart';
import 'package:morea/services/user.dart';
import 'package:morea/services/utilities/child_parent_pend.dart';
import 'package:morea/services/utilities/qr_code.dart';

import 'package:rxdart/rxdart.dart';

abstract class BaseMergeChildParent {
  Widget childShowQrCode(Map userMap, BuildContext context,
      Function childaktuallisieren, Function(String) deleteRequest);

  void parentReadsQrCode(Map<String, dynamic> userMap,
      Function parentaktuallisieren, BuildContext context, Function signOut);
}

class MergeChildParent extends BaseMergeChildParent {
  QrCode qrCode = new QrCode();
  late MoreaFirebase moreafire;
  late CrudMedthods crud0;
  late ChildParendPend childParendPend;
  late User moreaUser;
  late Register register;
  bool parentReaderror = false, allowScanner = true;
  final formKey = new GlobalKey<FormState>();
  StreamController<bool> streamRegisterStatus = new BehaviorSubject();
  bool loading = false;
  Widget widget = new Container();
  MailChimpAPIManager mailChimpAPIManager = MailChimpAPIManager();

  MergeChildParent(CrudMedthods crudMedthods, MoreaFirebase moreaFirebase) {
    this.moreafire = moreaFirebase;

    this.crud0 = crudMedthods;
    this.childParendPend =
        new ChildParendPend(crud0: crud0, moreaFirebase: moreafire);
    moreaUser = User(crud0);
    register = Register(
        moreaUser: moreaUser,
        docSnapAbteilung: crud0.getDocument(pathGroups, moreaGroupID));
  }

  Widget registernewChild(Map<String, dynamic> parentData, BuildContext context,
      Function setProfileState, Function newKidakt, Function signOut) {
    return new Container(
        color: Colors.black.withOpacity(0.7),
        padding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
        child: new Card(
          child: new Container(
            padding: EdgeInsets.all(10),
            child: new Column(
              children: <Widget>[
                Flexible(
                  flex: 1,
                  child: Text(
                    'Neues Kind registrieren',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                Flexible(
                  flex: 7,
                  child: new Form(
                      key: formKey,
                      child: buildRegisterTeilnehmer(context, parentData,
                          setProfileState, newKidakt, signOut)),
                ),
              ],
            ),
          ),
        ));
  }

  Widget upgradeChild(BuildContext context, Function upgradeKid,
      Map<String, dynamic> childToUpgradeMap, Function signOut) {
    return Container(
        color: Colors.black.withOpacity(0.7),
        padding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
        child: new Card(
          child: new Container(
            padding: EdgeInsets.all(20),
            child: new Column(
              children: <Widget>[
                Flexible(
                  flex: 1,
                  child: Text(
                    'Account erstellen',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                Flexible(
                  flex: 7,
                  child: new Form(
                      key: formKey,
                      child: buildUpgradeKid(
                          context, upgradeKid, childToUpgradeMap, signOut)),
                ),
              ],
            ),
          ),
        ));
  }

  Widget childShowQrCode(Map userMap, BuildContext context,
      Function childaktuallisieren, Function(String) deleteRequest) {
    Future<String> qrCodeString = childParendPend
        .childGenerateRequestString(Map<String, dynamic>.from(userMap));
    return new Container(
      color: Colors.black.withOpacity(0.7),
      padding: EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 40),
      child: Card(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              Text(
                'Eltern/Erziehungsberechtigte koppeln',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                  'Um die Kopplung abzuschliessen, muss ein Elternteil/Erziehungsberechtigte disen Code Scannen'),
              SizedBox(
                height: 30,
              ),
              FutureBuilder(
                future: qrCodeString,
                builder: (BuildContext context, snap) {
                  if (snap.hasData)
                    return qrCode.generate(snap.data!);
                  else
                    return Container(
                      child: Center(child: simpleMoreaLoadingIndicator()),
                      height: 100,
                      width: 140,
                    );
                },
              ),
              Expanded(
                flex: 2,
                child: Container(
                  height: 80,
                ),
              ),
              Expanded(
                flex: 2,
                child: new ElevatedButton(
                  child:
                      new Text('Abbrechen', style: new TextStyle(fontSize: 20)),
                  onPressed: () async => {
                    childaktuallisieren(),
                    deleteRequest(await qrCodeString)
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
              )
            ],
          ),
        ),
      ),
    );
  }

  void parentReadsQrCode(
      Map<String, dynamic> userMap,
      Function parentaktuallisieren,
      BuildContext context,
      Function signOut) async {
    await qrCode.germanScanQR();
    if (qrCode.germanError ==
        'Um den Kopplungsvorgang mit deinem Kind abzuschliessen, scanne den Qr-Code, der im Profil deines Kindes ersichtlich ist.') {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Kind wird verbunden...'),
              content: Center(
                child: simpleMoreaLoadingIndicator(),
              ),
            );
          });
      await childParendPend.parentSendsRequestString(qrCode.qrResult!, userMap);
      DocumentSnapshot userSnap = await moreafire.firestore
          .collection(pathUser)
          .doc(userMap[userMapUID])
          .get();
      List<String> groupIDs = <String>[];
      print(userSnap.data().toString());
      (userSnap.data() as Map<String, dynamic>)[userMapKinder]
          .forEach((key, value) async {
        DocumentSnapshot childSnap =
            await moreafire.firestore.collection(pathUser).doc(key).get();
        groupIDs.add(childSnap[userMapGroupIDs][0]);
      });
      mailChimpAPIManager.updateUserInfo(
          userMap[userMapEmail],
          userMap[userMapVorName],
          userMap[userMapNachName],
          userMap[userMapGeschlecht],
          groupIDs,
          moreafire);
      Navigator.of(context).pop();
      allowScanner = false;
      parentReaderror = false;
      parentaktuallisieren();
    } else {
      parentReaderror = true;
      parentaktuallisieren();
    }
    showDialog(
            context: context,
            builder: (context) =>
                AlertDialog(content: Text('Dein Kind wurde hinzugefügt')))
        .then((onvalue) {
      RestartWidget.restartApp(context);
    });
  }

  Widget parentScannsQrCode(Map<String, dynamic> userMap,
      Function parentaktuallisieren, BuildContext context, Function signOut) {
    return new Container(
      color: Colors.black.withOpacity(0.7),
      padding: EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 40),
      child: Card(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              Text(
                'Eltern/Erziehungsberechtigte koppeln',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(
                height: 30,
              ),
              Text(qrCode.germanError!),
              SizedBox(
                height: 30,
              ),
              moreaRaisedIconButton(
                  'Scannen',
                  () => parentReadsQrCode(
                      userMap, parentaktuallisieren, context, signOut),
                  Icon(Icons.camera_alt)),
              SizedBox(
                height: 40,
              ),
              ElevatedButton(
                child:
                    new Text('Abbrechen', style: new TextStyle(fontSize: 20)),
                onPressed: () =>
                    {parentReaderror = false, parentaktuallisieren()},
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
          ),
        ),
      ),
    );
  }

  Widget buildRegisterTeilnehmer(
      BuildContext context,
      Map<String, dynamic> parentData,
      Function setProfileState,
      Function newKidakt,
      Function signOut) {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            register.parentRegisterNewChild(setProfileState),
            ElevatedButton(
              child:
                  new Text('Registrieren', style: new TextStyle(fontSize: 20)),
              onPressed: () => {
                registerChild(parentData, context, newKidakt).then((onValue) {
                  streamRegisterStatus.add(onValue);
                }),
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return StreamBuilder(
                          stream: streamRegisterStatus.stream,
                          builder: (BuildContext context, AsyncSnapshot snap) {
                            if (!snap.hasData)
                              return Container(
                                padding: EdgeInsets.only(
                                    left: 40, bottom: 80, right: 40, top: 80),
                                child: Card(
                                    child: Container(
                                  padding: EdgeInsets.only(
                                      left: 20, bottom: 40, right: 20, top: 40),
                                  child: Column(children: [
                                    Expanded(
                                      child: Text("Dein Kind wird hinzugefügt",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                      flex: 1,
                                    ),
                                    Expanded(
                                      flex: 9,
                                      child: Center(
                                        child: Container(
                                          child: Center(
                                              child:
                                                  simpleMoreaLoadingIndicator()),
                                          height: 100,
                                          width: 140,
                                        ),
                                      ),
                                    )
                                  ]),
                                )),
                                height: 100,
                                width: 140,
                              );
                            else if (snap.data) {
                              return Container(
                                padding: EdgeInsets.only(
                                    left: 40, bottom: 80, right: 40, top: 80),
                                child: Card(
                                    child: Container(
                                  padding: EdgeInsets.only(
                                      left: 20, bottom: 40, right: 20, top: 40),
                                  child: Column(children: [
                                    Expanded(
                                      child: Text("Dein Kind wurde hinzugefügt",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                      flex: 1,
                                    ),
                                    Expanded(
                                      flex: 9,
                                      child: Center(
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.check_circle,
                                                  size: 60,
                                                  color: Colors.green),
                                              Text(" Fertig",
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold))
                                            ]),
                                      ),
                                    ),
                                    Expanded(
                                        flex: 1,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: <Widget>[
                                            ElevatedButton(
                                              child: Text("Ok"),
                                              onPressed: () =>
                                                  RestartWidget.restartApp(
                                                      context),
                                              style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                              Color>(
                                                          MoreaColors.violett)),
                                            )
                                          ],
                                        ))
                                  ]),
                                )),
                                height: 100,
                                width: 140,
                              );
                            } else
                              return AlertDialog(
                                content: Text(
                                    'Etwas hat nicht funktioniert. Bitte versuche es erneut.'),
                                actions: <Widget>[
                                  ElevatedButton(
                                    child: Text('Ok'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  )
                                ],
                              );
                          });
                    }),
              },
              style: ButtonStyle(
                shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30))),
                backgroundColor:
                    MaterialStateProperty.all<Color>(Color(0xff7a62ff)),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
            ),
            ElevatedButton(
              child: new Text('Abbrechen', style: new TextStyle(fontSize: 20)),
              onPressed: () async => {
                newKidakt(),
              },
              style: ButtonStyle(
                shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30))),
                backgroundColor:
                    MaterialStateProperty.all<Color>(Color(0xff7a62ff)),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildUpgradeKid(BuildContext context, Function upgradeKid,
      Map<String, dynamic> childToUpgradeMap, Function signOut) {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            register.parentUpgradeChild(),
            ElevatedButton(
              child: new Text('Upgraden', style: new TextStyle(fontSize: 20)),
              onPressed: () => {
                upgradeKidExecution(context, upgradeKid, childToUpgradeMap)
                    .then((onValue) {
                  streamRegisterStatus.add(onValue);
                }),
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return StreamBuilder(
                          stream: streamRegisterStatus.stream,
                          builder: (BuildContext context, AsyncSnapshot snap) {
                            if (!snap.hasData)
                              return Container(
                                padding: EdgeInsets.only(
                                    left: 40, bottom: 80, right: 40, top: 80),
                                child: Card(
                                    child: Container(
                                  padding: EdgeInsets.only(
                                      left: 20, bottom: 40, right: 20, top: 40),
                                  child: Column(children: [
                                    Expanded(
                                      child: Text("Dein Kind wird hinzugefügt",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                      flex: 1,
                                    ),
                                    Expanded(
                                      flex: 9,
                                      child: Center(
                                        child: Container(
                                          child: Center(
                                              child:
                                                  simpleMoreaLoadingIndicator()),
                                          height: 100,
                                          width: 140,
                                        ),
                                      ),
                                    )
                                  ]),
                                )),
                                height: 100,
                                width: 140,
                              );
                            else if (snap.data) {
                              return Container(
                                padding: EdgeInsets.only(
                                    left: 40, bottom: 80, right: 40, top: 80),
                                child: Card(
                                    child: Container(
                                  padding: EdgeInsets.only(
                                      left: 20, bottom: 40, right: 20, top: 40),
                                  child: Column(children: [
                                    Expanded(
                                      child: Text(
                                          "Dein Kind wurde hinzugefügt.",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                      flex: 1,
                                    ),
                                    Expanded(
                                      child: Text(
                                          "Du musst dich nun wieder einloggen.",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                      flex: 1,
                                    ),
                                    Expanded(
                                      flex: 9,
                                      child: Center(
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.check_circle,
                                                  size: 60,
                                                  color: Colors.green),
                                              Text(" Fertig",
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold))
                                            ]),
                                      ),
                                    ),
                                    Expanded(
                                        flex: 1,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: <Widget>[
                                            ElevatedButton(
                                              child: Text("Ok"),
                                              onPressed: () {
                                                Navigator.of(context).popUntil(
                                                    ModalRoute.withName('/'));
                                                signOut();
                                              },
                                              style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                              Color>(
                                                          MoreaColors.violett)),
                                            )
                                          ],
                                        ))
                                  ]),
                                )),
                                height: 100,
                                width: 140,
                              );
                            } else
                              return AlertDialog(
                                content: Text(
                                    'Etwas hat nicht funktioniert. Bitte versuche es erneut.'),
                                actions: <Widget>[
                                  ElevatedButton(
                                    child: Text('Ok'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  )
                                ],
                              );
                          });
                    }),
              },
              style: ButtonStyle(
                shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30))),
                backgroundColor:
                    MaterialStateProperty.all<Color>(Color(0xff7a62ff)),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
            ),
            ElevatedButton(
              child: new Text('Abbrechen', style: new TextStyle(fontSize: 20)),
              onPressed: () async => {
                upgradeKid(Map<String, dynamic>()),
              },
              style: ButtonStyle(
                shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30))),
                backgroundColor:
                    MaterialStateProperty.all<Color>(Color(0xff7a62ff)),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }

  bool validateAndSave(context) {
    final form = formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  Future<bool> registerChild(Map<String, dynamic> parentData,
      BuildContext context, Function newKidakt) async {
    if (!validateAndSave(context))
      return false;
    else {
      var userDoc = await register.validateParentRegistersChild(context);
      if (!(userDoc is User))
        return false;
      else {
        //assume adress form Parent to child
        moreaUser.adresse = parentData[userMapAdresse];
        moreaUser.plz = parentData[userMapPLZ];
        moreaUser.ort = parentData[userMapOrt];
        moreaUser.elternMap = <String, dynamic>{
          moreafire.getUserMap[userMapUID]: moreafire.getVorName,
        };
        moreaUser.pos = "Teilnehmer";
        HttpsCallableResult results = await moreafire
            .uploadChildUserInformation(moreaUser.generateAndValitateUserMap());
        String childUID = results.data;
        Map<String, dynamic> userInfo = Map.of(moreafire.getUserMap);
        if (userInfo[userMapKinder] == null) {
          userInfo[userMapKinder] = {childUID: moreaUser.vorName};
        } else {
          userInfo[userMapKinder][childUID] = moreaUser.vorName;
        }
        await moreafire.updateUserInformation(
            moreafire.getUserMap[userMapUID], userInfo);
        if (moreaUser.pfadiName == null || moreaUser.pfadiName == '') {
          moreaUser.displayName = moreaUser.vorName;
        } else {
          moreaUser.displayName = moreaUser.pfadiName!;
        }
        print(moreaUser.groupIDs);
        print(childUID);
        print(moreaUser.displayName);
        print(moreaUser.generateAndValitateUserMap().toString());
        for (var groupID in moreaUser.groupIDs!) {
          await moreafire.groupPriviledgeTN(groupID, childUID,
              moreaUser.displayName!, moreaUser.generateAndValitateUserMap());
        }

        return true;
      }
    }
  }

  Future<bool> upgradeKidExecution(BuildContext context, Function upgradeKid,
      Map<String, dynamic> childToUpgradeMap) async {
    if (!validateAndSave(context)) {
      return false;
    } else {
      var userDoc = await register.validateUpgradeChild(context);
      if (!(userDoc is User))
        return false;
      else {
        childToUpgradeMap[userMapEmail] = moreaUser.email;
        childToUpgradeMap[userMapHandynummer] = moreaUser.handynummer;
        String oldChildUID = childToUpgradeMap[userMapChildUID];
        await moreafire.upgradeChild(
            childToUpgradeMap, oldChildUID, register.getPassword);
        return true;
      }
    }
  }
}
