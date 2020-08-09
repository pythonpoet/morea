
/*
Use-Case:
  This Class handels the Teleblitz.
  
Developed:
  David Wild - 9.08.20

Description:
  initialisation:
    Stream Teleblitz
    
  
  Functions:
    readTeleblitz
     
*/


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:morea/morea_strings.dart';

abstract class BaseTeleblitz{
  void readTeleblitz(Stream<Map<String,dynamic>> sTeleblitz);
}

class Teleblitz extends BaseTeleblitz{
  String teleblitzType, timestamp, archived, draft, antreten, abtreten, bemerkunk, datum, ende_ferien, ferien, google_map, grund, keine_aktivitaet, map_abtreten, mitnehmen_test, name, name_des_senders, slug;
  List<String> groupIDs;
  Map<String, dynamic> teleblitz;

  Stream<Map<String,dynamic>> sTeleblitz;
  Teleblitz(this.sTeleblitz){
    readTeleblitz(this.sTeleblitz);
  }
    
  void readTeleblitz(Stream<Map<String,dynamic>> sTeleblitz)async{
    await for(Map<String,dynamic> teleblitz in sTeleblitz){
      this.teleblitz = teleblitz;

      if(teleblitz.containsKey(tlbzMapTeleblitzType))
        this.teleblitzType = teleblitz[tlbzMapTeleblitzType];
      else
         throw "$tlbzMapTeleblitzType has to be non-null";

      if(teleblitz.containsKey(mapTimestamp))
        this.timestamp = teleblitz[mapTimestamp];
      else
         throw "$mapTimestamp has to be non-null";

      if(teleblitz.containsKey(tlbzMapArchived))
        this.archived = teleblitz[tlbzMapArchived];
      else
         throw "$tlbzMapArchived has to be non-null";

      if(teleblitz.containsKey(tlbzMapDraft))
        this.draft = teleblitz[tlbzMapDraft];
      else
         throw "$tlbzMapDraft has to be non-null";

      if(teleblitz.containsKey(tlbzMapAntreten))
        this.antreten = teleblitz[tlbzMapAntreten];
      else
         throw "$tlbzMapAntreten has to be non-null";

      if(teleblitz.containsKey(tlbzMapAbtreten))
        this.abtreten = teleblitz[tlbzMapAbtreten];
      else
         throw "$tlbzMapAbtreten has to be non-null";

      if(teleblitz.containsKey(tlbzMapBemerkung))
        this.bemerkunk = teleblitz[tlbzMapBemerkung];
      else
         throw "$tlbzMapBemerkung has to be non-null";

      if(teleblitz.containsKey(tlbzMapDatum))
        this.datum = teleblitz[tlbzMapDatum];
      else
         throw "$tlbzMapDatum has to be non-null";
      
      if(teleblitz.containsKey(tlbzMapEndeFerien))
        this.ende_ferien = teleblitz[tlbzMapEndeFerien];
      else
         throw "$tlbzMapEndeFerien has to be non-null";

      if(teleblitz.containsKey(tlbzMapFerien))
        this.ferien = teleblitz[tlbzMapFerien];
      else
         throw "$tlbzMapFerien has to be non-null";

      if(teleblitz.containsKey(tlbzMapGoogleMaps))
        this.google_map = teleblitz[tlbzMapGoogleMaps];
      else
         throw "$tlbzMapGoogleMaps has to be non-null";

      if(teleblitz.containsKey(tlbzMapGrund))
        this.grund = teleblitz[tlbzMapGrund];
      else
         throw "$tlbzMapGrund has to be non-null";

      if(teleblitz.containsKey(tlbzMapKeineAktivitaet))
        this.keine_aktivitaet = teleblitz[tlbzMapKeineAktivitaet];
      else
         throw "$tlbzMapKeineAktivitaet has to be non-null";

      if(teleblitz.containsKey(tlbzMapMapAbtreten))
        this.map_abtreten = teleblitz[tlbzMapMapAbtreten];
      else
         throw "$tlbzMapMapAbtreten has to be non-null";

      if(teleblitz.containsKey(tlbzMapMitnehmenTest))
        this.mitnehmen_test = teleblitz[tlbzMapMitnehmenTest];
      else
         throw "$tlbzMapMitnehmenTest has to be non-null";

      if(teleblitz.containsKey(tlbzMapName))
        this.name = teleblitz[tlbzMapName];
      else
         throw "$tlbzMapName has to be non-null";

      if(teleblitz.containsKey(tlbzMapNameDesSenders))
        this.name_des_senders = teleblitz[tlbzMapNameDesSenders];
      else
         throw "$tlbzMapNameDesSenders has to be non-null";

      if(teleblitz.containsKey(tlbzMapSlug))
        this.slug = teleblitz[tlbzMapSlug];
      else
         throw "$tlbzMapSlug has to be non-null";

    }
  }
}