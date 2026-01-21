import 'instrument.dart';
import 'pitch_class.dart';
import 'tuning.dart';

/// Seed data for common stringed instruments.
///
/// These presets provide ready-to-use configurations for popular instruments.
/// Users can create their own instruments using the [Instrument] constructor
/// or [Instrument.custom] factory.
///
/// ```dart
/// // Use a preset
/// final guitar = Instruments.guitar;
///
/// // Or create your own
/// final myInstrument = Instrument(
///   name: 'My Custom Instrument',
///   strings: [...],
/// );
/// ```
abstract final class Instruments {
  /// Standard 6-string guitar in standard tuning (E A D G B E).
  static const guitar = Instrument(
    name: 'Guitar',
    strings: [
      StringConfig(openNote: PitchClass.e, octave: 2),
      StringConfig(openNote: PitchClass.a, octave: 2),
      StringConfig(openNote: PitchClass.d, octave: 3),
      StringConfig(openNote: PitchClass.g, octave: 3),
      StringConfig(openNote: PitchClass.b, octave: 3),
      StringConfig(openNote: PitchClass.e, octave: 4),
    ],
  );

  /// Standard 4-string bass in standard tuning (E A D G).
  static const bass = Instrument(
    name: 'Bass',
    strings: [
      StringConfig(openNote: PitchClass.e, octave: 1, fretCount: 20),
      StringConfig(openNote: PitchClass.a, octave: 1, fretCount: 20),
      StringConfig(openNote: PitchClass.d, octave: 2, fretCount: 20),
      StringConfig(openNote: PitchClass.g, octave: 2, fretCount: 20),
    ],
  );

  /// Standard ukulele in C tuning (G C E A) - reentrant tuning.
  static const ukulele = Instrument(
    name: 'Ukulele',
    strings: [
      StringConfig(openNote: PitchClass.g, octave: 4, fretCount: 15),
      StringConfig(openNote: PitchClass.c, octave: 4, fretCount: 15),
      StringConfig(openNote: PitchClass.e, octave: 4, fretCount: 15),
      StringConfig(openNote: PitchClass.a, octave: 4, fretCount: 15),
    ],
  );

  /// Brazilian cavaquinho in standard tuning (D G B D).
  static const cavaquinho = Instrument(
    name: 'Cavaquinho',
    strings: [
      StringConfig(openNote: PitchClass.d, octave: 4, fretCount: 17),
      StringConfig(openNote: PitchClass.g, octave: 4, fretCount: 17),
      StringConfig(openNote: PitchClass.b, octave: 4, fretCount: 17),
      StringConfig(openNote: PitchClass.d, octave: 5, fretCount: 17),
    ],
  );

  /// 5-string banjo in open G tuning (G D G B D).
  static const banjo = Instrument(
    name: 'Banjo',
    strings: [
      StringConfig(openNote: PitchClass.g, octave: 2),
      StringConfig(openNote: PitchClass.d, octave: 3),
      StringConfig(openNote: PitchClass.g, octave: 3),
      StringConfig(openNote: PitchClass.b, octave: 3),
      StringConfig(openNote: PitchClass.d, octave: 4),
    ],
  );

  /// 7-string guitar in standard tuning with low B (B E A D G B E).
  static const guitar7String = Instrument(
    name: '7-String Guitar',
    strings: [
      StringConfig(openNote: PitchClass.b, octave: 1),
      StringConfig(openNote: PitchClass.e, octave: 2),
      StringConfig(openNote: PitchClass.a, octave: 2),
      StringConfig(openNote: PitchClass.d, octave: 3),
      StringConfig(openNote: PitchClass.g, octave: 3),
      StringConfig(openNote: PitchClass.b, octave: 3),
      StringConfig(openNote: PitchClass.e, octave: 4),
    ],
  );

  /// All preset instruments.
  static const List<Instrument> all = [
    guitar,
    bass,
    ukulele,
    cavaquinho,
    banjo,
    guitar7String,
  ];
}

/// Seed data for common tunings.
///
/// These presets provide ready-to-use tuning configurations.
/// Users can create their own tunings using the [Tuning] constructor
/// or [Tuning.parse] factory.
///
/// ```dart
/// // Use a preset
/// final dropD = Tunings.guitar.dropD.applyTo(Instruments.guitar);
///
/// // Or create your own
/// final custom = Tuning.parse('My Tuning', 'C2 G2 D3 A3 E4 G4');
/// ```
abstract final class Tunings {
  /// Guitar tunings (6-string).
  static final guitar = _GuitarTunings();

  /// Bass tunings (4-string).
  static final bass = _BassTunings();

  /// Ukulele tunings (4-string).
  static final ukulele = _UkuleleTunings();

  /// Cavaquinho tunings (4-string).
  static final cavaquinho = _CavaquinhoTunings();

  /// Banjo tunings (5-string).
  static final banjo = _BanjoTunings();

  /// 7-string guitar tunings.
  static final guitar7String = _Guitar7Tunings();
}

