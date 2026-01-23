import 'chord.dart';
import 'instrument.dart';
import 'pitch_class.dart';
import 'voicing.dart';

/// Configuration options for voicing calculation.
class VoicingCalculatorOptions {
  /// Maximum fret span allowed (distance between lowest and highest fretted notes).
  ///
  /// Default is 4 frets, which is comfortable for most players.
  final int maxFretSpan;

  /// Maximum fret position to search.
  ///
  /// Default is 12 (one octave up the neck).
  final int maxFret;

  /// Minimum fret position to search.
  ///
  /// Default is 0 (open strings allowed).
  final int minFret;

  /// Whether to require the root note to be the bass (lowest) note.
  ///
  /// Default is true for standard chord voicings.
  final bool rootInBass;

  /// Whether to allow muted strings in the middle of the voicing.
  ///
  /// Default is true, but set to false for cleaner voicings.
  final bool allowInteriorMutes;

  /// Minimum number of strings that must be played.
  ///
  /// Default is 3 (minimum for a triad).
  final int minStringsPlayed;

  /// Maximum number of strings that can be muted.
  ///
  /// Default is 2.
  final int maxMutedStrings;

  /// Maximum number of fingers required to play the voicing.
  ///
  /// Default is 4 (standard for guitar playing).
  /// Accounts for barres (multiple strings at lowest fret = 1 finger).
  final int maxFingers;

  /// Filter by difficulty level.
  final VoicingDifficulty? maxDifficulty;

  /// Creates calculator options with defaults suitable for guitar.
  const VoicingCalculatorOptions({
    this.maxFretSpan = 4,
    this.maxFret = 12,
    this.minFret = 0,
    this.rootInBass = true,
    this.allowInteriorMutes = true,
    this.minStringsPlayed = 3,
    this.maxMutedStrings = 2,
    this.maxFingers = 4,
    this.maxDifficulty,
  });

  /// Options for beginner-friendly voicings.
  static const beginner = VoicingCalculatorOptions(
    maxFretSpan: 3,
    maxFret: 5,
    allowInteriorMutes: false,
    minStringsPlayed: 4,
    maxMutedStrings: 1,
    maxDifficulty: VoicingDifficulty.beginner,
  );

  /// Options for intermediate voicings.
  static const intermediate = VoicingCalculatorOptions(
    maxFret: 9,
    minStringsPlayed: 4,
    maxDifficulty: VoicingDifficulty.intermediate,
  );

  /// Options for advanced voicings (all possibilities).
  static const advanced = VoicingCalculatorOptions(
    maxFretSpan: 5,
    rootInBass: false,
    maxMutedStrings: 3,
  );
}

/// Calculates possible voicings for chords on instruments.
class VoicingCalculator {
  /// The instrument to calculate voicings for.
  final Instrument instrument;

  /// Options controlling the calculation.
  final VoicingCalculatorOptions options;

  /// Creates a voicing calculator for the given instrument.
  VoicingCalculator(this.instrument,
      {this.options = const VoicingCalculatorOptions()});

  /// Finds all valid voicings for the given chord.
  ///
  /// Returns voicings sorted by difficulty (easiest first).
  List<Voicing> findVoicings(Chord chord) {
    final chordPitches = chord.pitchClasses.toSet();
    final root = chord.root;

    // Include bass note as valid pitch for slash chords (e.g., A7/D includes D)
    final validPitches = Set<PitchClass>.from(chordPitches);
    if (chord.bassNote != null) {
      validPitches.add(chord.bassNote!);
    }

    // For each string, find all fret positions that produce chord tones
    final fretOptions = <List<int?>>[];
    for (var i = 0; i < instrument.stringCount; i++) {
      fretOptions.add(_findFretOptionsForString(i, validPitches));
    }

    // Generate all combinations
    final voicings = <Voicing>[];
    _generateCombinations(
      fretOptions,
      0,
      <int?>[],
      (combination) {
        final voicing = Voicing.fromFrets(combination);
        if (_isValidVoicing(voicing, chord, root)) {
          voicings.add(voicing);
        }
      },
    );

    // Deduplicate voicings with the same fretted shape
    // Keep the voicing with most played strings for each unique shape
    final deduped = _deduplicateVoicings(voicings);

    // Sort by difficulty
    deduped.sort((a, b) => a.difficultyScore.compareTo(b.difficultyScore));

    return deduped;
  }

  /// Deduplicates voicings that have the same "shape" (fretted positions).
  ///
  /// For voicings with identical fretted strings, keeps only the one that
  /// plays the most strings (fullest voicing).
  List<Voicing> _deduplicateVoicings(List<Voicing> voicings) {
    // Group by fretted shape (string index -> fret number for fretted strings only)
    final shapeMap = <String, Voicing>{};

    for (final voicing in voicings) {
      final shape = _getFrettedShape(voicing);

      if (!shapeMap.containsKey(shape) ||
          voicing.playedStringCount > shapeMap[shape]!.playedStringCount) {
        shapeMap[shape] = voicing;
      }
    }

    return shapeMap.values.toList();
  }

  /// Gets a string key representing the fretted positions of a voicing.
  ///
  /// Only includes strings that are fretted (not open or muted).
  String _getFrettedShape(Voicing voicing) {
    final parts = <String>[];
    for (var i = 0; i < voicing.positions.length; i++) {
      final pos = voicing.positions[i];
      if (pos.isFretted) {
        parts.add('$i:${pos.fret}');
      }
    }
    return parts.join(',');
  }

