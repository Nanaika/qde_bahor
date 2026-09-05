import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select language'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.language),
                title: Text('English'.tr()),
                onTap: () {
                  context.setLocale(const Locale('en'));
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text('Russian'.tr()),
                onTap: () {
                  context.setLocale(const Locale('ru'));
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text('Uzbek'.tr()),
                onTap: () {
                  context.setLocale(const Locale('uz'));
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
    return switch (locale.languageCode) {
      'ru' => 'RU',
      'uz' => 'UZ',
      _ => 'EN',
    };
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
      onPressed: () => _showLanguageDialog(context),
    );
  }
}
