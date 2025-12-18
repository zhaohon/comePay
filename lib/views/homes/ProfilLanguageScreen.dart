import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../viewmodels/locale_provider.dart';

class Profillanguagescreen extends StatefulWidget {
  const Profillanguagescreen({super.key});

  @override
  _ProfillanguagescreenState createState() => _ProfillanguagescreenState();
}

class _ProfillanguagescreenState extends State<Profillanguagescreen> {
  late List<Map<String, dynamic>> languages;

  @override
  void initState() {
    super.initState();
    final currentLocale =
        Provider.of<LocaleProvider>(context, listen: false).locale;
    languages = [
      {
        'name': 'English',
        'locale': const Locale('en'),
        'selected': currentLocale.languageCode == 'en'
      },
      {
        'name': 'China',
        'locale': const Locale('zh'),
        'selected': currentLocale.languageCode == 'zh'
      },
      {
        'name': 'Arabic',
        'locale': const Locale('ar'),
        'selected': currentLocale.languageCode == 'ar'
      },
    ];
  }

  void _showConfirmDialog(Locale locale) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: Center(
            child: Text(
              AppLocalizations.of(context)!.hint,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.applySetting,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    setState(() {
                      for (var lang in languages) {
                        lang['selected'] = false;
                      }
                      final selectedLang = languages
                          .firstWhere((lang) => lang['locale'] == locale);
                      selectedLang['selected'] = true;
                    });
                    Provider.of<LocaleProvider>(context, listen: false)
                        .setLocale(locale);
                    Navigator.of(context).pop();
                  },
                  child: Text(AppLocalizations.of(context)!.confirm),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          AppLocalizations.of(context)!.language,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 4.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: languages.map((language) {
              return Column(
                children: [
                  ListTile(
                    leading: Text(
                      AppLocalizations.of(context)!.language == 'Language'
                          ? language['name']
                          : _getTranslatedName(context, language['locale']),
                      style: TextStyle(
                          fontSize: 16,
                          color: const Color(0xFF757575),
                          fontWeight: language['selected']
                              ? FontWeight.bold
                              : FontWeight.normal),
                    ),
                    trailing: Icon(
                      language['selected']
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      color: language['selected']
                          ? Colors.blue
                          : const Color(0xFF757575),
                    ),
                    onTap: () => _showConfirmDialog(language['locale']),
                  ),
                  if (language != languages.last)
                    const Divider(height: 1, color: Color(0xFFE0E0E0)),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  String _getTranslatedName(BuildContext context, Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return AppLocalizations.of(context)!.english;
      case 'zh':
        return AppLocalizations.of(context)!.china;
      case 'ar':
        return AppLocalizations.of(context)!.arabic;
      default:
        return '';
    }
  }
}
