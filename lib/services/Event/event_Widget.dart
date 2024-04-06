import 'package:flutter/widgets.dart';
import 'package:morea/services/Event/data_types/Teleblitz_data.dart';
import 'package:morea/services/Event/event_data.dart';
import 'package:morea/services/Event/teleblitz_Widget.dart';

import 'package:morea/services/crud.dart';
import 'package:morea/services/morea_firestore.dart';

class EventWidget extends StatefulWidget {
  EventWidget(
      {required this.moreaFirebase,
      required this.crudMedthods,
      required this.eventID,
      required this.function});

  final MoreaFirebase moreaFirebase;
  final CrudMedthods crudMedthods;
  final String eventID;
  final Stream<String> Function(String, String) function;

  EventWidgetState createState() => EventWidgetState();
}

class EventWidgetState extends State<EventWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder(
          stream: getEventStreamMap(widget.crudMedthods, widget.eventID),
          builder:
              (BuildContext context, AsyncSnapshot<Map<String, dynamic>> data) {
            if (!data.hasData) return Container(child: Text("Loading"));
            EventData eventData = EventData(data.data!);
            eventData.setEventID(widget.eventID);

            switch (eventData.eventType) {
              case EventType.teleblitz:
                return TeleblitzWidget(
                    eventData: eventData as TeleblitzData,
                    moreaFirebase: widget.moreaFirebase,
                    crudMedthods: widget.crudMedthods,
                    eventID: widget.eventID,
                    function: widget.function);
              default:
                return Container(
                    child: Text("Upgrade to App to Display Event"));
            }
          }),
    );
  }
}
