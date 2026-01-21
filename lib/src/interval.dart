import 'note.dart';
import 'pitch_class.dart';

/// The quality of a musical interval.
enum IntervalQuality {
  /// Diminished interval (one semitone smaller than minor/perfect).
  diminished('d', 'diminished'),

  /// Minor interval (applies to 2nds, 3rds, 6ths, 7ths).
  minor('m', 'minor'),

  /// Perfect interval (applies to unisons, 4ths, 5ths, octaves).
  perfect('P', 'perfect'),

  /// Major interval (applies to 2nds, 3rds, 6ths, 7ths).
  major('M', 'major'),

  /// Augmented interval (one semitone larger than major/perfect).
  augmented('A', 'augmented');

  /// Short symbol for the quality (d, m, P, M, A).
  final String symbol;

  /// Full name of the quality.
  final String name;

  const IntervalQuality(this.symbol, this.name);

  @override
  String toString() => name;
}

/// A musical interval representing the distance between two pitches.
///
/// Intervals are defined by their size in semitones and their quality.
/// Common intervals include minor/major 2nds, 3rds, perfect 4ths/5ths, etc.
///
/// ```dart
/// final majorThird = Interval.majorThird;
/// final note = Note.parse('C4');
/// final newNote = note + majorThird.semitones; // E4
///
/// // Calculate interval between notes
/// final interval = Interval.between(Note.parse('C4'), Note.parse('G4'));
/// print(interval); // Perfect 5th
/// ```
class Interval implements Comparable<Interval> {
  /// The number of semitones in this interval.
  final int semitones;

  /// The quality of the interval (major, minor, perfect, etc.).
  final IntervalQuality quality;

  /// The interval number (1 = unison, 2 = second, 3 = third, etc.).
  final int number;

  /// Creates an interval with the given semitones, quality, and number.
  const Interval({
    required this.semitones,
    required this.quality,
    required this.number,
  });

  // ==================== Standard Intervals ====================

  /// Perfect unison (0 semitones).
  static const Interval perfectUnison = Interval(
    semitones: 0,
    quality: IntervalQuality.perfect,
    number: 1,
  );

  /// Minor second (1 semitone) - half step.
  static const Interval minorSecond = Interval(
    semitones: 1,
    quality: IntervalQuality.minor,
    number: 2,
  );

  /// Major second (2 semitones) - whole step.
  static const Interval majorSecond = Interval(
    semitones: 2,
    quality: IntervalQuality.major,
    number: 2,
  );

  /// Minor third (3 semitones).
  static const Interval minorThird = Interval(
    semitones: 3,
    quality: IntervalQuality.minor,
    number: 3,
  );

  /// Major third (4 semitones).
  static const Interval majorThird = Interval(
    semitones: 4,
    quality: IntervalQuality.major,
    number: 3,
  );

  /// Perfect fourth (5 semitones).
  static const Interval perfectFourth = Interval(
    semitones: 5,
    quality: IntervalQuality.perfect,
    number: 4,
  );

  /// Augmented fourth / tritone (6 semitones).
  static const Interval augmentedFourth = Interval(
    semitones: 6,
    quality: IntervalQuality.augmented,
    number: 4,
  );

  /// Diminished fifth / tritone (6 semitones).
  static const Interval diminishedFifth = Interval(
    semitones: 6,
    quality: IntervalQuality.diminished,
    number: 5,
  );

  /// Perfect fifth (7 semitones).
  static const Interval perfectFifth = Interval(
    semitones: 7,
    quality: IntervalQuality.perfect,
    number: 5,
  );

  /// Minor sixth (8 semitones).
  static const Interval minorSixth = Interval(
    semitones: 8,
    quality: IntervalQuality.minor,
    number: 6,
  );

  /// Major sixth (9 semitones).
  static const Interval majorSixth = Interval(
    semitones: 9,
    quality: IntervalQuality.major,
    number: 6,
  );

  /// Minor seventh (10 semitones).
  static const Interval minorSeventh = Interval(
    semitones: 10,
    quality: IntervalQuality.minor,
    number: 7,
  );

  /// Major seventh (11 semitones).
  static const Interval majorSeventh = Interval(
    semitones: 11,
    quality: IntervalQuality.major,
    number: 7,
  );

  /// Perfect octave (12 semitones).
  static const Interval perfectOctave = Interval(
    semitones: 12,
    quality: IntervalQuality.perfect,
    number: 8,
  );

  // ==================== Aliases ====================

  /// Alias for [minorSecond] - half step.
  static const Interval halfStep = minorSecond;

  /// Alias for [majorSecond] - whole step.
  static const Interval wholeStep = majorSecond;

  /// Alias for [augmentedFourth] - tritone (also called diminished 5th).
  static const Interval tritone = augmentedFourth;

  /// Alias for [perfectOctave].
  static const Interval octave = perfectOctave;

  // ==================== All Standard Intervals ====================

  /// All standard intervals within one octave.
  static const List<Interval> standardIntervals = [
    perfectUnison,
    minorSecond,
    majorSecond,
    minorThird,
    majorThird,
    perfectFourth,
    augmentedFourth,
    perfectFifth,
    minorSixth,
    majorSixth,
    minorSeventh,
    majorSeventh,
    perfectOctave,
  ];

  // ==================== Factory Methods ====================

