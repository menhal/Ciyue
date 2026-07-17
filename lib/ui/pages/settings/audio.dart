import "dart:io";

import "package:ciyue/core/app_globals.dart";
import "package:ciyue/core/env.dart";
import "package:ciyue/services/audio.dart";
import "package:ciyue/services/volcano_tts.dart";
import "package:ciyue/ui/core/title_text.dart";
import "package:ciyue/repositories/dictionary.dart";
import "package:ciyue/services/platform.dart";
import "package:ciyue/repositories/settings.dart";
import "package:ciyue/src/generated/i18n/app_localizations.dart";
import "package:ciyue/utils.dart";
import "package:ciyue/viewModels/audio.dart";
import "package:file_selector/file_selector.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

class AudioItems extends StatelessWidget {
  const AudioItems({super.key});

  @override
  Widget build(BuildContext context) {
    context.select<AudioModel, int>((model) => model.mddAudioListState);
    final mddAudioList = context.read<AudioModel>().mddAudioList;

    return Expanded(
      child: ReorderableListView.builder(
        buildDefaultDragHandles: false,
        itemCount: mddAudioList.length + 1,
        itemBuilder: (context, index) {
          if (index == mddAudioList.length) {
            return Card(
              key: ValueKey("tts_option"),
              color: Theme.of(context).colorScheme.onInverseSurface,
              child: ListTile(
                title: const Text("TTS"),
              ),
            );
          } else {
            final mddAudio = mddAudioList[index];
            return Card(
              color: Theme.of(context).colorScheme.onInverseSurface,
              key: ValueKey(mddAudio.id),
              child: ListTile(
                leading: ReorderableDragStartListener(
                  index: index,
                  child: IconButton(icon: Icon(Icons.menu), onPressed: () {}),
                ),
                title: Text(mddAudio.title),
                trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      await context
                          .read<AudioModel>()
                          .removeMddAudio(mddAudio.id);
                    }),
              ),
            );
          }
        },
        onReorderItem: (oldIndex, newIndex) {
          if (oldIndex >= mddAudioList.length ||
              newIndex >= mddAudioList.length) {
            return;
          }
          context.read<AudioModel>().reorderMddAudio(oldIndex, newIndex);
        },
      ),
    );
  }
}

class AudioList extends StatelessWidget {
  const AudioList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () async {
                if (Platform.isAndroid) {
                  if (isFullFlavor()) {
                    final isGranted =
                        await requestManageExternalStorage(context);
                    if (isGranted) {
                      final path = await getDirectoryPath();
                      if (path != null) {
                        await prefs.setString("audioDirectory", path);

                        final paths = await findMddAudioFilesOnAndroid(path);
                        if (context.mounted) {
                          await selectAudioMdd(context, paths);
                        }
                      }
                    }
                  } else {
                    PlatformMethod.openAudioDirectory();
                  }
                } else {
                  await selectMdxOrMddOnDesktop(context, false);
                }
              },
            ),
          ],
        ),
        AudioItems(),
      ],
    );
  }
}

class AudioSettingsPage extends StatelessWidget {
  const AudioSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(height: 24),
                  TTSSourceSetting(),
                  Expanded(child: AudioList()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TTSSourceSetting extends StatefulWidget {
  const TTSSourceSetting({super.key});

  @override
  State<TTSSourceSetting> createState() => _TTSSourceSettingState();
}

class _TTSSourceSettingState extends State<TTSSourceSetting> {
  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleText(locale.ttsSource),
        SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: settings.ttsSource,
          decoration: InputDecoration(
            labelText: locale.ttsSource,
            border: OutlineInputBorder(),
          ),
          items: [
            DropdownMenuItem(value: "system", child: Text(locale.systemTts)),
            if (Env.hasVolcanoTts)
              DropdownMenuItem(
                  value: "volcano", child: Text(locale.volcanoTts)),
          ],
          onChanged: (String? source) async {
            if (source != null) {
              await settings.setTTSSource(source);
              setState(() {});
            }
          },
        ),
        if (settings.ttsSource == "volcano") ...[
          SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: volcanoVoices
                    .any((voice) => voice.$1 == settings.volcanoTtsVoice)
                ? settings.volcanoTtsVoice
                : volcanoVoices.first.$1,
            decoration: InputDecoration(
              labelText: locale.volcanoVoice,
              border: OutlineInputBorder(),
            ),
            items: [
              for (final voice in volcanoVoices)
                DropdownMenuItem(value: voice.$1, child: Text(voice.$2)),
            ],
            onChanged: (String? voice) async {
              if (voice != null) {
                await settings.setVolcanoTtsVoice(voice);
              }
            },
          ),
        ],
        SizedBox(height: 24),
        if (settings.ttsSource == "system") ...[
          TTSEngines(),
          TTSLanguages(),
        ],
      ],
    );
  }
}

class TTSEngines extends StatelessWidget {
  const TTSEngines({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleText(AppLocalizations.of(context)!.ttsEngines),
        SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: settings.ttsEngine ??
              (ttsEngines.isNotEmpty ? ttsEngines.first : null),
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.ttsEngines,
            border: OutlineInputBorder(),
          ),
          items: [
            for (final engine in ttsEngines)
              DropdownMenuItem(
                value: engine,
                child: Text((engine as String)
                    .replaceFirst(RegExp(r"^com\."), "")
                    .split(".")
                    .map((e) => e.isEmpty
                        ? ""
                        : "${e[0].toUpperCase()}${e.substring(1)}")
                    .join(" ")),
              )
          ],
          onChanged: (String? ttsEngine) async {
            if (ttsEngine != null) {
              settings.setTTSEngine(ttsEngine);
              flutterTts.setEngine(ttsEngine);
            }
          },
        ),
        SizedBox(height: 24),
      ],
    );
  }
}

class TTSLanguages extends StatelessWidget {
  const TTSLanguages({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleText(AppLocalizations.of(context)!.ttsLanguages),
        SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: settings.ttsLanguage ?? _defaultLanguage(),
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.ttsLanguages,
            border: OutlineInputBorder(),
          ),
          items: [
            for (final lang in ttsLanguages)
              DropdownMenuItem(
                value: lang,
                child: Text(lang),
              )
          ],
          onChanged: (String? ttsLanguage) async {
            if (ttsLanguage != null) {
              settings.setTTSLanguage(ttsLanguage);
              flutterTts.setLanguage(ttsLanguage);
            }
          },
        )
      ],
    );
  }

  String _defaultLanguage() {
    if (ttsLanguages.contains("en-US")) {
      return "en-US";
    }

    if (ttsLanguages.isNotEmpty) {
      return ttsLanguages.first;
    }

    return "";
  }
}
