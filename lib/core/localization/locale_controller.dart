import 'package:flutter/material.dart';

class LocaleController extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;
  String get languageCode => _locale.languageCode;
  bool get isArabic => _locale.languageCode == 'ar';

  void setLocale(Locale newLocale) {
    if (_locale == newLocale) return;
    _locale = newLocale;
    notifyListeners();
  }

  void toggleLocale() {
    _locale = _locale.languageCode == 'en'
        ? const Locale('ar')
        : const Locale('en');
    notifyListeners();
  }
}
