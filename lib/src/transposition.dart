import 'chord.dart';
import 'pitch_class.dart';

/// Preference for enharmonic spelling when transposing.
enum SpellingPreference {
  /// Use sharps for accidentals (C#, D#, F#, G#, A#).
  sharps,

  /// Use flats for accidentals (Db, Eb, Gb, Ab, Bb).
  flats,

  /// Automatically choose based on the key or context.
  auto,
}

/// A musical key, defined by a tonic and mode.
class Key {
  /// The tonic (root) of the key.
  final PitchClass tonic;

  /// Whether this is a major key (true) or minor key (false).
  final bool isMajor;

  /// Creates a key with the given tonic and mode.
  const Key(this.tonic, {this.isMajor = true});

  /// Creates a major key.
  const Key.major(this.tonic) : isMajor = true;

  /// Creates a minor key.
  const Key.minor(this.tonic) : isMajor = false;

  /// The relative major/minor of this key.
  Key get relative {
    if (isMajor) {
      // Relative minor is 3 semitones down
      return Key.minor(tonic.transpose(-3));
    } else {
      // Relative major is 3 semitones up
      return Key.major(tonic.transpose(3));
    }
  }

  /// The parallel major/minor of this key (same tonic, different mode).
  Key get parallel => Key(tonic, isMajor: !isMajor);

  /// Transposes this key by the given number of semitones.
  Key transpose(int semitones) {
    return Key(tonic.transpose(semitones), isMajor: isMajor);
  }

  /// Whether this key prefers flats in its spelling.
  ///
  /// Keys with flats in their signature: F, Bb, Eb, Ab, Db, Gb, Cb (major)
  /// and their relative minors: Dm, Gm, Cm, Fm, Bbm, Ebm, Abm.
  bool get prefersFlats {
    // Major keys that prefer flats
    const flatMajorKeys = {
      PitchClass.f,
      PitchClass.aSharp, // Bb
      PitchClass.dSharp, // Eb
      PitchClass.gSharp, // Ab
      PitchClass.cSharp, // Db
      PitchClass.fSharp, // Gb
    };

    // Minor keys that prefer flats
    const flatMinorKeys = {
      PitchClass.d,
      PitchClass.g,
      PitchClass.c,
      PitchClass.f,
      PitchClass.aSharp, // Bbm
      PitchClass.dSharp, // Ebm
      PitchClass.gSharp, // Abm
    };

    if (isMajor) {
      return flatMajorKeys.contains(tonic);
    } else {
      return flatMinorKeys.contains(tonic);
    }
  }

  /// The pitch classes in this key's scale.
  List<PitchClass> get scale {
    // Major scale intervals: W W H W W W H (2 2 1 2 2 2 1)
    // Minor scale intervals: W H W W H W W (2 1 2 2 1 2 2)
    final intervals = isMajor
        ? const [0, 2, 4, 5, 7, 9, 11]
        : const [0, 2, 3, 5, 7, 8, 10];

    return intervals.map(tonic.transpose).toList();
  }

  /// The diatonic chords in this key.
  ///
  /// For major keys: I, ii, iii, IV, V, vi, vii°
  /// For minor keys: i, ii°, III, iv, v, VI, VII
  List<Chord> get diatonicChords {
    final scaleNotes = scale;

    if (isMajor) {
      return [
        Chord(scaleNotes[0], ChordType.major), // I
        Chord(scaleNotes[1], ChordType.minor), // ii
        Chord(scaleNotes[2], ChordType.minor), // iii
        Chord(scaleNotes[3], ChordType.major), // IV
        Chord(scaleNotes[4], ChordType.major), // V
        Chord(scaleNotes[5], ChordType.minor), // vi
        Chord(scaleNotes[6], ChordType.diminished), // vii°
      ];
    } else {
      return [
        Chord(scaleNotes[0], ChordType.minor), // i
        Chord(scaleNotes[1], ChordType.diminished), // ii°
        Chord(scaleNotes[2], ChordType.major), // III
        Chord(scaleNotes[3], ChordType.minor), // iv
        Chord(scaleNotes[4], ChordType.minor), // v
        Chord(scaleNotes[5], ChordType.major), // VI
        Chord(scaleNotes[6], ChordType.major), // VII
      ];
    }
  }