  /// Finds fret positions on a string that produce any of the given pitch classes.
  List<int?> _findFretOptionsForString(
      int stringIndex, Set<PitchClass> targets) {
    final options = <int?>[null]; // null = muted is always an option

    final maxFret = options.isEmpty
        ? this.options.maxFret
        : this.options.maxFret.clamp(
            0, instrument.strings[stringIndex].fretCount - instrument.capo);

    for (var fret = this.options.minFret; fret <= maxFret; fret++) {
      final pitch = instrument.soundingNoteAt(stringIndex, fret);
      if (targets.contains(pitch)) {
        options.add(fret);
      }
    }

    return options;
  }

  /// Recursively generates all combinations of fret positions.
  void _generateCombinations(
    List<List<int?>> fretOptions,
    int stringIndex,
    List<int?> current,
    void Function(List<int?>) onCombination,
  ) {
    if (stringIndex == fretOptions.length) {
      onCombination(List.from(current));
      return;
    }

    for (final fret in fretOptions[stringIndex]) {
      current.add(fret);
      _generateCombinations(
          fretOptions, stringIndex + 1, current, onCombination);
      current.removeLast();
    }
  }

  /// Checks if a voicing is valid according to options and musical rules.
  bool _isValidVoicing(Voicing voicing, Chord chord, PitchClass root) {
    // Check minimum strings played
    if (voicing.playedStringCount < options.minStringsPlayed) {
      return false;
    }

    // Check maximum muted strings
    if (voicing.mutedStringCount > options.maxMutedStrings) {
      return false;
    }

    // Check fret span
    if (voicing.fretSpan > options.maxFretSpan) {
      return false;
    }

    // Check maximum fingers required
    if (voicing.fingersRequired > options.maxFingers) {
      return false;
    }

    // Check interior mutes
    if (!options.allowInteriorMutes && _hasInteriorMutes(voicing)) {
      return false;
    }

    // Check difficulty
    if (options.maxDifficulty != null) {
      final difficultyIndex =
          VoicingDifficulty.values.indexOf(voicing.difficulty);
      final maxIndex = VoicingDifficulty.values.indexOf(options.maxDifficulty!);
      if (difficultyIndex > maxIndex) {
        return false;
      }
    }

    // Get the pitch classes played
    final playedPitches = voicing.pitchClassesOn(instrument);
    if (playedPitches.isEmpty) {
      return false;
    }

    // Must include the root
    if (!playedPitches.contains(root)) {
      return false;
    }

    // Determine required bass note: use slash chord bass note if present,
    // otherwise use root (if rootInBass option is enabled)
    final requiredBass = chord.bassNote;

    // Check bass note requirement
    if (requiredBass != null || options.rootInBass) {
      final expectedBass = requiredBass ?? root;
      // Find the first played string (lowest pitch = bass)
      for (var i = 0; i < voicing.positions.length; i++) {
        if (voicing.positions[i].isPlayed) {
          final bassPitch =
              instrument.soundingNoteAt(i, voicing.positions[i].fret!);
          if (bassPitch != expectedBass) {
            return false;
          }
          break;
        }
      }
    }

    // Build set of valid chord tones (chord pitches + bass note if slash chord)
    final chordTones = chord.pitchClasses.toSet();
    if (chord.bassNote != null) {
      chordTones.add(chord.bassNote!);
    }
    final uniquePitches = playedPitches.toSet();

    // All played notes must be chord tones (including bass note for slash chords)
    for (final pitch in playedPitches) {
      if (!chordTones.contains(pitch)) {
        return false;
      }
    }

    // All chord tones must be present in the voicing
    // This ensures Bm7b5 voicings include the b5, etc.
    // For slash chords, we require chord pitches but bass note presence
    // is already enforced above
    for (final chordTone in chord.pitchClasses) {
      if (!uniquePitches.contains(chordTone)) {
        return false;
      }
    }

    // Must have at least root and one other note (typically the 3rd)
    if (uniquePitches.length < 2) {
      return false;
    }

    return true;
  }

  /// Checks if the voicing has muted strings in the middle.
  bool _hasInteriorMutes(Voicing voicing) {
    var foundPlayed = false;
    var foundMutedAfterPlayed = false;

    for (final pos in voicing.positions) {
      if (pos.isPlayed) {
        if (foundMutedAfterPlayed) {
          return true; // Found played after muted after played
        }
        foundPlayed = true;
      } else if (foundPlayed) {
        foundMutedAfterPlayed = true;
      }
    }

    return false;
  }

  /// Finds voicings and returns them grouped by position on the neck.
  Map<int, List<Voicing>> findVoicingsGroupedByPosition(Chord chord) {
    final voicings = findVoicings(chord);
    final grouped = <int, List<Voicing>>{};

    for (final voicing in voicings) {
      final position = voicing.lowestFret ?? 0;
      grouped.putIfAbsent(position, () => []).add(voicing);
    }

    return grouped;
  }

  /// Finds the N easiest voicings for a chord.
  List<Voicing> findEasiestVoicings(Chord chord, {int limit = 5}) {
    final voicings = findVoicings(chord);
    return voicings.take(limit).toList();
  }
}

/// Extension for convenient voicing calculation on Chord.
extension ChordVoicingExtension on Chord {
  /// Finds all voicings for this chord on the given instrument.
  List<Voicing> voicingsOn(
    Instrument instrument, {
    VoicingCalculatorOptions options = const VoicingCalculatorOptions(),
  }) {
    return VoicingCalculator(instrument, options: options).findVoicings(this);
  }

  /// Finds the easiest voicings for this chord on the given instrument.
  ///
  /// Uses intermediate difficulty options to include common chord shapes
  /// like C major (X32010) which are classified as intermediate.
  List<Voicing> easyVoicingsOn(Instrument instrument, {int limit = 5}) {
    return VoicingCalculator(
      instrument,
      options: VoicingCalculatorOptions.intermediate,
    ).findEasiestVoicings(this, limit: limit);
  }
}
