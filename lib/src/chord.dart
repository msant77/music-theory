import 'interval.dart';
import 'note.dart';
import 'pitch_class.dart';

/// A chord type defined by its intervals from the root.
///
/// Each chord type has a name, symbol, and list of intervals that
/// define the chord's structure.
class ChordType {
  /// The full name of the chord type (e.g., "major", "minor seventh").
  final String name;

  /// The symbol used in chord notation (e.g., "", "m", "7", "maj7").
  final String symbol;

  /// The intervals from the root that define this chord.
  final List<Interval> intervals;

  /// Creates a chord type with the given name, symbol, and intervals.
  const ChordType({
    required this.name,
    required this.symbol,
    required this.intervals,
  });

  // ==================== Triads ====================

  /// Major triad: R, M3, P5
  static const ChordType major = ChordType(
    name: 'major',
    symbol: '',
    intervals: [
      Interval.perfectUnison,
      Interval.majorThird,
      Interval.perfectFifth
    ],
  );

  /// Minor triad: R, m3, P5
  static const ChordType minor = ChordType(
    name: 'minor',
    symbol: 'm',
    intervals: [
      Interval.perfectUnison,
      Interval.minorThird,
      Interval.perfectFifth
    ],
  );

  /// Diminished triad: R, m3, d5
  static const ChordType diminished = ChordType(
    name: 'diminished',
    symbol: 'dim',
    intervals: [
      Interval.perfectUnison,
      Interval.minorThird,
      Interval.diminishedFifth
    ],
  );

  /// Augmented triad: R, M3, A5
  static const ChordType augmented = ChordType(
    name: 'augmented',
    symbol: 'aug',
    intervals: [
      Interval.perfectUnison,
      Interval.majorThird,
      Interval(semitones: 8, quality: IntervalQuality.augmented, number: 5),
    ],
  );

  /// Suspended 2nd: R, M2, P5
  static const ChordType sus2 = ChordType(
    name: 'suspended 2nd',
    symbol: 'sus2',
    intervals: [
      Interval.perfectUnison,
      Interval.majorSecond,
      Interval.perfectFifth
    ],
  );

  /// Suspended 4th: R, P4, P5
  static const ChordType sus4 = ChordType(
    name: 'suspended 4th',
    symbol: 'sus4',
    intervals: [
      Interval.perfectUnison,
      Interval.perfectFourth,
      Interval.perfectFifth
    ],
  );

  // ==================== Seventh Chords ====================

  /// Dominant 7th: R, M3, P5, m7
  static const ChordType dominant7 = ChordType(
    name: 'dominant 7th',
    symbol: '7',
    intervals: [
      Interval.perfectUnison,
      Interval.majorThird,
      Interval.perfectFifth,
      Interval.minorSeventh,
    ],
  );

  /// Major 7th: R, M3, P5, M7
  static const ChordType major7 = ChordType(
    name: 'major 7th',
    symbol: 'maj7',
    intervals: [
      Interval.perfectUnison,
      Interval.majorThird,
      Interval.perfectFifth,
      Interval.majorSeventh,
    ],
  );

  /// Minor 7th: R, m3, P5, m7
  static const ChordType minor7 = ChordType(
    name: 'minor 7th',
    symbol: 'm7',
    intervals: [
      Interval.perfectUnison,
      Interval.minorThird,
      Interval.perfectFifth,
      Interval.minorSeventh,
    ],
  );

  /// Minor major 7th: R, m3, P5, M7
  static const ChordType minorMajor7 = ChordType(
    name: 'minor major 7th',
    symbol: 'mMaj7',
    intervals: [
      Interval.perfectUnison,
      Interval.minorThird,
      Interval.perfectFifth,
      Interval.majorSeventh,
    ],
  );

  /// Diminished 7th: R, m3, d5, d7 (d7 = 9 semitones)
  static const ChordType diminished7 = ChordType(
    name: 'diminished 7th',
    symbol: 'dim7',
    intervals: [
      Interval.perfectUnison,
      Interval.minorThird,
      Interval.diminishedFifth,
      Interval(semitones: 9, quality: IntervalQuality.diminished, number: 7),
    ],
  );

  /// Half-diminished 7th (minor 7 flat 5): R, m3, d5, m7
  static const ChordType halfDiminished7 = ChordType(
    name: 'half-diminished 7th',
    symbol: 'm7b5',
    intervals: [
      Interval.perfectUnison,
      Interval.minorThird,
      Interval.diminishedFifth,
      Interval.minorSeventh,
    ],
  );