/// Guitar tuning presets.
class _GuitarTunings {
  /// Standard: E A D G B E
  final standard = Tuning.parse('Standard', 'E2 A2 D3 G3 B3 E4');

  /// Drop D: D A D G B E
  final dropD = Tuning.parse('Drop D', 'D2 A2 D3 G3 B3 E4');

  /// Drop C: C G C F A D
  final dropC = Tuning.parse('Drop C', 'C2 G2 C3 F3 A3 D4');

  /// Open G: D G D G B D
  final openG = Tuning.parse('Open G', 'D2 G2 D3 G3 B3 D4');

  /// Open D: D A D F# A D
  final openD = Tuning.parse('Open D', 'D2 A2 D3 F#3 A3 D4');

  /// Open E: E B E G# B E
  final openE = Tuning.parse('Open E', 'E2 B2 E3 G#3 B3 E4');

  /// Open A: E A E A C# E
  final openA = Tuning.parse('Open A', 'E2 A2 E3 A3 C#4 E4');

  /// DADGAD: D A D G A D
  final dadgad = Tuning.parse('DADGAD', 'D2 A2 D3 G3 A3 D4');

  /// Half step down: Eb Ab Db Gb Bb Eb
  final halfStepDown = Tuning.parse('Half Step Down', 'Eb2 Ab2 Db3 Gb3 Bb3 Eb4');

  /// Whole step down: D G C F A D
  final wholeStepDown = Tuning.parse('Whole Step Down', 'D2 G2 C3 F3 A3 D4');

  /// Double drop D: D A D G B D
  final doubleDropD = Tuning.parse('Double Drop D', 'D2 A2 D3 G3 B3 D4');

  /// All fourths: E A D G C F
  final allFourths = Tuning.parse('All Fourths', 'E2 A2 D3 G3 C4 F4');

  /// New standard (Robert Fripp): C G D A E G
  final newStandard = Tuning.parse('New Standard', 'C2 G2 D3 A3 E4 G4');

  /// All guitar tunings.
  List<Tuning> get all => [
        standard,
        dropD,
        dropC,
        openG,
        openD,
        openE,
        openA,
        dadgad,
        halfStepDown,
        wholeStepDown,
        doubleDropD,
        allFourths,
        newStandard,
      ];
}

/// Bass tuning presets.
class _BassTunings {
  /// Standard: E A D G
  final standard = Tuning.parse('Standard', 'E1 A1 D2 G2', fretCount: 20);

  /// Drop D: D A D G
  final dropD = Tuning.parse('Drop D', 'D1 A1 D2 G2', fretCount: 20);

  /// Half step down: Eb Ab Db Gb
  final halfStepDown =
      Tuning.parse('Half Step Down', 'Eb1 Ab1 Db2 Gb2', fretCount: 20);

  /// All bass tunings.
  List<Tuning> get all => [standard, dropD, halfStepDown];
}

/// Ukulele tuning presets.
class _UkuleleTunings {
  /// Standard (C tuning, reentrant): G C E A
  final standard = Tuning.parse('Standard', 'G4 C4 E4 A4', fretCount: 15);

  /// Low G: G C E A (G is low)
  final lowG = Tuning.parse('Low G', 'G3 C4 E4 A4', fretCount: 15);

  /// D tuning: A D F# B
  final dTuning = Tuning.parse('D Tuning', 'A4 D4 F#4 B4', fretCount: 15);

  /// Baritone: D G B E
  final baritone = Tuning.parse('Baritone', 'D3 G3 B3 E4', fretCount: 15);

  /// All ukulele tunings.
  List<Tuning> get all => [standard, lowG, dTuning, baritone];
}

/// Cavaquinho tuning presets.
class _CavaquinhoTunings {
  /// Standard: D G B D
  final standard = Tuning.parse('Standard', 'D4 G4 B4 D5', fretCount: 17);

  /// Natural: D G B E
  final natural = Tuning.parse('Natural', 'D4 G4 B4 E5', fretCount: 17);

  /// All cavaquinho tunings.
  List<Tuning> get all => [standard, natural];
}

/// Banjo tuning presets.
class _BanjoTunings {
  /// Open G (standard): G D G B D
  final openG = Tuning.parse('Open G', 'G2 D3 G3 B3 D4');

  /// Double C: G C G C D
  final doubleC = Tuning.parse('Double C', 'G2 C3 G3 C4 D4');

  /// Open D: F# D F# A D
  final openD = Tuning.parse('Open D', 'F#2 D3 F#3 A3 D4');

  /// All banjo tunings.
  List<Tuning> get all => [openG, doubleC, openD];
}

/// 7-string guitar tuning presets.
class _Guitar7Tunings {
  /// Standard: B E A D G B E
  final standard = Tuning.parse('Standard', 'B1 E2 A2 D3 G3 B3 E4');

  /// Drop A: A E A D G B E
  final dropA = Tuning.parse('Drop A', 'A1 E2 A2 D3 G3 B3 E4');

  /// All 7-string guitar tunings.
  List<Tuning> get all => [standard, dropA];
}
