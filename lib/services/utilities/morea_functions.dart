import 'package:cloud_functions/cloud_functions.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/cloud_functions.dart';

Future<HttpsCallableResult> makeLeiter(
    String editUID, String request, String groupID) {
  return callFunction(getcallable("makeLeiter"),
      param: {userMapgroupID: groupID, "editUID": editUID, "request": request});
}
