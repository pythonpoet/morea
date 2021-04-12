import 'package:morea/morea_strings.dart';
import 'package:morea/services/Event/event_data.dart';

enum TeleblitzType { ferien, keineAktivitaet, teleblitz, notImplemented }

class TeleblitzData extends EventData {
  String timestamp,
      antreten,
      abtreten,
      bemerkung,
      datum,
      endeFerien,
      googleMap,
      grund,
      keineAktivitaet,
      mapAbtreten,
      name,
      nameDesSenders,
      slug;
  bool archived, draft, ferien;
  List<String> mitnehmenTest;
  TeleblitzType teleblitzType;

  TeleblitzData(Map<String, dynamic> eventData) : super.init(eventData) {
    this.teleblitzType = readTeleblitzType(eventData);

    if (eventData.containsKey(tlbzMapArchived))
      this.archived = eventData[tlbzMapArchived];
    else
      throw "$tlbzMapArchived has to be non-null";

    if (eventData.containsKey(tlbzMapDraft))
      this.draft = eventData[tlbzMapDraft];
    else
      throw "$tlbzMapDraft has to be non-null";

    if (eventData.containsKey(tlbzMapAntreten))
      this.antreten = eventData[tlbzMapAntreten];
    else
      throw "$tlbzMapAntreten has to be non-null";

    if (eventData.containsKey(tlbzMapAbtreten))
      this.abtreten = eventData[tlbzMapAbtreten];
    else
      throw "$tlbzMapAbtreten has to be non-null";

    if (eventData.containsKey(tlbzMapBemerkung))
      this.bemerkung = eventData[tlbzMapBemerkung];
    else
      throw "$tlbzMapBemerkung has to be non-null";

    if (eventData.containsKey(tlbzMapDatum))
      this.datum = eventData[tlbzMapDatum];
    else
      throw "$tlbzMapDatum has to be non-null";

    if (eventData.containsKey(tlbzMapEndeFerien))
      this.endeFerien = eventData[tlbzMapEndeFerien];
    else
      throw "$tlbzMapEndeFerien has to be non-null";

    if (eventData.containsKey(tlbzMapFerien))
      this.ferien = eventData[tlbzMapFerien];
    else
      throw "$tlbzMapFerien has to be non-null";

    if (eventData.containsKey(tlbzMapGoogleMaps))
      this.googleMap = eventData[tlbzMapGoogleMaps];
    else
      throw "$tlbzMapGoogleMaps has to be non-null";

    if (eventData.containsKey(tlbzMapGrund))
      this.grund = eventData[tlbzMapGrund];
    else
      throw "$tlbzMapGrund has to be non-null";

    if (eventData.containsKey(tlbzMapKeineAktivitaet))
      this.keineAktivitaet = eventData[tlbzMapKeineAktivitaet].toString();
    else
      throw "$tlbzMapKeineAktivitaet has to be non-null";

    if (eventData.containsKey(tlbzMapMapAbtreten))
      this.mapAbtreten = eventData[tlbzMapMapAbtreten];
    else
      throw "$tlbzMapMapAbtreten has to be non-null";

    if (eventData.containsKey(tlbzMapMitnehmenTest))
      this.mitnehmenTest = new List.from(eventData[tlbzMapMitnehmenTest]);
    else
      throw "$tlbzMapMitnehmenTest has to be non-null";

    if (eventData.containsKey(tlbzMapName))
      this.name = eventData[tlbzMapName];
    else
      throw "$tlbzMapName has to be non-null";

    if (eventData.containsKey(tlbzMapNameDesSenders))
      this.nameDesSenders = eventData[tlbzMapNameDesSenders];
    else
      throw "$tlbzMapNameDesSenders has to be non-null";

    if (eventData.containsKey(tlbzMapSlug)) this.slug = eventData[tlbzMapSlug];
  }

  TeleblitzType readTeleblitzType(Map<String, dynamic> tlbz) {
    if (tlbz["EventType"] != "Teleblitz") return TeleblitzType.notImplemented;

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

  @override
  Map<String, dynamic> pack() {
    return super.eventData;
  }
}
