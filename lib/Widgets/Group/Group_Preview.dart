import 'package:flutter/material.dart';
import 'package:morea/services/Group/group_data.dart';

class GroupPreview extends CircleAvatar {
  final GroupData groupData;
  @override
  late final Widget child;
  @override
  final double radius;
  GroupPreview({required this.groupData, required this.radius}) {
    this.child = Text(this.groupData.groupNickName!.substring(0, 1));
  }
}
