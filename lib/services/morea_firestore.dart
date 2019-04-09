import 'Getteleblitz.dart';
import 'auth.dart';
import 'crud.dart';
import 'dwi_format.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BaseMoreaFirebase{
  Future<void> createUserInformation(Map userInfo);
  Future<void> updateUserInformation(String userUID, Map userInfo);
  Future<DocumentSnapshot> getUserInformation(String userUID);

  Future uebunganmelden(String stufe, String _userUID, Map anmeldedaten);
  Future<DocumentSnapshot> getteleblitz(String stufe);
  Future uploadteleblitz(String stufe, Map data);
  Future<bool> refreshteleblitz(String stufe);
  Future<QuerySnapshot> getTNs(String stufe, String datum);

  Stream<QuerySnapshot> getAgenda(String stufe);
  Future uploadtoAgenda(String stufe,String name, Map data);

  Future<void> uploaddevtocken(String stufe,String token, String userUID);
}

class MoreaFirebase extends BaseMoreaFirebase{

  Info teleblitzinfo =  new Info();
  CrudMedthods crud0 = new CrudMedthods();
  Auth auth0 = new Auth();
  DWIFormat dwiformat = new DWIFormat();

  Future<void> createUserInformation(Map userInfo)async{
    String userUID =  await auth0.currentUser();
    crud0.setData('user', userUID, userInfo);
    return null;
  }
  Future<void> updateUserInformation(String userUID, Map userInfo,){
    userUID = dwiformat.simplestring(userUID);
    crud0.setData('user', userUID, userInfo);
     return null;
  }
  Future<DocumentSnapshot> getUserInformation(String userUID) async {
    return await crud0.getDocument('user', userUID);
  }
  Stream<QuerySnapshot> getChildren(){
    return crud0.streamCollection('user');
  }
  //Funktioniert das wück?
  Future<void> pendParent(String child_UID, String parent_UID, String parent)async{
    Map<String, dynamic> parentMap = {};
    var old = await getUserInformation(child_UID);
    for (var u in old.data['Eltern-pending'].keys) {
      parentMap[u] = old[u];
    }
    if(parentMap[parent] ==  null){
      parentMap[parent] = parent_UID;
      updateUserInformation(child_UID, parentMap);
    }
  }

  Future<void> uebunganmelden(String stufe, String _userUID, Map anmeldedaten) async {
    String uebungsdatum = dwiformat.simplestring(teleblitzinfo.datum);
    stufe = dwiformat.simplestring(stufe);
    crud0.setData('uebung/'+ stufe + '/'+ uebungsdatum, _userUID, anmeldedaten);
    return null;
  }
  Future<void> uploadteleblitz(String stufe, Map data){
    Map<String,String> akteleblitz= {
      'AktuellerTeleblitz' : data['datum'].toString().replaceAll('Samstag, ', ''),
      'Stufe': stufe
    };
    stufe = dwiformat.simplestring(stufe);
    crud0.setData('Teleblitz/overview/' + stufe, akteleblitz['AktuellerTeleblitz'], data);
    crud0.setData('Teleblitz/info/' + stufe, 'AktuellerTeleblitz', akteleblitz);
    return null;
  }
  Future<DocumentSnapshot> getteleblitz(String stufe) async {
    if(stufe!= null){
      stufe = dwiformat.simplestring(stufe);
      DocumentSnapshot aktdat = await crud0.getDocument('Teleblitz/info/' + stufe, 'AktuellerTeleblitz');
      return await crud0.getDocument('Teleblitz/overview/'+ stufe, aktdat.data['AktuellerTeleblitz']);
    }else{
      return null;
    }
  }
  Future<bool> refreshteleblitz(String stufe) async {
    DateTime letztesaktdat;
    var timenow = DateTime.now();
    stufe = dwiformat.simplestring(stufe);
    DocumentSnapshot aktdat = await crud0.getDocument('Teleblitz/info/' + stufe, 'Teleblitzaktualisiert');

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
      crud0.setData('Teleblitz/info/' + stufe, 'Teleblitzaktualisiert', uploadakdat);
      return true;
    }
    return false;
  }
  Future<QuerySnapshot> getTNs(String stufe, String datum)async{
  String uebungsdatum = teleblitzinfo.datum;
  stufe = dwiformat.simplestring(stufe);
  return await crud0.getCollection('uebung/$stufe/$datum');
}

  Stream<QuerySnapshot> getAgenda(String stufe)  {
    return crud0.streamOrderCollection('Stufen/$stufe/Agenda', 'Order');
  }
  Future<void> uploadtoAgenda(String stufe, String name, Map data)async{
    stufe = dwiformat.simplestring(stufe);
    name = dwiformat.simplestring(name);
    crud0.setData('Stufen/$stufe/Agenda', name, data);
    return null;
  }
  
  Future<void> uploaddevtocken(String stufe, String token, String userUID) async {
    Map<String,String> tokendata = {
      'devtoken' : token,
      'UID' : userUID
    };
    crud0.setData('Stufen/$stufe/Devices', token.toString(), tokendata);
  }
}