import "package:ciyue/core/app_globals.dart";
import "package:ciyue/repositories/settings.dart";
import "package:ciyue/src/generated/i18n/app_localizations.dart";
import "package:flutter/material.dart";

class LanguageSelector extends StatefulWidget {
  const LanguageSelector({super.key});

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  String _getLanguageName(String? code, AppLocalizations locale) {
    switch (code) {
      case "system":
        return locale.system;
      case "en":
        return "English";
      case "zh":
        return "简体中文";
      default:
        return code ?? locale.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return InkWell(
      onTapUp: (tapUpDetails) async {
        final languageSelected = await showMenu<String>(
          context: context,
          position: RelativeRect.fromLTRB(
            tapUpDetails.globalPosition.dx,
            tapUpDetails.globalPosition.dy,
            tapUpDetails.globalPosition.dx,
            tapUpDetails.globalPosition.dy,
          ),
          initialValue: settings.language,
          items: [
            PopupMenuItem(value: "system", child: Text(locale.system)),
            const PopupMenuItem(value: "en", child: Text("English")),
            const PopupMenuItem(value: "zh", child: Text("简体中文")),
          ],
        );

        if (languageSelected != null && languageSelected != settings.language) {
          settings.language = languageSelected;
          await prefs.setString("language", languageSelected);

          setState(() {});
          refreshAll();
        }
      },
      child: ListTile(
        leading: const Icon(Icons.language),
        title: Text(locale.language),
        subtitle: Text(_getLanguageName(settings.language, locale)),
        trailing: const Icon(Icons.keyboard_arrow_down),
      ),
    );
  }
}
