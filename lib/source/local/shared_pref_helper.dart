import 'dart:ffi';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  static const String userIdPrefKey = 'user_pref_key';
  static const String tokenPrefKey = 'token_pref_key';

  SharedPrefHelper._();
  static late SharedPreferences _pref;
  static Future<void> init() async {
    _pref = await SharedPreferences.getInstance();
  }

  static set userId(String val) {
    _pref.setString(userIdPrefKey, val);
  }

  static get userId {
    return _pref.getString(userIdPrefKey);
  }

  static set token(String val) {
    _pref.setString(tokenPrefKey, val);
  }

  static get token {
    return _pref.getString(tokenPrefKey);
  }
}
