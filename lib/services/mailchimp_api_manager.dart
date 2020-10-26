import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/morea_firestore.dart';

class MailChimpAPIManager {
  MailChimpAPIManager();

  printUserInfo(String email, MoreaFirebase moreafire) async {
    String apiKey = await moreafire.getMailChimpApiKey();
    String hash = generateMd5(email);
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('pfadimorea:$apiKey'));
    var result = await http.get(urlInfoMailListMembers + hash,
        headers: {'Authorization': basicAuth});
    var decoded = json.decode(result.body);
    print(decoded);
  }

  updateUserInfo(String email, String vorname, String nachname,
      String geschlecht, List<String> stufe, MoreaFirebase moreafire) async {
    String apiKey = await moreafire.getMailChimpApiKey();
    String biber = 'Nein', woelfe = 'Nein', meitli = 'Nein', buebe = 'Nein';
    if (stufe.contains(midatanamebiber)) {
      biber = 'Ja';
    } else if (stufe.contains(midatanamewoelf)) {
      woelfe = 'Ja';
    } else if (stufe.contains(midatanamemeitli)) {
      meitli = 'Ja';
    } else if (stufe.contains(midatanamebuebe)) {
      buebe = 'Ja';
    }
    String hash = generateMd5(email);
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('pfadimorea:$apiKey'));
    Map bodyMap = {
      'email_address': email,
      'status_if_new': 'subscribed',
      'merge_fields': {
        'FNAME': vorname,
        'LNAME': nachname,
        'GESCHLECHT': geschlecht,
        'BIBER': biber,
        'WOELFE': woelfe,
        'MEITLI': meitli,
        'BUEBE': buebe
      }
    };
    String bodyStr = jsonEncode(bodyMap);
    var result = await http.put(urlInfoMailListMembers + hash,
        headers: {'Authorization': basicAuth}, body: bodyStr);
    var decoded = json.decode(result.body);
    print(decoded);
  }

  String generateMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }
}
