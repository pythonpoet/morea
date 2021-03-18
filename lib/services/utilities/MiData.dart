import 'package:morea/services/utilities/dwi_format.dart';

String convWebflowtoMiData(String stufe) {
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
      return 'Op3qqioWs36MCeoWgDYL';
    case 'Wombat (Wölfe)':
      return '3776';
    case 'Nahani (Meitli)':
      return '3779';
    case 'Drason (Buebe)':
      return 'Op3qqioWs36MCeoWgDYL';
    default:
      print("stufe = " + stufe);
      return stufe;
  }
}

String convMiDatatoWebflow(String groupID) {
  switch (groupID) {
    case 'hjZL6PT8t8MCfxf5GOko':
      return 'Biber';
    case 'TJNO3BHaPnBZE33anezc':
      return 'Wölfe 1';
    case 'VVy3DAlQLmbw9oGuRwvZ':
      return 'Nahani (Meitli)';
    case '4013':
      return 'Drason (Buebe)';
    case 'Op3qqioWs36MCeoWgDYL':
      return 'Drason (Buebe)';
    case 'UisNaofVTp924gvx6Kcf':
      return 'Wölfe 2';
    case 'iRHtWXGhstTpMwmceqaF':
      return 'Pio';
    default:
      throw "convMiDatatoWebflow Error groupID given was: " +
          groupID.toString();
  }
}
