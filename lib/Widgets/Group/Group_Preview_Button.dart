import 'package:flutter/material.dart';
import 'package:morea/Widgets/Group/Group_Preview.dart';
import 'package:morea/services/Group/group_data.dart';

class GroupPreviewButton extends GroupPreview {
  final GroupData groupData;
  @override
  late final Widget child;
  @override
  final double radius;
  final void Function()? function;
  GroupPreviewButton(
      {required this.groupData, this.function, required this.radius})
      : super(groupData: groupData, radius: radius) {
    this.child = InkWell(
      onTap: this.function,
      child: GroupPreview(
        groupData: this.groupData,
        radius: this.radius,
      ),
    );
  }
}
