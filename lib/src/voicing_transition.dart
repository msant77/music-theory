import 'voicing.dart';

/// Preference for voicing selection.
enum VoicingPreference {
  /// Prefer open chord voicings when available.
  preferOpen,

  /// Prefer barre chord voicings when available.
  preferBarre,

  /// Balance between open and barre based on context.
  balanced,
}

/// A voicing with its ranking information for context-aware selection.
class RankedVoicing {
  /// The voicing being ranked.
  final Voicing voicing;

  /// Original index in the candidate list.
  final int originalIndex;

  /// Total transition cost (lower = easier transition).
  final int transitionCost;

  /// Whether this voicing is the suggested choice.
  final bool isSuggested;

  const RankedVoicing({
    required this.voicing,
    required this.originalIndex,
    required this.transitionCost,
    required this.isSuggested,
  });

  @override
  String toString() =>
      'RankedVoicing(index: $originalIndex, cost: $transitionCost, suggested: $isSuggested)';
}

/// Calculates transition costs between voicings for context-aware selection.
///
/// The transition cost represents how difficult it is to move from one
/// voicing to another. Lower costs indicate easier transitions.
class VoicingTransition {
  /// Calculate the transition cost between two voicings.
  ///
  /// Returns a non-negative integer where lower values indicate
  /// easier transitions. Factors considered:
  /// - Fret position difference (center of gravity)
  /// - Per-string fret distance changes
  /// - Barre state changes
  /// - Shape similarity bonus
  ///
  /// Returns 0 if either voicing is null.
  static int calculateCost(Voicing? from, Voicing? to) {
    if (from == null || to == null) return 0;

    int cost = 0;

    // 1. Position difference (0-120 points)
    // Measures how far the hand needs to move along the neck
    final fromCenter = from.lowestFret ?? 0;
    final toCenter = to.lowestFret ?? 0;
    cost += (fromCenter - toCenter).abs() * 10;

    // 2. Per-string changes (0-36 points for 6 strings)
    // Measures individual finger movement requirements
    final minStrings = from.stringCount < to.stringCount
        ? from.stringCount
        : to.stringCount;
    for (int i = 0; i < minStrings; i++) {
      final fromPos = from.positions[i];
      final toPos = to.positions[i];

      if (fromPos.isFretted && toPos.isFretted) {
        // Both fretted: add cost based on fret difference
        cost += (fromPos.fret! - toPos.fret!).abs() * 2;
      } else if (fromPos.isFretted != toPos.isFretted) {
        // One fretted, one not: finger state change
        cost += 3;
      }
      // Both open or both muted: no additional cost
    }

    // 3. Barre transition penalty (+15)
    // Changing barre state is more difficult than maintaining it
    if (from.requiresBarre != to.requiresBarre) {
      cost += 15;
    }

    // 4. Shape similarity bonus (-5)
    // Similar shapes are easier to transition between
    if (_hasSimilarShape(from, to)) {
      cost -= 5;
    }

    return cost < 0 ? 0 : cost;
  }

  /// Check if two voicings have similar shapes.
  ///
  /// Similar shapes have comparable fret spans and finger counts.
  static bool _hasSimilarShape(Voicing from, Voicing to) {
    final spanDiff = (from.fretSpan - to.fretSpan).abs();
    final fingerDiff = (from.fingersRequired - to.fingersRequired).abs();
    return spanDiff <= 1 && fingerDiff <= 1;
  }

  /// Rank voicings based on transition context.
  ///
  /// Returns candidates ranked by transition cost, with the best
  /// option marked as suggested.
  ///
  /// Parameters:
  /// - [previousVoicing]: The voicing being transitioned from (null if first chord)
  /// - [nextVoicing]: The voicing being transitioned to (null if last chord)
  /// - [candidates]: List of possible voicings to choose from
  /// - [preference]: User preference for open vs barre voicings
  ///
  /// The ranking considers:
  /// 1. Transition cost from previous voicing (weighted 60%)
  /// 2. Transition cost to next voicing (weighted 40%)
  /// 3. User preference adjustments
  /// 4. Difficulty as tiebreaker
  static List<RankedVoicing> rankVoicings({
    required Voicing? previousVoicing,
    required Voicing? nextVoicing,
    required List<Voicing> candidates,
    VoicingPreference preference = VoicingPreference.balanced,
  }) {
    if (candidates.isEmpty) return [];

    final ranked = <_ScoredVoicing>[];

    for (int i = 0; i < candidates.length; i++) {
      final voicing = candidates[i];

      // Calculate weighted transition costs
      final costFromPrevious = calculateCost(previousVoicing, voicing);
      final costToNext = calculateCost(voicing, nextVoicing);

      // Weight: previous matters more (60/40) since it's known
      int score = (costFromPrevious * 0.6 + costToNext * 0.4).round();

      // Apply preference adjustments
      score += _preferenceAdjustment(voicing, preference);

      // Use difficulty as minor factor (0-10 points)
      score += voicing.difficultyScore ~/ 10;

      ranked.add(_ScoredVoicing(
        voicing: voicing,
        originalIndex: i,
        score: score,
      ));
    }

    // Sort by score (lower is better)
    ranked.sort((a, b) => a.score.compareTo(b.score));

    // Mark the best as suggested
    return ranked.asMap().entries.map((entry) {
      return RankedVoicing(
        voicing: entry.value.voicing,
        originalIndex: entry.value.originalIndex,
        transitionCost: entry.value.score,
        isSuggested: entry.key == 0,
      );
    }).toList();
  }

  /// Get preference adjustment for a voicing.
  static int _preferenceAdjustment(Voicing voicing, VoicingPreference pref) {
    switch (pref) {
      case VoicingPreference.preferOpen:
        return voicing.requiresBarre ? 30 : -15;
      case VoicingPreference.preferBarre:
        return voicing.requiresBarre ? -15 : 25;
      case VoicingPreference.balanced:
        return 0;
    }
  }

  /// Find the suggested voicing index from a list of candidates.
  ///
  /// Convenience method that returns just the index of the best voicing.
  /// Returns 0 if candidates is empty.
  static int suggestedIndex({
    required Voicing? previousVoicing,
    required Voicing? nextVoicing,
    required List<Voicing> candidates,
    VoicingPreference preference = VoicingPreference.balanced,
  }) {
    final ranked = rankVoicings(
      previousVoicing: previousVoicing,
      nextVoicing: nextVoicing,
      candidates: candidates,
      preference: preference,
    );
    if (ranked.isEmpty) return 0;

    // Find the RankedVoicing marked as suggested and return its original index
    final suggested = ranked.firstWhere((r) => r.isSuggested);
    return suggested.originalIndex;
  }

  /// Categorize transition difficulty based on cost.
  ///
  /// Returns a difficulty category for UI coloring:
  /// - easy: cost < 20
  /// - medium: cost 20-50
  /// - hard: cost > 50
  static TransitionDifficulty categorizeCost(int cost) {
    if (cost < 20) return TransitionDifficulty.easy;
    if (cost <= 50) return TransitionDifficulty.medium;
    return TransitionDifficulty.hard;
  }
}

/// Difficulty category for chord transitions.
enum TransitionDifficulty {
  /// Easy transition (cost < 20).
  easy,

  /// Medium transition (cost 20-50).
  medium,

  /// Hard transition (cost > 50).
  hard,
}

/// Internal class for scoring during ranking.
class _ScoredVoicing {
  final Voicing voicing;
  final int originalIndex;
  final int score;

  _ScoredVoicing({
    required this.voicing,
    required this.originalIndex,
    required this.score,
  });
}
