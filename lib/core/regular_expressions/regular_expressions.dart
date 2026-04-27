abstract class RegexApp {
  static final onlyNumbers = RegExp(r'[0-9]');

  static final email = RegExp(
    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
  );

  static final phone = RegExp(r'^\+\d{2}\d{2}\d{3,5}\d{4}$');

  static final password = RegExp(
    r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).*$',
  );

  static final hasLowerCase = RegExp(r'(?=.*[a-z])');

  static final hasUpperCase = RegExp(r'(?=.*[A-Z])');

  static final hasDigit = RegExp(r'(?=.*\d)');

  static final hasSpecialChar = RegExp(r'(?=.*[!@#$%^&*(),.?":{}|<>])');
}