  /// Parses a key from a string like "C", "Am", "F#m", "Bb".
  ///
  /// Major keys use just the note name (C, G, F#).
  /// Minor keys add "m" suffix (Am, Em, F#m).
  factory Key.parse(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('Empty key string');
    }

    // Check if it ends with 'm' or 'min' for minor
    if (trimmed.endsWith('min')) {
      final tonicStr = trimmed.substring(0, trimmed.length - 3);
      return Key.minor(PitchClass.parse(tonicStr));
    } else if (trimmed.endsWith('m') && !trimmed.endsWith('dim')) {
      final tonicStr = trimmed.substring(0, trimmed.length - 1);
      return Key.minor(PitchClass.parse(tonicStr));
    } else {
      return Key.major(PitchClass.parse(trimmed));
    }
  }

  /// Tries to parse a key, returning null on failure.
  static Key? tryParse(String input) {
    try {
      return Key.parse(input);
    } on FormatException {
      return null;
    }
  }

  /// The name of this key.
  String get name {
    final modeName = isMajor ? 'major' : 'minor';
    return '${spelledTonic()} $modeName';
  }

  /// The symbol for this key (e.g., "C", "Am", "F#m").
  String get symbol {
    final suffix = isMajor ? '' : 'm';
    return '${spelledTonic()}$suffix';
  }

  /// Returns the tonic with appropriate enharmonic spelling.
  String spelledTonic({SpellingPreference preference = SpellingPreference.auto}) {
    final pref = preference == SpellingPreference.auto
        ? (prefersFlats ? SpellingPreference.flats : SpellingPreference.sharps)
        : preference;

    return spellPitchClass(tonic, pref);
  }

  @override
  bool operator ==(Object other) =>
      other is Key && other.tonic == tonic && other.isMajor == isMajor;

  @override
  int get hashCode => Object.hash(tonic, isMajor);

  @override
  String toString() => symbol;
}

/// Returns the enharmonic spelling of a pitch class.
///
/// With [SpellingPreference.sharps]: C, C#, D, D#, E, F, F#, G, G#, A, A#, B
/// With [SpellingPreference.flats]: C, Db, D, Eb, E, F, Gb, G, Ab, A, Bb, B
String spellPitchClass(PitchClass pc, SpellingPreference preference) {
  if (preference == SpellingPreference.flats) {
    return switch (pc) {
      PitchClass.c => 'C',
      PitchClass.cSharp => 'Db',
      PitchClass.d => 'D',
      PitchClass.dSharp => 'Eb',
      PitchClass.e => 'E',
      PitchClass.f => 'F',
      PitchClass.fSharp => 'Gb',
      PitchClass.g => 'G',
      PitchClass.gSharp => 'Ab',
      PitchClass.a => 'A',
      PitchClass.aSharp => 'Bb',
      PitchClass.b => 'B',
    };
  } else {
    // Sharps (default)
    return pc.name;
  }
}

/// Transposes a chord with the specified enharmonic spelling preference.
///
/// ```dart
/// final chord = Chord.parse('C');
/// final transposed = transposeChord(chord, 1, SpellingPreference.flats);
/// print(transposed); // Db (not C#)
/// ```
Chord transposeChord(
  Chord chord,
  int semitones, {
  SpellingPreference spelling = SpellingPreference.auto,
}) {
  return chord.transpose(semitones);
}

/// Returns the chord symbol with the specified spelling preference.
String spellChord(Chord chord, SpellingPreference preference) {
  final rootSpelling = spellPitchClass(chord.root, preference);
  return '$rootSpelling${chord.type.symbol}';
}

/// A chord progression - a sequence of chords.
class ChordProgression {
  /// The chords in this progression.
  final List<Chord> chords;

  /// Creates a progression from a list of chords.
  const ChordProgression(this.chords);

  /// Creates a progression from a space-separated string of chord symbols.
  ///
  /// ```dart
  /// final prog = ChordProgression.parse('C Am F G');
  /// ```
  factory ChordProgression.parse(String input) {
    final parts = input.trim().split(RegExp(r'\s+'));
    final chords = parts.map(Chord.parse).toList();
    return ChordProgression(chords);
  }

