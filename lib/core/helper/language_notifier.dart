import 'package:flutter/material.dart';
import '../network/cache_helper.dart';

class LanguageNotifier extends ValueNotifier<Locale> {
  static const String _key = 'selected_language';

  LanguageNotifier() : super(const Locale('en')) {
    init();
  }

  void init() {
    final langCode = CacheHelper.getString(key: _key) ?? 'en';
    value = Locale(langCode);
  }

  Future<void> changeLanguage(String langCode) async {
    if (value.languageCode == langCode) return;
    await CacheHelper.saveData(key: _key, value: langCode);
    value = Locale(langCode);
  }

  bool get isArabic => value.languageCode == 'ar';
}

final languageNotifier = LanguageNotifier();
