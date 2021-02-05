class MoreaInputValidator {
  static bool email(String value) {
    RegExp regExp = RegExp(r'[^@\s]+@.+\.[A-Za-z]+');
    return regExp.hasMatch(value);
  }

  static bool phoneNumber(String value) {
    return RegExp(r'(^\+\d{7,}|^00\d{7,})').hasMatch(value);
  }

  static bool number(String value) {
    return RegExp(r'^\d{4}').hasMatch(value);
  }

  static bool letters(String value) {
    return RegExp(r'\D').hasMatch(value);
  }
}
