import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:morea/morea_strings.dart';

class MailChimpAPIManager {
  final String apiKey = '36068e99be1a9254da7c6c32aa391d02-us13';

  MailChimpAPIManager();

  printUserInfo(String email) async {
    String hash = generateMd5(email);
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('pfadimorea:$apiKey'));
    var result = await http.get(urlInfoMailListMembers + hash,
        headers: {'Authorization': basicAuth});
    var decoded = json.decode(result.body);
    print(decoded);
  }

  updateUserInfo(String email, String vorname, String nachname,
      String geschlecht, String stufe) async {
    String biber = 'Nein',
        woelfe = 'Nein',
        meitli = 'Nein',
        buebe = 'Nein';
    if (stufe == midatanamebiber) {
      biber = 'Ja';
    } else if (stufe == midatanamewoelf) {
      woelfe = 'Ja';
    } else if (stufe == midatanamemeitli) {
      meitli = 'Ja';
    } else if (stufe == midatanamebuebe) {
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
    var result = await http.put(urlInfoMailListMembers + hash, headers: {
      'Authorization': basicAuth
    }, body: bodyStr);
    var decoded = json.decode(result.body);
    print(decoded);
  }

  String generateMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }
}