  /// Augmented 7th: R, M3, A5, m7
  static const ChordType augmented7 = ChordType(
    name: 'augmented 7th',
    symbol: 'aug7',
    intervals: [
      Interval.perfectUnison,
      Interval.majorThird,
      Interval(semitones: 8, quality: IntervalQuality.augmented, number: 5),
      Interval.minorSeventh,
    ],
  );

  // ==================== Extended Chords ====================

  /// Add 9: R, M3, P5, M9
  static const ChordType add9 = ChordType(
    name: 'add 9',
    symbol: 'add9',
    intervals: [
      Interval.perfectUnison,
      Interval.majorThird,
      Interval.perfectFifth,
      Interval(semitones: 14, quality: IntervalQuality.major, number: 9),
    ],
  );

  /// Minor add 9: R, m3, P5, M9
  static const ChordType minorAdd9 = ChordType(
    name: 'minor add 9',
    symbol: 'madd9',
    intervals: [
      Interval.perfectUnison,
      Interval.minorThird,
      Interval.perfectFifth,
      Interval(semitones: 14, quality: IntervalQuality.major, number: 9),
    ],
  );

  /// Dominant 9th: R, M3, P5, m7, M9
  static const ChordType dominant9 = ChordType(
    name: 'dominant 9th',
    symbol: '9',
    intervals: [
      Interval.perfectUnison,
      Interval.majorThird,
      Interval.perfectFifth,
      Interval.minorSeventh,
      Interval(semitones: 14, quality: IntervalQuality.major, number: 9),
    ],
  );

  /// Major 9th: R, M3, P5, M7, M9
  static const ChordType major9 = ChordType(
    name: 'major 9th',
    symbol: 'maj9',
    intervals: [
      Interval.perfectUnison,
      Interval.majorThird,
      Interval.perfectFifth,
      Interval.majorSeventh,
      Interval(semitones: 14, quality: IntervalQuality.major, number: 9),
    ],
  );

  /// Minor 9th: R, m3, P5, m7, M9
  static const ChordType minor9 = ChordType(
    name: 'minor 9th',
    symbol: 'm9',
    intervals: [
      Interval.perfectUnison,
      Interval.minorThird,
      Interval.perfectFifth,
      Interval.minorSeventh,
      Interval(semitones: 14, quality: IntervalQuality.major, number: 9),
    ],
  );

  // ==================== Altered Dominant Chords ====================

  /// Dominant 7 flat 9: R, M3, P5, m7, m9
  static const ChordType dominant7b9 = ChordType(
    name: 'dominant 7 flat 9',
    symbol: '7b9',
    intervals: [
      Interval.perfectUnison,
      Interval.majorThird,
      Interval.perfectFifth,
      Interval.minorSeventh,
      Interval(semitones: 13, quality: IntervalQuality.minor, number: 9),
    ],
  );

  /// Dominant 7 sharp 9: R, M3, P5, m7, A9
  static const ChordType dominant7sharp9 = ChordType(
    name: 'dominant 7 sharp 9',
    symbol: '7#9',
    intervals: [
      Interval.perfectUnison,
      Interval.majorThird,
      Interval.perfectFifth,
      Interval.minorSeventh,
      Interval(semitones: 15, quality: IntervalQuality.augmented, number: 9),
    ],
  );

  /// Dominant 7 flat 13: R, M3, P5, m7, m13
  static const ChordType dominant7b13 = ChordType(
    name: 'dominant 7 flat 13',
    symbol: '7b13',
    intervals: [
      Interval.perfectUnison,
      Interval.majorThird,
      Interval.perfectFifth,
      Interval.minorSeventh,
      Interval(semitones: 20, quality: IntervalQuality.minor, number: 13),
    ],
  );

  /// Dominant 7 sharp 11: R, M3, P5, m7, A11
  static const ChordType dominant7sharp11 = ChordType(
    name: 'dominant 7 sharp 11',
    symbol: '7#11',
    intervals: [
      Interval.perfectUnison,
      Interval.majorThird,
      Interval.perfectFifth,
      Interval.minorSeventh,
      Interval(semitones: 18, quality: IntervalQuality.augmented, number: 11),
    ],
  );

