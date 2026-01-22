import 'chord.dart';
import 'instrument.dart';
import 'pitch_class.dart';

/// Represents the position of a finger on a single string.
///
/// A string can be:
/// - Muted (not played): [fret] is null
/// - Open (played unfretted): [fret] is 0
/// - Fretted: [fret] is 1 or higher
class StringPosition {
  /// The fret number, or null if the string is muted.
  ///
  /// - null = muted (X)
  /// - 0 = open string (O)
  /// - 1+ = fretted position
  final int? fret;

  /// The finger used to fret this position (1-4), or null if not specified.
  ///
  /// - 1 = index finger
  /// - 2 = middle finger
  /// - 3 = ring finger
  /// - 4 = pinky
  /// - null = not specified or open/muted
  final int? finger;

  /// Creates a string position.
  const StringPosition({this.fret, this.finger});

  /// Creates a muted string position.
  const StringPosition.muted()
      : fret = null,
        finger = null;

  /// Creates an open string position.
  const StringPosition.open()
      : fret = 0,
        finger = null;

  /// Creates a fretted string position.
  const StringPosition.fretted(int fretNumber, {this.finger})
      : fret = fretNumber;

  /// Whether this string is muted (not played).
  bool get isMuted => fret == null;

  /// Whether this string is played open (unfretted).
  bool get isOpen => fret == 0;

  /// Whether this string is fretted.
  bool get isFretted => fret != null && fret! > 0;

  /// Whether this string is played (not muted).
  bool get isPlayed => fret != null;

  @override
  String toString() {
    if (isMuted) return 'X';
    if (isOpen) return 'O';
    return fret.toString();
  }

  @override
  bool operator ==(Object other) =>
      other is StringPosition && other.fret == fret && other.finger == finger;

  @override
  int get hashCode => Object.hash(fret, finger);
}

/// Represents a barre (one finger pressing multiple strings).
class Barre {
  /// The fret where the barre is placed.
  final int fret;

  /// The index of the first (lowest) string covered by the barre.
  final int fromString;

  /// The index of the last (highest) string covered by the barre.
  final int toIndex;

  /// The finger used for the barre (usually 1 for index finger).
  final int finger;

  /// Creates a barre.
  const Barre({
    required this.fret,
    required this.fromString,
    required this.toIndex,
    this.finger = 1,
  });

  /// Number of strings covered by this barre.
  int get stringCount => toIndex - fromString + 1;

  @override
  String toString() => 'Barre(fret: $fret, strings: $fromString-$toIndex)';

  @override
  bool operator ==(Object other) =>
      other is Barre &&
      other.fret == fret &&
      other.fromString == fromString &&
      other.toIndex == toIndex &&
      other.finger == finger;

  @override
  int get hashCode => Object.hash(fret, fromString, toIndex, finger);
}

/// Difficulty level for chord voicings.
enum VoicingDifficulty {
  /// Easy voicings - open chords, few frets, no barres.
  beginner,

  /// Medium voicings - may include barres or wider stretches.
  intermediate,

  /// Hard voicings - complex fingerings, large stretches, high positions.
  advanced,
}

/// A specific way to play a chord on an instrument.
///
/// A voicing defines the exact fret positions for each string,
/// optional finger assignments, and any barre information.
///
/// ```dart
/// // Am chord voicing for guitar
/// final am = Voicing(
///   positions: [
///     StringPosition.muted(),      // E string - muted
///     StringPosition.open(),        // A string - open
///     StringPosition.fretted(2),    // D string - 2nd fret
///     StringPosition.fretted(2),    // G string - 2nd fret
///     StringPosition.fretted(1),    // B string - 1st fret
///     StringPosition.open(),        // e string - open
///   ],
/// );
/// ```
class Voicing {
  /// The fret positions for each string, from lowest to highest.
  final List<StringPosition> positions;

  /// Optional barre information.
  final Barre? barre;

  /// Creates a voicing with the given positions.
  const Voicing({
    required this.positions,
    this.barre,
  });