  /// Creates an interval from a number of semitones.
  ///
  /// Returns the most common interval name for that number of semitones.
  /// For compound intervals (> 12 semitones), reduces to simple interval.
  factory Interval.fromSemitones(int semitones) {
    final simpleSemitones = semitones % 12;
    final octaves = semitones ~/ 12;

    final baseInterval = switch (simpleSemitones) {
      0 => perfectUnison,
      1 => minorSecond,
      2 => majorSecond,
      3 => minorThird,
      4 => majorThird,
      5 => perfectFourth,
      6 => augmentedFourth,
      7 => perfectFifth,
      8 => minorSixth,
      9 => majorSixth,
      10 => minorSeventh,
      11 => majorSeventh,
      _ => perfectUnison, // Should never happen due to modulo
    };

    if (octaves == 0) {
      return baseInterval;
    }

    // Compound interval
    return Interval(
      semitones: semitones,
      quality: baseInterval.quality,
      number: baseInterval.number + (octaves * 7),
    );
  }

  /// Calculates the interval between two notes.
  ///
  /// The interval is always positive, measuring from lower to higher note.
  ///
  /// ```dart
  /// Interval.between(Note.parse('C4'), Note.parse('G4')); // Perfect 5th
  /// Interval.between(Note.parse('G4'), Note.parse('C4')); // Perfect 5th
  /// ```
  factory Interval.between(Note a, Note b) {
    final semitones = (b.midiNumber - a.midiNumber).abs();
    return Interval.fromSemitones(semitones);
  }

  /// Calculates the directed interval from one note to another.
  ///
  /// Returns negative semitones if [to] is below [from].
  static int directedSemitones(Note from, Note to) {
    return to.midiNumber - from.midiNumber;
  }

  // ==================== Properties ====================

  /// Whether this is a perfect interval (unison, 4th, 5th, octave).
  bool get isPerfect =>
      number == 1 || number == 4 || number == 5 || number == 8 || number % 7 == 1 || number % 7 == 4 || number % 7 == 5;

  /// Whether this interval spans more than one octave.
  bool get isCompound => semitones > 12;

  /// Returns the simple interval (reduced to within one octave).
  Interval get simple {
    if (!isCompound) return this;
    return Interval.fromSemitones(semitones % 12);
  }

  /// Returns the inversion of this interval.
  ///
  /// The inversion is the interval that, when added to this one,
  /// equals an octave. For example, a major 3rd inverts to a minor 6th.
  Interval get inversion {
    final invertedSemitones = 12 - (semitones % 12);
    return Interval.fromSemitones(invertedSemitones);
  }

  /// A beginner-friendly name for common intervals.
  String get friendlyName {
    return switch (semitones % 12) {
      0 => 'unison',
      1 => 'half step',
      2 => 'whole step',
      3 => 'minor third',
      4 => 'major third',
      5 => 'perfect fourth',
      6 => 'tritone',
      7 => 'perfect fifth',
      8 => 'minor sixth',
      9 => 'major sixth',
      10 => 'minor seventh',
      11 => 'major seventh',
      _ => name,
    };
  }

  /// The full name of the interval (e.g., "major third", "perfect fifth").
  String get name {
    final numberName = _numberToOrdinal(number);
    return '${quality.name} $numberName';
  }

  /// Short notation (e.g., "M3", "P5", "m7").
  String get shortName => '${quality.symbol}$number';

  // ==================== Operations ====================

  /// Adds this interval to a note, returning the resulting note.
  Note addTo(Note note) => note.transpose(semitones);

  /// Subtracts this interval from a note, returning the resulting note.
  Note subtractFrom(Note note) => note.transpose(-semitones);

  // ==================== Comparison ====================

  @override
  int compareTo(Interval other) => semitones.compareTo(other.semitones);

  /// Returns true if this interval is smaller than [other].
  bool operator <(Interval other) => semitones < other.semitones;

  /// Returns true if this interval is smaller than or equal to [other].
  bool operator <=(Interval other) => semitones <= other.semitones;

  /// Returns true if this interval is larger than [other].
  bool operator >(Interval other) => semitones > other.semitones;

  /// Returns true if this interval is larger than or equal to [other].
  bool operator >=(Interval other) => semitones >= other.semitones;

  @override
  bool operator ==(Object other) =>
      other is Interval && other.semitones == semitones && other.quality == quality && other.number == number;

  @override
  int get hashCode => Object.hash(semitones, quality, number);

  @override
  String toString() => name;
}

/// Converts a number to its ordinal form (1st, 2nd, 3rd, etc.).
String _numberToOrdinal(int n) {
  if (n == 1) return 'unison';
  if (n == 8) return 'octave';

  final suffix = switch (n % 10) {
    1 when n % 100 != 11 => 'st',
    2 when n % 100 != 12 => 'nd',
    3 when n % 100 != 13 => 'rd',
    _ => 'th',
  };
  return '$n$suffix';
}

/// Extension methods for calculating intervals from notes.
extension NoteIntervalExtension on Note {
  /// Returns the interval from this note to [other].
  Interval intervalTo(Note other) => Interval.between(this, other);

  /// Returns the number of semitones from this note to [other].
  ///
  /// Positive if [other] is higher, negative if lower.
  int directedIntervalTo(Note other) => Interval.directedSemitones(this, other);
}

/// Extension methods for calculating intervals from pitch classes.
extension PitchClassIntervalExtension on PitchClass {
  /// Returns the interval in semitones from this pitch class to [other].
  ///
  /// Always returns a value from 0 to 11 (ascending).
  int semitonesTo(PitchClass other) {
    final diff = other.index - index;
    return diff < 0 ? diff + 12 : diff;
  }
}
