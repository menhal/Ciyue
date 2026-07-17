import "package:ciyue/src/generated/i18n/app_localizations.dart";
import "package:ciyue/ui/pages/flashcards/providers.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

class FlashcardSettingsPage extends ConsumerStatefulWidget {
  const FlashcardSettingsPage({super.key});

  @override
  ConsumerState<FlashcardSettingsPage> createState() =>
      _FlashcardSettingsPageState();
}

class _FlashcardSettingsPageState extends ConsumerState<FlashcardSettingsPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(flashcardDailyNewLimitProvider).toString(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(locale.flashcards)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(locale.newCardsPerDay,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              helperText: locale.allowedRange,
              suffixText: locale.cardsUnit,
            ),
            onSubmitted: (_) => _save(),
            onTapOutside: (_) => _save(),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(locale.scheduling),
            subtitle: Text(locale.schedulingDescription),
          ),
          const SizedBox(height: 8),
          FilledButton.tonalIcon(
            onPressed: _redraw,
            icon: const Icon(Icons.casino_outlined),
            label: Text(locale.redrawTodaysNewCards),
          ),
        ],
      ),
    );
  }

  Future<void> _redraw() async {
    final removed = await redrawFlashcardNewCards();
    ref.invalidate(flashcardSessionProvider);
    ref.invalidate(flashcardOverviewProvider);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.redrawnNewCards(removed)),
      ),
    );
  }

  Future<void> _save() async {
    final parsed = int.tryParse(_controller.text) ?? 20;
    final normalized = normalizeFlashcardDailyLimit(parsed);
    _controller.text = normalized.toString();
    await ref
        .read(flashcardDailyNewLimitProvider.notifier)
        .setLimit(normalized);
  }
}
