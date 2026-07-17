import "package:ciyue/core/providers.dart";
import "package:ciyue/src/generated/i18n/app_localizations.dart";
import "package:ciyue/services/audio.dart";
import "package:ciyue/services/flashcard_scheduler.dart";
import "package:ciyue/services/flashcard_study_service.dart";
import "package:ciyue/ui/core/word_display/utils.dart";
import "package:ciyue/ui/pages/flashcards/providers.dart";
import "package:ciyue/ui/pages/flashcards/rating_buttons.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

class FlashcardStudyPage extends ConsumerStatefulWidget {
  final int? tag;

  const FlashcardStudyPage({super.key, this.tag});

  @override
  ConsumerState<FlashcardStudyPage> createState() => _FlashcardStudyPageState();
}

class _FlashcardStudyPageState extends ConsumerState<FlashcardStudyPage> {
  @override
  Widget build(BuildContext context) {
    final session = ref.watch(flashcardSessionProvider(widget.tag));
    return session.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(),
        body: Center(
            child: Text(AppLocalizations.of(context)!
                .errorWithMessage(error.toString()))),
      ),
      data: (state) {
        if (state.complete) return _buildSummary(state);
        return Scaffold(
          appBar: AppBar(
            title: Text("${state.index + 1} / ${state.items.length}"),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => context.push("/settings/flashcards"),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(4),
              child: LinearProgressIndicator(
                value: state.index / state.items.length,
              ),
            ),
          ),
          body: SafeArea(child: _buildCard(state)),
        );
      },
    );
  }

  Widget _buildCard(FlashcardSessionState state) {
    final item = state.current;
    final wide = MediaQuery.sizeOf(context).width >= 800;
    final word = _wordPanel(item.word);
    final answer = _answerPanel(item);
    final notifier = ref.read(flashcardSessionProvider(widget.tag).notifier);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: !state.answerVisible
                  ? word
                  : wide
                      ? Row(children: [
                          Expanded(child: word),
                          const VerticalDivider(width: 1),
                          Expanded(child: answer),
                        ])
                      : Column(children: [
                          SizedBox(height: 120, child: word),
                          const Divider(height: 1),
                          Expanded(child: answer),
                        ]),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: state.answerVisible
                ? FlashcardRatingButtons(onSelected: _rate)
                : FilledButton(
                    onPressed: notifier.showAnswer,
                    child: Text(AppLocalizations.of(context)!.showAnswer),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _wordPanel(String word) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              word,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            IconButton(
              icon: const Icon(Icons.volume_up),
              onPressed: () => ttsSpeak(word),
            ),
          ],
        ),
      );

  Widget _answerPanel(FlashcardSessionItem item) {
    final validIds = ref.watch(validDictIdsProvider(item.word));
    return validIds.when(
      data: (ids) => ids.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppLocalizations.of(context)!.noDefinitionFound),
                  TextButton(
                    onPressed: () =>
                        context.push("/word/${Uri.encodeComponent(item.word)}"),
                    child:
                        Text(AppLocalizations.of(context)!.openFullDictionary),
                  ),
                ],
              ),
            )
          : buildWebView(item.word, ids.first, false),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
          child: Text(AppLocalizations.of(context)!
              .errorWithMessage(error.toString()))),
    );
  }

  Future<void> _rate(FlashcardRating rating) async {
    final notifier = ref.read(flashcardSessionProvider(widget.tag).notifier);
    await notifier.rate(rating, now: DateTime.now().toUtc());
  }

  Widget _buildSummary(FlashcardSessionState state) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, size: 72),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.sessionComplete,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(AppLocalizations.of(context)!
                  .cardsReviewed(state.items.length)),
              Text(AppLocalizations.of(context)!.minutesCount(
                  DateTime.now().difference(state.startedAt).inMinutes)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: [
                  for (final rating in FlashcardRating.values)
                    Chip(
                      label: Text(
                        "${_ratingLabel(rating)} ${state.ratings[rating]}",
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.pop(),
                child: Text(AppLocalizations.of(context)!.done),
              ),
            ],
          ),
        ),
      );

  String _ratingLabel(FlashcardRating rating) {
    final locale = AppLocalizations.of(context)!;
    return switch (rating) {
      FlashcardRating.again => locale.ratingAgain,
      FlashcardRating.hard => locale.ratingHard,
      FlashcardRating.good => locale.ratingGood,
      FlashcardRating.easy => locale.ratingEasy,
    };
  }
}
