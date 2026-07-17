import "package:ciyue/src/generated/i18n/app_localizations.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:url_launcher/url_launcher.dart";

class CiyueError extends StatelessWidget {
  final Object error;

  const CiyueError({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(locale.error),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(error.toString()),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                launchUrl(
                    Uri.parse("https://github.com/mumu-lhl/ciyue/issues"));
              },
              child: Text(locale.reportIssue),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: error.toString()));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(locale.errorCopied)),
                );
              },
              child: Text(locale.copyError),
            ),
          ],
        ),
      ),
    );
  }
}
