import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:ui'; // Import to access PlatformDispatcher

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  late Box _box;

  Locale get locale => _locale;

  void init() {
    _box = Hive.box('settings');
    String? langCode = _box.get('language');

    if (langCode != null) {
      // 1. If user has a saved preference, use it
      _locale = Locale(langCode);
    } else {
      // 2. No preference saved (first run), try to get device locale
      final deviceLocale = PlatformDispatcher.instance.locale;
      print('📱 Detected device locale: ${deviceLocale.languageCode}');

      // Check if device locale is supported
      if (_isSupported(deviceLocale)) {
        _locale = Locale(deviceLocale.languageCode);
        print(
            '✅ Device locale is supported. Setting language to: ${deviceLocale.languageCode}');
      } else {
        // Fallback to English
        _locale = const Locale('en');
        print('⚠️ Device locale not supported. Defaulting to English.');
      }
    }
    notifyListeners();
  }

  bool _isSupported(Locale locale) {
    for (var supportedLocale in L10n.all) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
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
