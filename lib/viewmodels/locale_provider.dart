import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  late Box _box;

  Locale get locale => _locale;

  void init() {
    _box = Hive.box('settings');
    String? langCode = _box.get('language');
    if (langCode != null) {
      _locale = Locale(langCode);
    }
    notifyListeners();
  }

  void setLocale(Locale locale) {
    if (!L10n.all.contains(locale)) return;
    _locale = locale;
    _box.put('language', locale.languageCode);
    notifyListeners();
  }

  void clearLocale() {
    _locale = const Locale('en');
    _box.put('language', 'en');
    notifyListeners();
  }
}

class L10n {
  static final all = [
    const Locale('en'),
    const Locale('zh'),
    const Locale('ar'),
  ];
}
