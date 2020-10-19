import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:morea/Widgets/Group/Group_Preview.dart';
import 'package:morea/services/Group/group_data.dart';

class GroupPreviewButton extends GroupPreview {
  GroupData groupData;
  @override
  Widget child;
  @override
  double radius;
  Function function;
  GroupPreviewButton({@required this.groupData, this.function, this.radius}) {
    this.child = InkWell(
      onTap: this.function,
      child: GroupPreview(
        groupData: this.groupData,
        radius: this.radius,
      ),
    );
  }
}
