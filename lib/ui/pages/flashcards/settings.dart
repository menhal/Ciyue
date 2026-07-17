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
    return Scaffold(
      appBar: AppBar(title: const Text("Flashcards")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text("New cards per day",
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              helperText: "Allowed range: 0–9999",
              suffixText: "cards",
            ),
            onSubmitted: (_) => _save(),
            onTapOutside: (_) => _save(),
          ),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text("Scheduling"),
            subtitle: Text("FSRS · 90% desired retention"),
          ),
          const SizedBox(height: 8),
          FilledButton.tonalIcon(
            onPressed: _redraw,
            icon: const Icon(Icons.casino_outlined),
            label: const Text("Redraw today's new cards"),
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
        content: Text("Redrawn: $removed unreviewed new cards returned"),
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
