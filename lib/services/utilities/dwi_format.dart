abstract class BaseDWIFormat {
  String simplestring(String str);

  String pathstring(String str);
}

class DWIFormat implements BaseDWIFormat {
  String simplestring(String str) {
    RegExp exp = new RegExp(r"(\w)");
    Iterable<Match> matches = exp.allMatches(str);
    List<String> charakters = ['%'];
    for (Match m in matches) {
      charakters.add(m.group(0)!);
    }
    charakters.remove('%');
    return charakters.join().toString();
  }

  String pathstring(String str) {
    RegExp exp = new RegExp(r"[\w\/]");
    Iterable<Match> matches = exp.allMatches(str);
    List<String> charakters = ['%'];
    for (Match m in matches) {
      charakters.add(m.group(0)!);
    }
    charakters.remove('%');
    return charakters.join().toString();
  }
}
