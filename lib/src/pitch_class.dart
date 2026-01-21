/// The 12 chromatic pitch classes in Western music.
///
/// Each pitch class represents a note name without octave information.
/// Internally uses sharp notation; parser accepts both sharps and flats.
enum PitchClass {
  /// C natural.
  c('C'),

  /// C sharp (enharmonic: D flat).
  cSharp('C#'),

  /// D natural.
  d('D'),

  /// D sharp (enharmonic: E flat).
  dSharp('D#'),

  /// E natural.
  e('E'),

  /// F natural.
  f('F'),

  /// F sharp (enharmonic: G flat).
  fSharp('F#'),

  /// G natural.
  g('G'),

  /// G sharp (enharmonic: A flat).
  gSharp('G#'),

  /// A natural.
  a('A'),

  /// A sharp (enharmonic: B flat).
  aSharp('A#'),

  /// B natural.
  b('B');

  /// The display name for this pitch class.
  final String name;

  const PitchClass(this.name);

  /// Returns the pitch class [semitones] above this one.
  PitchClass transpose(int semitones) {
    final newIndex = (index + semitones) % 12;
    return PitchClass.values[newIndex < 0 ? newIndex + 12 : newIndex];
  }

  /// Parses a pitch class from a string.
  ///
  /// Accepts sharp (#) and flat (b) notation, case insensitive.
  /// Throws [FormatException] if invalid.
  static PitchClass parse(String input) {
    final normalized = input.trim().toLowerCase();

    return switch (normalized) {
      'c' || 'b#' => PitchClass.c,
      'c#' || 'db' => PitchClass.cSharp,
      'd' => PitchClass.d,
      'd#' || 'eb' => PitchClass.dSharp,
      'e' || 'fb' => PitchClass.e,
      'f' || 'e#' => PitchClass.f,
      'f#' || 'gb' => PitchClass.fSharp,
      'g' => PitchClass.g,
      'g#' || 'ab' => PitchClass.gSharp,
      'a' => PitchClass.a,
      'a#' || 'bb' => PitchClass.aSharp,
      'b' || 'cb' => PitchClass.b,
      _ => throw FormatException('Invalid pitch class: "$input"'),
    };
  }

  /// Tries to parse a pitch class, returning null on failure.
  static PitchClass? tryParse(String input) {
    try {
      return parse(input);
    } on FormatException {
      return null;
    }
  }

  @override
  String toString() => name;
}
