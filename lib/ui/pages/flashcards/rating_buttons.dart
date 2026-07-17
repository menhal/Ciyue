import "package:ciyue/services/flashcard_scheduler.dart";
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
                child: Text(_label(rating)),
              ),
            ),
          ),
      ],
    );
  }

  String _label(FlashcardRating rating) => switch (rating) {
        FlashcardRating.again => "Again",
        FlashcardRating.hard => "Hard",
        FlashcardRating.good => "Good",
        FlashcardRating.easy => "Easy",
      };
}