  /// Tries to parse a progression, returning null on failure.
  static ChordProgression? tryParse(String input) {
    try {
      return ChordProgression.parse(input);
    } on FormatException {
      return null;
    }
  }

  /// Transposes all chords in this progression by the given semitones.
  ChordProgression transpose(int semitones) {
    return ChordProgression(
      chords.map((c) => c.transpose(semitones)).toList(),
    );
  }

  /// Returns the progression symbols with the specified spelling preference.
  List<String> spell(SpellingPreference preference) {
    return chords.map((c) => spellChord(c, preference)).toList();
  }

  /// The number of chords in this progression.
  int get length => chords.length;

  /// Whether this progression is empty.
  bool get isEmpty => chords.isEmpty;

  /// Whether this progression is not empty.
  bool get isNotEmpty => chords.isNotEmpty;

  /// Returns the chord symbols as a space-separated string.
  String toSymbolString({SpellingPreference spelling = SpellingPreference.sharps}) {
    return spell(spelling).join(' ');
  }

  @override
  String toString() => toSymbolString();
}

/// Utility functions for transposition.
class Transposition {
  Transposition._();

  /// Transposes a single chord by the given number of semitones.
  ///
  /// Positive values transpose up, negative values transpose down.
  static Chord chord(Chord chord, int semitones) {
    return chord.transpose(semitones);
  }

  /// Transposes a chord progression by the given number of semitones.
  static ChordProgression progression(ChordProgression prog, int semitones) {
    return prog.transpose(semitones);
  }

  /// Transposes a key by the given number of semitones.
  static Key key(Key key, int semitones) {
    return key.transpose(semitones);
  }

  /// Calculates semitones between two keys.
  ///
  /// Returns the number of semitones to transpose from [from] to [to].
  static int semitonesBetweenKeys(Key from, Key to) {
    final fromIndex = from.tonic.index;
    final toIndex = to.tonic.index;
    var diff = toIndex - fromIndex;
    if (diff < 0) diff += 12;
    return diff;
  }

  /// Common transposition intervals for reference.
  static const Map<String, int> commonIntervals = {
    'half step up': 1,
    'half step down': -1,
    'whole step up': 2,
    'whole step down': -2,
    'minor third up': 3,
    'minor third down': -3,
    'major third up': 4,
    'major third down': -4,
    'perfect fourth up': 5,
    'perfect fourth down': -5,
    'tritone': 6,
    'perfect fifth up': 7,
    'perfect fifth down': -7,
    'octave up': 12,
    'octave down': -12,
  };

  /// Transposes from one key to another, preserving chord relationships.
  ///
  /// This maintains the relative position of chords in the original key.
  static List<Chord> fromKeyToKey(List<Chord> chords, Key from, Key to) {
    final semitones = semitonesBetweenKeys(from, to);
    return chords.map((c) => c.transpose(semitones)).toList();
  }
}

/// Extension methods for transposition on chords.
extension ChordTranspositionExtension on Chord {
  /// Returns the chord symbol spelled with flats.
  String get flatSymbol => spellChord(this, SpellingPreference.flats);

  /// Returns the chord symbol spelled with sharps.
  String get sharpSymbol => spellChord(this, SpellingPreference.sharps);

  /// Transposes up by the given number of semitones.
  Chord transposeUp(int semitones) => transpose(semitones.abs());

  /// Transposes down by the given number of semitones.
  Chord transposeDown(int semitones) => transpose(-semitones.abs());

  /// Transposes up by a half step (1 semitone).
  Chord get halfStepUp => transpose(1);

  /// Transposes down by a half step (1 semitone).
  Chord get halfStepDown => transpose(-1);

  /// Transposes up by a whole step (2 semitones).
  Chord get wholeStepUp => transpose(2);

  /// Transposes down by a whole step (2 semitones).
  Chord get wholeStepDown => transpose(-2);
}

/// Extension methods for pitch class spelling.
extension PitchClassSpellingExtension on PitchClass {
  /// Returns this pitch class spelled with flats.
  String get flatName => spellPitchClass(this, SpellingPreference.flats);

  /// Returns this pitch class spelled with sharps.
  String get sharpName => spellPitchClass(this, SpellingPreference.sharps);
}