  /// Dominant 11th: R, M3, P5, m7, M9, P11
  static const ChordType dominant11 = ChordType(
    name: 'dominant 11th',
    symbol: '11',
    intervals: [
      Interval.perfectUnison,
      Interval.majorThird,
      Interval.perfectFifth,
      Interval.minorSeventh,
      Interval(semitones: 14, quality: IntervalQuality.major, number: 9),
      Interval(semitones: 17, quality: IntervalQuality.perfect, number: 11),
    ],
  );

  /// Dominant 13th: R, M3, P5, m7, M9, M13
  static const ChordType dominant13 = ChordType(
    name: 'dominant 13th',
    symbol: '13',
    intervals: [
      Interval.perfectUnison,
      Interval.majorThird,
      Interval.perfectFifth,
      Interval.minorSeventh,
      Interval(semitones: 14, quality: IntervalQuality.major, number: 9),
      Interval(semitones: 21, quality: IntervalQuality.major, number: 13),
    ],
  );

  // ==================== Sixth Chords ====================

  /// Major 6th: R, M3, P5, M6
  static const ChordType major6 = ChordType(
    name: 'major 6th',
    symbol: '6',
    intervals: [
      Interval.perfectUnison,
      Interval.majorThird,
      Interval.perfectFifth,
      Interval.majorSixth,
    ],
  );

  /// Minor 6th: R, m3, P5, M6
  static const ChordType minor6 = ChordType(
    name: 'minor 6th',
    symbol: 'm6',
    intervals: [
      Interval.perfectUnison,
      Interval.minorThird,
      Interval.perfectFifth,
      Interval.majorSixth,
    ],
  );

  /// Major 6/9: R, M3, P5, M6, M9
  static const ChordType sixNine = ChordType(
    name: 'major 6/9',
    symbol: '6/9',
    intervals: [
      Interval.perfectUnison,
      Interval.majorThird,
      Interval.perfectFifth,
      Interval.majorSixth,
      Interval(semitones: 14, quality: IntervalQuality.major, number: 9),
    ],
  );

  // ==================== Power Chord ====================

  /// Power chord (5th): R, P5
  static const ChordType power = ChordType(
    name: 'power chord',
    symbol: '5',
    intervals: [Interval.perfectUnison, Interval.perfectFifth],
  );

  // ==================== All Chord Types ====================

  /// All standard chord types.
  static const List<ChordType> all = [
    major,
    minor,
    diminished,
    augmented,
    sus2,
    sus4,
    dominant7,
    major7,
    minor7,
    minorMajor7,
    diminished7,
    halfDiminished7,
    augmented7,
    add9,
    minorAdd9,
    dominant9,
    major9,
    minor9,
    dominant7b9,
    dominant7sharp9,
    dominant7b13,
    dominant7sharp11,
    dominant11,
    dominant13,
    major6,
    minor6,
    sixNine,
    power,
  ];

  /// The number of notes in this chord type.
  int get noteCount => intervals.length;

  /// Whether this is a triad (3 notes).
  bool get isTriad => noteCount == 3;

  /// Whether this is a seventh chord (4 notes with a 7th).
  bool get isSeventh => intervals.any((i) => i.number == 7);

  /// Whether this is an extended chord (9th, 11th, 13th).
  bool get isExtended => intervals.any((i) => i.number >= 9);

  @override
  bool operator ==(Object other) =>
      other is ChordType && other.name == name && other.symbol == symbol;

  @override
  int get hashCode => Object.hash(name, symbol);

  @override
  String toString() => name;
}

/// A chord with a root note and chord type.
///
/// ```dart
/// final cMajor = Chord(PitchClass.c, ChordType.major);
/// final am7 = Chord.parse('Am7');
/// print(am7.notes); // [A, C, E, G]
/// ```
class Chord {
  /// The root note of the chord.
  final PitchClass root;

  /// The type of chord (major, minor, etc.).
  final ChordType type;

  /// The bass note for slash chords (e.g., G in "C/G"), or null for regular chords.
  final PitchClass? bassNote;

  /// Creates a chord with the given root and type.
  const Chord(this.root, this.type, {this.bassNote});

  /// Parses a chord from a string like "C", "Am", "G7", "Fmaj7", "Bb".
  ///
  /// Supported formats:
  /// - Root note: C, D, E, F, G, A, B (with optional # or b)
  /// - Major: C, Cmaj, CM
  /// - Minor: Cm, Cmin, C-
  /// - Diminished: Cdim, C°
  /// - Augmented: Caug, C+
  /// - Suspended: Csus2, Csus4, Csus
  /// - Seventh: C7, Cmaj7, CM7, Cm7, Cmin7, Cdim7, C°7
  /// - Half-diminished: Cm7b5, Cø, Cø7, Cm7(b5)
  /// - Extended: C9, Cmaj9, Cm9, Cadd9
  /// - Sixth: C6, Cm6
  /// - Power: C5
  /// - Slash chords: C/G, Am/E, G/B
  ///
  /// Throws [FormatException] if the chord cannot be parsed.
  factory Chord.parse(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('Empty chord string');
    }