  /// Creates a voicing from a list of fret numbers.
  ///
  /// Use -1 or null for muted strings, 0 for open strings.
  factory Voicing.fromFrets(List<int?> frets, {Barre? barre}) {
    return Voicing(
      positions: frets
          .map((f) => f == null || f < 0
              ? const StringPosition.muted()
              : StringPosition(fret: f))
          .toList(),
      barre: barre,
    );
  }

  /// Parses a voicing from a string like "X02210" or "X-0-2-2-1-0".
  ///
  /// - 'X' or 'x' = muted
  /// - '0' or 'O' or 'o' = open
  /// - Numbers = fret position
  /// - Delimiter can be '-' or space for multi-digit frets
  factory Voicing.parse(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('Empty voicing string');
    }

    List<int?> frets;

    // Check if it uses delimiters (for multi-digit frets)
    if (trimmed.contains('-') || trimmed.contains(' ')) {
      final parts = trimmed.split(RegExp(r'[-\s]+'));
      frets = parts.map(_parseFretPart).toList();
    } else {
      // Single characters
      frets = trimmed.split('').map(_parseFretPart).toList();
    }

    return Voicing.fromFrets(frets);
  }

  static int? _parseFretPart(String part) {
    final lower = part.toLowerCase();
    if (lower == 'x') return null;
    if (lower == 'o') return 0;
    return int.tryParse(part);
  }

  /// Number of strings in this voicing.
  int get stringCount => positions.length;

  /// Number of strings that are played (not muted).
  int get playedStringCount => positions.where((p) => p.isPlayed).length;

  /// Number of strings that are muted.
  int get mutedStringCount => positions.where((p) => p.isMuted).length;

  /// Number of strings that are fretted (not open or muted).
  int get frettedStringCount => positions.where((p) => p.isFretted).length;

  /// The lowest fret used (excluding open strings), or null if all open/muted.
  int? get lowestFret {
    final fretted = positions.where((p) => p.isFretted).map((p) => p.fret!);
    return fretted.isEmpty ? null : fretted.reduce((a, b) => a < b ? a : b);
  }

  /// The highest fret used, or null if all open/muted.
  int? get highestFret {
    final fretted = positions.where((p) => p.isFretted).map((p) => p.fret!);
    return fretted.isEmpty ? null : fretted.reduce((a, b) => a > b ? a : b);
  }

  /// The fret span (difference between highest and lowest fret).
  ///
  /// Returns 0 if there's only one fretted position or none.
  int get fretSpan {
    final low = lowestFret;
    final high = highestFret;
    if (low == null || high == null) return 0;
    return high - low;
  }

  /// Whether this voicing requires a barre.
  bool get requiresBarre => barre != null;

  /// Whether this voicing uses only open strings (no fretted notes).
  bool get isAllOpen => positions.every((p) => p.isOpen || p.isMuted);

  /// Calculates a difficulty score for this voicing.
  ///
  /// Lower scores are easier. Factors include:
  /// - Fret span (wider = harder)
  /// - Number of fretted strings
  /// - Presence of barres
  /// - Position on neck (higher = harder)
  /// - Muted strings in the middle (harder to mute)
  int get difficultyScore {
    var score = 0;

    // Fret span penalty (wider stretch = harder)
    score += fretSpan * 10;

    // Number of fingers needed
    score += frettedStringCount * 5;

    // Barre penalty
    if (requiresBarre) {
      score += 20;
      if (barre!.stringCount > 4) score += 10; // Full barre is harder
    }

    // Position penalty (higher frets = harder to reach)
    final low = lowestFret;
    if (low != null && low > 5) {
      score += (low - 5) * 3;
    }

    // Muted interior strings penalty (harder to mute middle strings)
    for (var i = 1; i < positions.length - 1; i++) {
      if (positions[i].isMuted &&
          positions.sublist(0, i).any((p) => p.isPlayed) &&
          positions.sublist(i + 1).any((p) => p.isPlayed)) {
        score += 15;
      }
    }

    // Open chord bonus (easier)
    if (lowestFret == null || lowestFret == 1) {
      final openCount = positions.where((p) => p.isOpen).length;
      score -= openCount * 3;
    }

    return score < 0 ? 0 : score;
  }

  /// Returns the difficulty level based on the difficulty score.
  VoicingDifficulty get difficulty {
    final score = difficultyScore;
    if (score <= 25) return VoicingDifficulty.beginner;
    if (score <= 50) return VoicingDifficulty.intermediate;
    return VoicingDifficulty.advanced;
  }

  /// Estimates the number of fingers required to play this voicing.
  ///
  /// Accounts for potential barres: if multiple strings at the lowest fret
  /// could reasonably be barred together (no overriding frets in between),
  /// they count as one finger.
  ///
  /// Returns the estimated finger count (1-6 for guitar).
  int get fingersRequired {
    // Group fretted positions by fret number
    final fretPositions = <int, List<int>>{};
    for (var i = 0; i < positions.length; i++) {
      final pos = positions[i];
      if (pos.isFretted) {
        fretPositions.putIfAbsent(pos.fret!, () => []).add(i);
      }
    }

    if (fretPositions.isEmpty) return 0;

    // Find the lowest fret
    final sortedFrets = fretPositions.keys.toList()..sort();
    final lowestFret = sortedFrets.first;
    final stringsAtLowest = fretPositions[lowestFret]!..sort();

    var fingers = 0;

    // Check if lowest fret could be a valid barre (2+ strings, no overrides)
    var canBarre = stringsAtLowest.length >= 2;
    if (canBarre) {
      final fromString = stringsAtLowest.first;
      final toStringIndex = stringsAtLowest.last;

      // Check that no string in the barre range has a higher fret
      for (var s = fromString; s <= toStringIndex; s++) {
        final pos = positions[s];
        if (pos.isFretted && pos.fret! > lowestFret) {
          // A string in the barre range is fretted higher - not a valid barre
          canBarre = false;
          break;
        }
      }
    }

    if (canBarre) {
      // Valid barre - counts as 1 finger
      fingers = 1;
    } else {
      // No valid barre - each string at lowest fret needs its own finger
      fingers = stringsAtLowest.length;
    }

    // Count remaining frets (each string at a higher fret = 1 finger)
    for (var i = 1; i < sortedFrets.length; i++) {
      final fret = sortedFrets[i];
      final stringsAtFret = fretPositions[fret]!;
      fingers += stringsAtFret.length;
    }

    return fingers;
  }

  /// Returns the pitch classes being played in this voicing on the given instrument.
  List<PitchClass> pitchClassesOn(Instrument instrument) {
    if (positions.length != instrument.stringCount) {
      throw ArgumentError(
        'Voicing has ${positions.length} positions but instrument has ${instrument.stringCount} strings',
      );
    }

    final pitches = <PitchClass>[];
    for (var i = 0; i < positions.length; i++) {
      final pos = positions[i];
      if (pos.isPlayed) {
        pitches.add(instrument.soundingNoteAt(i, pos.fret!));
      }
    }
    return pitches;
  }

  /// Checks if this voicing plays the given chord on the instrument.
  ///
  /// Returns true if:
  /// - All played notes are chord tones (no wrong notes)
  /// - All chord tones are present in the voicing
  /// - The root note is present
  bool playsChord(Chord chord, Instrument instrument) {
    final voicingPitches = pitchClassesOn(instrument).toSet();
    final chordPitches = chord.pitchClasses.toSet();

    // All played notes must be in the chord (no wrong notes)
    if (!voicingPitches.every(chordPitches.contains)) {
      return false;
    }

    // All chord notes must be present in the voicing
    if (!chordPitches.every(voicingPitches.contains)) {
      return false;
    }

    // Must have the root
    if (!voicingPitches.contains(chord.root)) {
      return false;
    }

    return true;
  }

  /// Returns a compact string representation like "X02210".
  String toCompactString() {
    return positions.map((p) {
      if (p.isMuted) return 'X';
      if (p.fret! >= 10) return '(${p.fret})';
      return p.fret.toString();
    }).join();
  }

  @override
  String toString() => toCompactString();

  @override
  bool operator ==(Object other) =>
      other is Voicing &&
      _listEquals(other.positions, positions) &&
      other.barre == barre;

  @override
  int get hashCode => Object.hash(Object.hashAll(positions), barre);
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
