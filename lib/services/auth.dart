import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:intl/intl.dart';

abstract class BaseAuth{
  Future<String> signInWithEmailAndPassword(String email, String password);
  Future<String> createUserWithEmailAndPassword(String email, String password);
  Future<void> sendPasswordResetEmail(String email);
  Future<String> currentUser();
  Future<void> signOut();
  Future<void> createUserInformation(Map userInfo);
  Future<DocumentSnapshot> getUserInformation();
  Future uebunganmelden(Map anmeldedaten, String stufe, String _userUID);
  Future<DocumentSnapshot> getteleblitz(stufe);
  Future ubloadteleblitz(data,stufe);
  Future<bool> refreshteleblitz(stufe);
  Stream<QuerySnapshot> getAgenda(stufe);
  Future uploadtoAgenda(stufe,datum,data);
  Future deletedocument(String path, String document);
  Future<void> uploaddevtocken(stufe,token, userUID);
}

class Auth implements BaseAuth {

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  String getuebungsdatum(){
    var now = new DateTime.now();
    var formatter = new DateFormat('E');
    var formatter2 = new DateFormat('dd');
    String formatted = formatter.format(now);
    String formatted2 = formatter2.format(now);
    int date = int.parse(formatted2);
    switch (formatted) {
      case 'Sun':
        date += 6;
        break;
      case 'Mon':
        date += 5;
        break;
      case 'Tue':
        date += 4;
        break;
      case 'Wed':
        date += 3;
        break;
      case 'Thu':
        date += 2;
        break;
      case 'Fri':
        date += 1;
        break;
    }
        String akdate;
        akdate = date.toString();
        var fixdate = new DateFormat('yyyy-MM');
        String fixdateformatted = fixdate.format(now);
        return fixdateformatted + '-' + akdate;
  }
  String formatstring(String str){
    RegExp exp = new RegExp(r"(\w)");
        Iterable<Match> matches = exp.allMatches(str);
        List<String> charakters=['%'];
        for (Match m in matches) {
        charakters.add(m.group(0));
      }
      charakters.remove('%');
      return charakters.join().toString();
  }

  Future<String> signInWithEmailAndPassword(String email, String password)async{
    FirebaseUser user = await  _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    return user.uid;
  }

  Future<String> createUserWithEmailAndPassword(String email, String password) async {
    FirebaseUser user = await  _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    return user.uid;
  }
  Future<void> sendPasswordResetEmail(String email) async {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }
  Future<void> createUserInformation(Map userInfo) async {
    String userUID =  await currentUser();
    Firestore.instance.collection('user').document(userUID).setData(userInfo).catchError((e){
      print(e);
    });
  }
  Future uebunganmelden(Map anmeldedaten, String stufe, String _userUID) async {
    stufe = formatstring(stufe);
    String uebungsdatum = getuebungsdatum();
    Firestore.instance.collection('uebung').document(stufe).collection(uebungsdatum).document(_userUID).setData(anmeldedaten).catchError((e){
        print(e);
    });

  }

  Future ubloadteleblitz(data,stufe) async {
    stufe = formatstring(stufe);
    Map<String,String> akteleblitz= {
      'AktuellerTeleblitz' : data['datum'].toString().replaceAll('Samstag, ', ''),
      'Stufe': stufe
    };
    Firestore.instance.collection('Teleblitz').document('overview').collection(stufe).document(akteleblitz['AktuellerTeleblitz']).setData(data).catchError((e){
      print(e);
    });
     Firestore.instance.collection('Teleblitz').document('info').collection(stufe).document('AktuellerTeleblitz').setData(akteleblitz).catchError((e){
      print(e);
    });

  }
  Future<DocumentSnapshot> getteleblitz(stufe) async {
    
    if(stufe!= null){
    stufe = formatstring(stufe);
    DocumentSnapshot aktdat = await Firestore.instance.collection('Teleblitz').document('info').collection(stufe).document('AktuellerTeleblitz').get();
    return await Firestore.instance.collection('Teleblitz').document('overview').collection(stufe).document((aktdat.data['AktuellerTeleblitz']).toString()).get();
    }
  }


  Future<bool> refreshteleblitz(stufe) async {
    stufe = formatstring(stufe);
    DateTime letztesaktdat;
    var timenow = DateTime.now();
    DocumentSnapshot aktdat = await Firestore.instance.collection('Teleblitz').document('info').collection(stufe).document('Teleblitzaktualisiert').get();

    if(aktdat.data != null) {
       letztesaktdat = DateTime.parse(aktdat.data['Letztesaktualisierungsdatum']);
      //Aktuallisirungszeit festlegen
    }else{
        letztesaktdat = DateTime.parse('2019-03-07T13:30:16.388642');
    }
    if(timenow.difference(letztesaktdat).inMinutes> 1){
      Map<String,String> uploadakdat ={
        'Letztesaktualisierungsdatum': timenow.toIso8601String()
      };
      print('aktuelisiert');
      await Firestore.instance.collection('Teleblitz').document('info').collection(stufe).document('Teleblitzaktualisiert').setData(uploadakdat).catchError((e){
        print(e);
      });
      return true;
    }
    return false;
  }

  Future<DocumentSnapshot> getUserInformation() async {
    String userUID =  await currentUser();
    return await Firestore.instance.collection('user').document(userUID).get();
  }
  Future<DocumentSnapshot> getTNs(String stufe)async{
    stufe = formatstring(stufe);
    String uebungsdatum = getuebungsdatum();
    var document = Firestore.instance.document('user/${stufe}/${uebungsdatum}');
    document.get();
    print(document);

    return await Firestore.instance.collection(stufe).document(uebungsdatum).get();
  }

  Future<String> currentUser() async {
    FirebaseUser user = await  _firebaseAuth.currentUser();
    return user != null ? user.uid : null;
  }
  Future<String> userEmail() async {
    FirebaseUser user = await  _firebaseAuth.currentUser();
    return user != null ? user.email : null;
  }

  Future<void> signOut() async {
    return  _firebaseAuth.signOut();
  }
  Stream<QuerySnapshot> getAgenda(stufe)  {
    return Firestore.instance.collection('Stufen').document(stufe).collection('Agenda').snapshots();
  }

  Future uploadtoAgenda(stufe,datum,data)async{
    stufe = formatstring(stufe);
    await Firestore.instance.collection('Stufen').document(stufe).collection('Agenda').document(datum).setData(data).catchError((e){
      print(e);
    });
  }
  Future deletedocument(String path, String document) async{
    await Firestore.instance.collection(path).document(document).delete().catchError((e){
      print(e);
    });
  }
  Future<void> uploaddevtocken(stufe,token, userUID) async {
    stufe = formatstring(stufe);
    Map<String,String> tokendata = {
      'devtoken' : token,
      'UID' : userUID
    };
    await Firestore.instance.collection('Stufen').document(stufe).collection('Devices').document(token.toString()).setData(tokendata).catchError((e){
      print(e);
    });
  }
  
}
