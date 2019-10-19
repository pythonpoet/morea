import 'package:morea/services/dwi_format.dart';

abstract class BaseMiData{
  String convWebflowtoMiData(String stufe);
  String convMiDatatoWebflow(String groupnr);
}
class MiData implements BaseMiData{
  DWIFormat dwiFormat = new DWIFormat();

  String convWebflowtoMiData(String stufe){
    stufe = dwiFormat.simplestring(stufe);
    switch (stufe) {
      case 'Biber':
        return '3775';
      case 'WombatWlfe':
        return '3776';
      case 'NahaniMeitli':
        return '3779';
      case 'DrasonBuebe':
        return '4013';
    }
  }
   String convMiDatatoWebflow(String groupID){
     switch (groupID) {
      case '3775':
        return 'Biber';
      case '3776':
        return 'Wombat (Wölfe)';
      case '3779':
        return 'Nahani (Meitli)';
      case '4013':
        return 'Drason (Buebe)';
     }     
   }
}