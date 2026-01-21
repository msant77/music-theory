import 'pitch_class.dart';

/// A musical note with pitch class and octave.
///
/// Notes combine a [PitchClass] (C, C#, D, etc.) with an octave number
/// to represent a specific pitch. Middle C is C4 (MIDI note 60).
///
/// ```dart
/// final middleC = Note(PitchClass.c, 4);
/// final a440 = Note.parse('A4'); // A above middle C (440 Hz)
/// ```
class Note implements Comparable<Note> {
  /// The pitch class (C, C#, D, etc.).
  final PitchClass pitchClass;

  /// The octave number.
  ///
  /// Standard piano range is roughly octaves 0-8.
  /// Middle C is octave 4.
  final int octave;

  /// Creates a note with the given pitch class and octave.
  const Note(this.pitchClass, this.octave);

  /// Middle C (C4), MIDI note 60.
  static const Note middleC = Note(PitchClass.c, 4);

  /// A440, the standard tuning reference (A4), MIDI note 69.
  static const Note a440 = Note(PitchClass.a, 4);

  /// The MIDI note number for this note.
  ///
  /// Middle C (C4) = 60, A4 = 69.
  /// Range: 0 (C-1) to 127 (G9).
  int get midiNumber => (octave + 1) * 12 + pitchClass.index;

  /// Creates a note from a MIDI note number.
  ///
  /// MIDI note 60 = C4 (middle C).
  factory Note.fromMidi(int midiNumber) {
    if (midiNumber < 0 || midiNumber > 127) {
      throw RangeError.range(midiNumber, 0, 127, 'midiNumber');
    }
    final octave = (midiNumber ~/ 12) - 1;
    final pitchIndex = midiNumber % 12;
    return Note(PitchClass.values[pitchIndex], octave);
  }

  /// Parses a note from a string like "C4", "C#4", "Db3".
  ///
  /// Format: pitch class followed by octave number.
  /// Accepts sharps (#) and flats (b), case insensitive.
  ///
  /// Throws [FormatException] if the format is invalid.
  static Note parse(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('Empty note string');
    }

    // Find where the octave number starts
    // Handle negative octaves (e.g., "C-1")
    int octaveStart = -1;
    for (var i = 1; i < trimmed.length; i++) {
      final char = trimmed[i];
      if (char == '-' || (char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57)) {
        // Found minus sign or digit
        if (char != '#' && char != 'b') {
          octaveStart = i;
          break;
        }
      }
    }

    if (octaveStart == -1) {
      throw FormatException('Missing octave in note: "$input"');
    }

    final pitchStr = trimmed.substring(0, octaveStart);
    final octaveStr = trimmed.substring(octaveStart);

    final pitchClass = PitchClass.parse(pitchStr);
    final octave = int.tryParse(octaveStr);

    if (octave == null) {
      throw FormatException('Invalid octave in note: "$input"');
    }

    return Note(pitchClass, octave);
  }

  /// Tries to parse a note, returning null on failure.
  static Note? tryParse(String input) {
    try {
      return parse(input);
    } on FormatException {
      return null;
    }
  }

  /// Returns a new note transposed by the given number of semitones.
  ///
  /// Positive values transpose up, negative values transpose down.
  /// Handles octave boundary crossing automatically.
  ///
  /// ```dart
  /// Note.parse('C4').transpose(12); // C5
  /// Note.parse('C4').transpose(-1); // B3
  /// Note.parse('G4').transpose(5);  // C5
  /// ```
  Note transpose(int semitones) {
    final newMidi = midiNumber + semitones;
    if (newMidi < 0 || newMidi > 127) {
      throw RangeError('Transposition results in out-of-range MIDI note: $newMidi');
    }
    return Note.fromMidi(newMidi);
  }

  /// Returns the interval in semitones from this note to [other].
  ///
  /// Returns positive if [other] is higher, negative if lower.
  ///
  /// ```dart
  /// Note.parse('C4').semitonesTo(Note.parse('E4')); // 4
  /// Note.parse('C4').semitonesTo(Note.parse('C5')); // 12
  /// ```
  int semitonesTo(Note other) => other.midiNumber - midiNumber;

  /// Returns the frequency in Hz for this note, using A4 = 440 Hz.
  ///
  /// Uses equal temperament tuning.
  double get frequency {
    // A4 = 440 Hz, MIDI note 69
    // f = 440 * 2^((n-69)/12)
    return 440.0 * _pow2((midiNumber - 69) / 12.0);
  }

  /// Returns the note name with octave (e.g., "C#4").
  String get name => '${pitchClass.name}$octave';

  @override
  int compareTo(Note other) => midiNumber.compareTo(other.midiNumber);

  /// Returns true if this note is lower than [other].
  bool operator <(Note other) => midiNumber < other.midiNumber;

  /// Returns true if this note is lower than or equal to [other].
  bool operator <=(Note other) => midiNumber <= other.midiNumber;

  /// Returns true if this note is higher than [other].
  bool operator >(Note other) => midiNumber > other.midiNumber;

  /// Returns true if this note is higher than or equal to [other].
  bool operator >=(Note other) => midiNumber >= other.midiNumber;

  /// Adds semitones to this note. Same as [transpose].
  Note operator +(int semitones) => transpose(semitones);

  /// Subtracts semitones from this note. Same as [transpose] with negation.
  Note operator -(int semitones) => transpose(-semitones);

  @override
  bool operator ==(Object other) =>
      other is Note && other.pitchClass == pitchClass && other.octave == octave;

  @override
  int get hashCode => Object.hash(pitchClass, octave);

  @override
  String toString() => name;
}

/// Fast power of 2 calculation for frequency.
double _pow2(double x) {
  // Using dart:math would require an import, so we use exp(x * ln(2))
  // exp(x) ≈ sum of x^n/n! for efficiency at small x
  // For audio frequencies, this is accurate enough
  const ln2 = 0.6931471805599453;
  final y = x * ln2;

  // Use Dart's built-in for accuracy
  return _exp(y);
}

/// Exponential function approximation.
double _exp(double x) {
  // For values in typical note range, we can use a Taylor series
  // or simply use the formula: e^x
  // Since we're computing 2^x for notes, x is in range roughly -10 to +6

  // Using the identity: e^x = e^(n + f) = e^n * e^f where n is integer
  // This gives better accuracy for larger |x|

  if (x == 0) return 1.0;

  // Split into integer and fractional parts
  final n = x.floor();
  final f = x - n;

  // e^f using Taylor series (f is in [0, 1))
  double ef = 1.0;
  double term = 1.0;
  for (var i = 1; i <= 20; i++) {
    term *= f / i;
    ef += term;
    if (term.abs() < 1e-15) break;
  }

  // e^n using repeated squaring
  const e = 2.718281828459045;
  double en = 1.0;
  double base = n >= 0 ? e : 1 / e;
  var absN = n.abs();

  while (absN > 0) {
    if (absN & 1 == 1) {
      en *= base;
    }
    base *= base;
    absN >>= 1;
  }

  return en * ef;
}
