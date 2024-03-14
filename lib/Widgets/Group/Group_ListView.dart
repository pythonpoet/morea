import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:morea/Widgets/Group/Group_Preview_Button.dart';
import 'package:morea/services/Group/group_data.dart';
import 'package:rxdart/rxdart.dart';

class GroupListView extends SingleChildScrollView {
  static StreamController<String> selectedGroupID = BehaviorSubject();
  @override
  final Axis scrollDirection = Axis.horizontal;
  @override
  late final Widget child;

  GroupListView(Map<String, GroupData> mapGroupData) {
    if (!GroupListView.selectedGroupID.hasListener)
      GroupListView.selectedGroupID.add(mapGroupData.keys.first);

    this.child = Row(
      children: mapGroupData
          .map<String, Widget>((String groupID, GroupData groupData) {
            return MapEntry(
                groupID,
                Container(
                  child: GroupPreviewButton(
                    groupData: groupData,
                    radius: 35,
                    function: () => setGroupID(groupID),
                  ),
                ));
          })
          .values
          .toList(),
    );
  }
  void setGroupID(String groupID) {
    GroupListView.selectedGroupID.add(groupID);
  }
}