    // Check for slash chord (bass note)
    // Find the last '/' that is NOT inside parentheses, so that
    // compound intervals like (6/9) are preserved.
    PitchClass? bassNote;
    var chordPart = trimmed;

    var slashIndex = -1;
    var parenDepth = 0;
    for (var ci = trimmed.length - 1; ci >= 0; ci--) {
      final ch = trimmed[ci];
      if (ch == ')') {
        parenDepth++;
      } else if (ch == '(') {
        parenDepth--;
      } else if (ch == '/' && parenDepth == 0) {
        slashIndex = ci;
        break;
      }
    }
    if (slashIndex > 0) {
      final bassStr = trimmed.substring(slashIndex + 1);
      try {
        bassNote = PitchClass.parse(bassStr);
        chordPart = trimmed.substring(0, slashIndex);
      } on FormatException {
        // Not a valid bass note, treat as part of chord type
      }
    }

    // Parse root note
    var index = 1;
    if (chordPart.length > 1 && (chordPart[1] == '#' || chordPart[1] == 'b')) {
      index = 2;
    }

    final rootStr = chordPart.substring(0, index);
    final root = PitchClass.parse(rootStr);
    var suffix = chordPart.substring(index);

    // Normalize Brazilian notation before stripping parentheses:
    // (5-) → (b5), (9+) → (#9), 7M → M7
    suffix = suffix.replaceAllMapped(
      RegExp(r'\((\d+)-\)'),
      (m) => '(b${m[1]})',
    );
    suffix = suffix.replaceAllMapped(
      RegExp(r'\((\d+)\+\)'),
      (m) => '(#${m[1]})',
    );
    // 7M → M7 (Brazilian major 7 shorthand), but not mmaj7 etc.
    if (suffix.contains('7M') && !suffix.contains('maj')) {
      suffix = suffix.replaceFirst('7M', 'M7');
    }

    // Handle parentheses alterations: convert Cm7(b5) to Cm7b5
    suffix = suffix.replaceAll('(', '').replaceAll(')', '');

    // Parse chord type from suffix
    final type = _parseChordType(suffix);
    if (type == null) {
      throw FormatException('Unknown chord type: "$suffix" in "$input"');
    }

