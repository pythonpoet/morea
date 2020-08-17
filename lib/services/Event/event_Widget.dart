import 'package:flutter/widgets.dart';
import 'package:morea/Widgets/animated/MoreaLoading.dart';
import 'package:morea/services/Event/event_data.dart';
import 'package:morea/services/Event/teleblitz_Widget.dart';
import 'package:morea/services/Teleblitz/download_teleblitz.dart';
import 'package:morea/services/crud.dart';
import 'package:morea/services/morea_firestore.dart';

class EventWidget extends StatefulWidget{
  EventWidget({
              @required this.moreaFirebase, 
              @required this.crudMedthods,
              @required this.eventID,
              @required this.function});

  final MoreaFirebase moreaFirebase;
  final CrudMedthods crudMedthods;
  final String eventID;
  final Stream<String> Function(String, String) function;

  EventWidgetState createState() => EventWidgetState();
}
class EventWidgetState extends State<EventWidget>{


  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder(
        stream: getEventStreamMap(widget.crudMedthods, widget.eventID),
        builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> data){
          if(!data.hasData)
            return Container(child: Text("Loading"));
          EventData eventData = EventData(data.data);

          switch (eventData.eventType) {
            case EventType.teleblitz:
                return TeleblitzWidget(eventData: eventData, moreaFirebase: null, crudMedthods: widget.crudMedthods, groupID: null, eventID: null, function: null);
              break;
            //TODO implement New Events here!
            default:
              return Container(child: Text("Upgrade to App to Display Event"));
          }
        }
      ),
    );
  }

}