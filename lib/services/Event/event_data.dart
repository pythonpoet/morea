import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/crud.dart';

 Stream<Map<String, dynamic>> getEventStreamMap(CrudMedthods crudMedthods, String eventID)async*{
  await for(DocumentSnapshot dsEventData in crudMedthods.streamDocument(pathEvents, eventID)){
    yield dsEventData.data;
  }
}
enum EventType{teleblitz}
enum TeleblitzType { ferien, keineAktivitaet, teleblitz, notImplemented }
class EventData {
  String  
        timestamp,
        archived,
        draft,
        antreten,
        abtreten,
        bemerkung,
        datum,
        endeFerien,
        ferien,
        googleMap,
        grund,
        keineAktivitaet,
        mapAbtreten,
        mitnehmenTest,
        name,
        nameDesSenders,
        slug;
  List<String> groupIDs;
  Map<String, dynamic> eventData;
  EventType eventType;
  TeleblitzType teleblitzType;
  EventData(this.eventData){
    readTeleblitz(this.eventData);
  }
    
  void readTeleblitz(Map<String,dynamic> eventData)async{
      this.eventData = eventData;

      this.teleblitzType = readTeleblitzType(eventData);

      if(eventData.containsKey(mapTimestamp))
        this.timestamp = eventData[mapTimestamp];
      else
         throw "$mapTimestamp has to be non-null";

      if(eventData.containsKey(tlbzMapArchived))
        this.archived = eventData[tlbzMapArchived];
      else
         throw "$tlbzMapArchived has to be non-null";

      if(eventData.containsKey(tlbzMapDraft))
        this.draft = eventData[tlbzMapDraft];
      else
         throw "$tlbzMapDraft has to be non-null";

      if(eventData.containsKey(tlbzMapAntreten))
        this.antreten = eventData[tlbzMapAntreten];
      else
         throw "$tlbzMapAntreten has to be non-null";

      if(eventData.containsKey(tlbzMapAbtreten))
        this.abtreten = eventData[tlbzMapAbtreten];
      else
         throw "$tlbzMapAbtreten has to be non-null";

      if(eventData.containsKey(tlbzMapBemerkung))
        this.bemerkung = eventData[tlbzMapBemerkung];
      else
         throw "$tlbzMapBemerkung has to be non-null";

      if(eventData.containsKey(tlbzMapDatum))
        this.datum = eventData[tlbzMapDatum];
      else
         throw "$tlbzMapDatum has to be non-null";
      
      if(eventData.containsKey(tlbzMapEndeFerien))
        this.endeFerien = eventData[tlbzMapEndeFerien];
      else
         throw "$tlbzMapEndeFerien has to be non-null";

      if(eventData.containsKey(tlbzMapFerien))
        this.ferien = eventData[tlbzMapFerien];
      else
         throw "$tlbzMapFerien has to be non-null";

      if(eventData.containsKey(tlbzMapGoogleMaps))
        this.googleMap = eventData[tlbzMapGoogleMaps];
      else
         throw "$tlbzMapGoogleMaps has to be non-null";

      if(eventData.containsKey(tlbzMapGrund))
        this.grund = eventData[tlbzMapGrund];
      else
         throw "$tlbzMapGrund has to be non-null";

      if(eventData.containsKey(tlbzMapKeineAktivitaet))
        this.keineAktivitaet = eventData[tlbzMapKeineAktivitaet];
      else
         throw "$tlbzMapKeineAktivitaet has to be non-null";

      if(eventData.containsKey(tlbzMapMapAbtreten))
        this.mapAbtreten = eventData[tlbzMapMapAbtreten];
      else
         throw "$tlbzMapMapAbtreten has to be non-null";

      if(eventData.containsKey(tlbzMapMitnehmenTest))
        this.mitnehmenTest = eventData[tlbzMapMitnehmenTest];
      else
         throw "$tlbzMapMitnehmenTest has to be non-null";

      if(eventData.containsKey(tlbzMapName))
        this.name = eventData[tlbzMapName];
      else
         throw "$tlbzMapName has to be non-null";

      if(eventData.containsKey(tlbzMapNameDesSenders))
        this.nameDesSenders = eventData[tlbzMapNameDesSenders];
      else
         throw "$tlbzMapNameDesSenders has to be non-null";

      if(eventData.containsKey(tlbzMapSlug))
        this.slug = eventData[tlbzMapSlug];
      else
         throw "$tlbzMapSlug has to be non-null";

    
  }
   TeleblitzType readTeleblitzType(Map<String, dynamic> tlbz) {
    if (tlbz.containsKey("TeleblitzType")) if (tlbz["TeleblitzType"] !=
        "Teleblitz") return TeleblitzType.notImplemented;
    var keineAkt = tlbz["keine-aktivitat"];
    var keineFerien = tlbz["ferien"];
    if (keineAkt.runtimeType == String) {
      keineAkt = keineAkt.toLowerCase() == 'true';
    }
    if (keineFerien.runtimeType == String) {
      keineFerien = keineFerien.toLowerCase() == 'true';
    }

    if (keineAkt) {
      return TeleblitzType.keineAktivitaet;
    } else if (keineFerien) {
      return TeleblitzType.ferien;
    } else {
      return TeleblitzType.teleblitz;
    }
  }
 
}

  
  
