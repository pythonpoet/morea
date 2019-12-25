import 'package:morea/services/utilities/dwi_format.dart'; 

  String convWebflowtoMiData(String stufe){
    DWIFormat dwiFormat = new DWIFormat();
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
      case 'Wombat (Wölfe)':
        return '3776';
      case 'Nahani (Meitli)':
        return '3779';
      case 'Drason (Buebe)':
        return '4013';
      default:
        print("stufe = "+ stufe);
        return stufe;
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
      default:
        throw "convMiDatatoWebflow Error";
     }     
   }
