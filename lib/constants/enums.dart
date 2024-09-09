//Priviledge Group

import 'package:morea/morea_strings.dart';

enum PriviledgeGroup {
  Erziehungsperson(roleErziehungsperson),
  TN(roleTN),
  Leitung(roleLeitung),
  StaLei(roleStaLei),
  AL(roleAL);

  const PriviledgeGroup(this.roleDescription);
  final String roleDescription;
}
