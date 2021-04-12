import 'package:flutter/material.dart';
import 'package:morea/services/Group/group_data.dart';

class GroupPreview extends CircleAvatar {
  GroupData groupData;
  @override
  Widget child;
  @override
  double radius;
  GroupPreview({@required this.groupData, this.radius}) {
    this.child = Text(this.groupData.groupNickName.substring(0, 1));
  }
}
