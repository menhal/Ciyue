import "package:ciyue/services/flashcard_scheduler.dart";
import "package:ciyue/src/generated/i18n/app_localizations.dart";
import "package:flutter/material.dart";

class FlashcardRatingButtons extends StatelessWidget {
  final ValueChanged<FlashcardRating> onSelected;

  const FlashcardRatingButtons({
    super.key,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final rating in FlashcardRating.values)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: FilledButton.tonal(
                onPressed: () => onSelected(rating),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                ),
                child: Text(_label(context, rating)),
              ),
            ),
          ),
      ],
    );
  }

  String _label(BuildContext context, FlashcardRating rating) {
    final locale = AppLocalizations.of(context)!;
    return switch (rating) {
      FlashcardRating.again => locale.ratingAgain,
      FlashcardRating.hard => locale.ratingHard,
      FlashcardRating.good => locale.ratingGood,
      FlashcardRating.easy => locale.ratingEasy,
    };
  }
}