    return Chord(root, type, bassNote: bassNote);
  }

  /// Tries to parse a chord, returning null on failure.
  static Chord? tryParse(String input) {
    try {
      return Chord.parse(input);
    } on FormatException {
      return null;
    }
  }

  /// The pitch classes in this chord.
  List<PitchClass> get pitchClasses {
    return type.intervals
        .map((interval) => root.transpose(interval.semitones))
        .toList();
  }

  /// The notes in this chord, starting from the given octave.
  ///
  /// Notes are arranged in ascending order from the root.
  List<Note> notesFromOctave(int octave) {
    final rootNote = Note(root, octave);
    final notes = <Note>[rootNote];

    for (var i = 1; i < type.intervals.length; i++) {
      notes.add(rootNote.transpose(type.intervals[i].semitones));
    }

    return notes;
  }

  /// The chord symbol (e.g., "C", "Am", "G7", "C/G").
  String get symbol {
    final base = '${root.name}${type.symbol}';
    return bassNote != null ? '$base/${bassNote!.name}' : base;
  }

  /// The full name of the chord (e.g., "C major", "A minor", "C major over G").
  String get name {
    final base = '${root.name} ${type.name}';
    return bassNote != null ? '$base over ${bassNote!.name}' : base;
  }

  /// The intervals that make up this chord.
  List<Interval> get intervals => type.intervals;

  /// The number of notes in this chord.
  int get noteCount => type.noteCount;

  /// Transposes this chord by the given number of semitones.
  Chord transpose(int semitones) {
    return Chord(
      root.transpose(semitones),
      type,
      bassNote: bassNote?.transpose(semitones),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Chord &&
      other.root == root &&
      other.type == type &&
      other.bassNote == bassNote;

  @override
  int get hashCode => Object.hash(root, type, bassNote);

  @override
  String toString() => symbol;
}

/// Parses a chord type from a suffix string.
///
/// Accepts all common musical notation styles directly without transformation.
ChordType? _parseChordType(String suffix) {
  return switch (suffix) {
    // Major: empty, M, maj, Maj, MAJ
    '' || 'M' || 'maj' || 'Maj' || 'MAJ' => ChordType.major,

    // Minor: m, min, Min, MIN, -
    'm' || 'min' || 'Min' || 'MIN' || '-' => ChordType.minor,

    // Diminished: dim, Dim, DIM, ° (degree), ˚ (ring above), º (ordinal)
    'dim' || 'Dim' || 'DIM' || '°' || '˚' || 'º' => ChordType.diminished,

    // Augmented: aug, Aug, AUG, +
    'aug' || 'Aug' || 'AUG' || '+' => ChordType.augmented,

    // Suspended 2nd: sus2, Sus2, SUS2
    'sus2' || 'Sus2' || 'SUS2' => ChordType.sus2,

    // Suspended 4th: sus4, Sus4, SUS4, sus, Sus, SUS
    'sus4' || 'Sus4' || 'SUS4' || 'sus' || 'Sus' || 'SUS' => ChordType.sus4,

    // Dominant 7th
    '7' => ChordType.dominant7,

    // Major 7th: M7, maj7, Maj7, MAJ7, Δ, Δ7
    'M7' || 'maj7' || 'Maj7' || 'MAJ7' || 'Δ' || 'Δ7' => ChordType.major7,

    // Minor 7th: m7, min7, Min7, MIN7
    'm7' || 'min7' || 'Min7' || 'MIN7' => ChordType.minor7,

    // Minor major 7th: mM7, mMaj7, mmaj7, minMaj7, minM7
    'mM7' ||
    'mMaj7' ||
    'mmaj7' ||
    'minMaj7' ||
    'minM7' =>
      ChordType.minorMajor7,

    // Diminished 7th: dim7, Dim7, DIM7, °7, ˚7, º7
    'dim7' || 'Dim7' || 'DIM7' || '°7' || '˚7' || 'º7' => ChordType.diminished7,

    // Half-diminished 7th: m7b5, min7b5, ø, ø7
    'm7b5' || 'min7b5' || 'ø' || 'ø7' => ChordType.halfDiminished7,

    // Augmented 7th: aug7, Aug7, AUG7, +7
    'aug7' || 'Aug7' || 'AUG7' || '+7' => ChordType.augmented7,

    // Add 9: add9, Add9, ADD9
    'add9' || 'Add9' || 'ADD9' => ChordType.add9,

    // Minor add 9: madd9, mAdd9, minadd9, minAdd9
    'madd9' || 'mAdd9' || 'minadd9' || 'minAdd9' => ChordType.minorAdd9,

    // Dominant 9th
    '9' => ChordType.dominant9,

    // Major 9th: M9, maj9, Maj9, MAJ9
    'M9' || 'maj9' || 'Maj9' || 'MAJ9' => ChordType.major9,

    // Minor 9th: m9, min9, Min9, MIN9
    'm9' || 'min9' || 'Min9' || 'MIN9' => ChordType.minor9,

    // Dominant 7 flat 9: 7b9
    '7b9' => ChordType.dominant7b9,

    // Dominant 7 sharp 9: 7#9
    '7#9' => ChordType.dominant7sharp9,

    // Dominant 7 flat 13: 7b13
    '7b13' => ChordType.dominant7b13,

    // Dominant 7 sharp 11: 7#11
    '7#11' => ChordType.dominant7sharp11,

    // Dominant 11th
    '11' => ChordType.dominant11,

    // Dominant 13th
    '13' => ChordType.dominant13,

    // Major 6th
    '6' => ChordType.major6,

    // Minor 6th: m6, min6, Min6, MIN6
    'm6' || 'min6' || 'Min6' || 'MIN6' => ChordType.minor6,

    // Major 6/9: 69, 6/9
    '69' || '6/9' => ChordType.sixNine,

    // Power chord
    '5' => ChordType.power,
    _ => null,
  };
}

/// Extension methods for creating chords from pitch classes.
extension PitchClassChordExtension on PitchClass {
  /// Creates a major chord with this pitch class as root.
  Chord get majorChord => Chord(this, ChordType.major);

  /// Creates a minor chord with this pitch class as root.
  Chord get minorChord => Chord(this, ChordType.minor);

  /// Creates a chord with this pitch class as root.
  Chord chord(ChordType type) => Chord(this, type);
}
