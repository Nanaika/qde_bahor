import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:qde_eco_bahor/generated/locale_keys.g.dart';

class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(LocaleKeys.language_select.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(LocaleKeys.language_english.tr()),
                onTap: () {
                  context.setLocale(const Locale('en'));
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(LocaleKeys.language_russian.tr()),
                onTap: () {
                  context.setLocale(const Locale('ru'));
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _getCurrentLanguage(BuildContext context) {
    final locale = context.locale;
    return locale.languageCode == 'ru' ? 'RU' : 'EN';
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.language),
          const SizedBox(width: 4),
          Text(
            _getCurrentLanguage(context),
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
      tooltip: LocaleKeys.language_change.tr(),
      onPressed: () => _showLanguageDialog(context),
    );
  }
}
