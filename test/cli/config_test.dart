import 'dart:convert';
import 'dart:io';

import 'package:music_theory/music_theory.dart';
import 'package:music_theory/src/cli/config.dart';
import 'package:test/test.dart';

void main() {
  group('MusicTheoryConfig', () {
    group('constructor', () {
      test('creates config with required fields', () {
        const config = MusicTheoryConfig(instrument: 'guitar');
        expect(config.instrument, equals('guitar'));
        expect(config.tuningName, isNull);
        expect(config.tuningNotes, isNull);
        expect(config.capo, equals(0));
      });

      test('creates config with all fields', () {
        const config = MusicTheoryConfig(
          instrument: 'bass',
          tuningName: 'dropD',
          capo: 3,
        );
        expect(config.instrument, equals('bass'));
        expect(config.tuningName, equals('dropD'));
        expect(config.capo, equals(3));
      });
    });

    group('defaultConfig', () {
      test('is guitar with standard tuning', () {
        expect(MusicTheoryConfig.defaultConfig.instrument, equals('guitar'));
        expect(MusicTheoryConfig.defaultConfig.tuningName, equals('standard'));
        expect(MusicTheoryConfig.defaultConfig.capo, equals(0));
      });
    });

    group('fromJson / toJson', () {
      test('round-trips correctly', () {
        const original = MusicTheoryConfig(
          instrument: 'ukulele',
          tuningName: 'lowG',
          capo: 2,
        );
        final json = original.toJson();
        final restored = MusicTheoryConfig.fromJson(json);
        expect(restored, equals(original));
      });

      test('handles custom tuning notes', () {
        const original = MusicTheoryConfig(
          instrument: 'guitar',
          tuningNotes: 'D2 A2 D3 G3 B3 E4',
          capo: 1,
        );
        final json = original.toJson();
        final restored = MusicTheoryConfig.fromJson(json);
        expect(restored.tuningNotes, equals('D2 A2 D3 G3 B3 E4'));
      });

      test('handles missing fields with defaults', () {
        final config = MusicTheoryConfig.fromJson({});
        expect(config.instrument, equals('guitar'));
        expect(config.capo, equals(0));
      });
    });

    group('toInstrument', () {
      test('resolves guitar with standard tuning', () {
        const config = MusicTheoryConfig(
          instrument: 'guitar',
          tuningName: 'standard',
        );
        final instrument = config.toInstrument();
        expect(instrument.name, equals('Guitar'));
        expect(instrument.stringCount, equals(6));
        expect(instrument.strings[0].openNote, equals(PitchClass.e));
      });

      test('resolves guitar with drop D tuning', () {
        const config = MusicTheoryConfig(
          instrument: 'guitar',
          tuningName: 'Drop D',
        );
        final instrument = config.toInstrument();
        expect(instrument.strings[0].openNote, equals(PitchClass.d));
      });

      test('resolves bass with standard tuning', () {
        const config = MusicTheoryConfig(
          instrument: 'bass',
          tuningName: 'standard',
        );
        final instrument = config.toInstrument();
        expect(instrument.name, equals('Bass'));
        expect(instrument.stringCount, equals(4));
      });

      test('applies capo correctly', () {
        const config = MusicTheoryConfig(
          instrument: 'guitar',
          tuningName: 'standard',
          capo: 2,
        );
        final instrument = config.toInstrument();
        expect(instrument.capo, equals(2));
      });

      test('resolves custom tuning notes', () {
        const config = MusicTheoryConfig(
          instrument: 'guitar',
          tuningNotes: 'D2 A2 D3 G3 B3 D4',
        );
        final instrument = config.toInstrument();
        expect(instrument.strings[0].openNote, equals(PitchClass.d));
        expect(instrument.strings[5].openNote, equals(PitchClass.d));
      });

      test('throws on unknown instrument', () {
        const config = MusicTheoryConfig(instrument: 'unknown');
        expect(() => config.toInstrument(), throwsArgumentError);
      });

      test('throws on unknown tuning', () {
        const config = MusicTheoryConfig(
          instrument: 'guitar',
          tuningName: 'unknown',
        );
        expect(() => config.toInstrument(), throwsArgumentError);
      });
    });

    group('copyWith', () {
      test('copies with new instrument', () {
        const original = MusicTheoryConfig(
          instrument: 'guitar',
          tuningName: 'standard',
          capo: 2,
        );
        final copied = original.copyWith(instrument: 'bass');
        expect(copied.instrument, equals('bass'));
        expect(copied.tuningName, equals('standard'));
        expect(copied.capo, equals(2));
      });

      test('clears tuning name when requested', () {
        const original = MusicTheoryConfig(
          instrument: 'guitar',
          tuningName: 'standard',
        );
        final copied = original.copyWith(clearTuningName: true);
        expect(copied.tuningName, isNull);
      });

      test('clears tuning notes when requested', () {
        const original = MusicTheoryConfig(
          instrument: 'guitar',
          tuningNotes: 'D2 A2 D3 G3 B3 E4',
        );
        final copied = original.copyWith(clearTuningNotes: true);
        expect(copied.tuningNotes, isNull);
      });
    });

    group('equality', () {
      test('equal configs are equal', () {
        const a = MusicTheoryConfig(
          instrument: 'guitar',
          tuningName: 'standard',
        );
        const b = MusicTheoryConfig(
          instrument: 'guitar',
          tuningName: 'standard',
        );
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('different instruments are not equal', () {
        const a = MusicTheoryConfig(instrument: 'guitar');
        const b = MusicTheoryConfig(instrument: 'bass');
        expect(a, isNot(equals(b)));
      });
    });

    group('toString', () {
      test('shows instrument and tuning name', () {
        const config = MusicTheoryConfig(
          instrument: 'guitar',
          tuningName: 'dropD',
        );
        expect(config.toString(), equals('guitar dropD'));
      });

      test('shows custom tuning notes', () {
        const config = MusicTheoryConfig(
          instrument: 'guitar',
          tuningNotes: 'D2 A2 D3 G3 B3 E4',
        );
        expect(config.toString(), equals('guitar tuning: D2 A2 D3 G3 B3 E4'));
      });

      test('shows capo when present', () {
        const config = MusicTheoryConfig(
          instrument: 'guitar',
          tuningName: 'standard',
          capo: 3,
        );
        expect(config.toString(), equals('guitar standard capo 3'));
      });
    });

    group('file I/O', () {
      late Directory tempDir;
      late String configPath;

      setUp(() async {
        tempDir = await Directory.systemTemp.createTemp('music_theory_test_');
        configPath = '${tempDir.path}/config.json';
      });

      tearDown(() async {
        await tempDir.delete(recursive: true);
      });

      test('saves and loads config', () async {
        const config = MusicTheoryConfig(
          instrument: 'ukulele',
          tuningName: 'baritone',
          capo: 1,
        );
        await config.saveTo(configPath);

        final loaded = await MusicTheoryConfig.loadFrom(configPath);
        expect(loaded, equals(config));
      });

      test('creates directory if needed', () async {
        final nestedPath = '${tempDir.path}/nested/dir/config.json';
        const config = MusicTheoryConfig(instrument: 'guitar');
        await config.saveTo(nestedPath);

        expect(await File(nestedPath).exists(), isTrue);
      });

      test('returns default if file does not exist', () async {
        final loaded = await MusicTheoryConfig.loadFrom(
            '${tempDir.path}/nonexistent.json');
        expect(loaded, equals(MusicTheoryConfig.defaultConfig));
      });

      test('returns default if file is invalid JSON', () async {
        final file = File(configPath);
        await file.writeAsString('not valid json');

        final loaded = await MusicTheoryConfig.loadFrom(configPath);
        expect(loaded, equals(MusicTheoryConfig.defaultConfig));
      });

      test('saves with pretty formatting', () async {
        const config = MusicTheoryConfig(
          instrument: 'guitar',
          tuningName: 'standard',
        );
        await config.saveTo(configPath);

        final contents = await File(configPath).readAsString();
        expect(contents, contains('\n')); // Has newlines (pretty)
        final json = jsonDecode(contents) as Map<String, dynamic>;
        expect(json['instrument'], equals('guitar'));
      });
    });
  }, tags: ['unit']);

  group('getAvailableInstruments', () {
    test('returns all instrument names', () {
      final instruments = getAvailableInstruments();
      expect(instruments, contains('guitar'));
      expect(instruments, contains('bass'));
      expect(instruments, contains('ukulele'));
      expect(instruments, contains('cavaquinho'));
      expect(instruments, contains('banjo'));
    });
  }, tags: ['unit']);

  group('getAvailableTunings', () {
    test('returns guitar tunings', () {
      final tunings = getAvailableTunings('guitar');
      expect(tunings, contains('Standard'));
      expect(tunings, contains('Drop D'));
      expect(tunings, contains('Open G'));
    });

    test('returns bass tunings', () {
      final tunings = getAvailableTunings('bass');
      expect(tunings, contains('Standard'));
      expect(tunings, contains('Drop D'));
    });

    test('returns empty for unknown instrument', () {
      final tunings = getAvailableTunings('unknown');
      expect(tunings, isEmpty);
    });
  }, tags: ['unit']);

  group('normalizeTuningString', () {
    test('passes through space-separated notes', () {
      expect(
        normalizeTuningString('B1 E2 A2 D3 G3 B3 E4'),
        equals('B1 E2 A2 D3 G3 B3 E4'),
      );
    });

    test('parses concatenated notes with octaves', () {
      expect(
        normalizeTuningString('B1E2A2D3G3B3E4'),
        equals('B1 E2 A2 D3 G3 B3 E4'),
      );
    });

    test('parses notes without octaves and infers them (7 strings)', () {
      final result = normalizeTuningString('BEADGBE');
      expect(result, equals('B1 E2 A2 D3 G3 B3 E4'));
    });

    test('parses notes without octaves for 6 strings', () {
      final result = normalizeTuningString('EADGBE');
      expect(result, equals('E2 A2 D3 G3 B3 E4'));
    });

    test('parses notes without octaves for 4 strings (ukulele range)', () {
      final result = normalizeTuningString('GCEA');
      expect(result, equals('G3 C4 E4 A4'));
    });

    test('handles sharps and flats', () {
      expect(
        normalizeTuningString('C#4D4'),
        equals('C#4 D4'),
      );
      expect(
        normalizeTuningString('Db4D4'),
        equals('Db4 D4'),
      );
    });

    test('handles sharps in notes without octaves', () {
      final result = normalizeTuningString('C#DEF');
      expect(result, equals('C#3 D3 E3 F3'));
    });

    test('trims whitespace', () {
      expect(
        normalizeTuningString('  E2 A2  '),
        equals('E2 A2'),
      );
    });
  }, tags: ['unit']);

  group('parseFrets', () {
    test('parses single value', () {
      expect(parseFrets('22'), equals([22]));
    });

    test('parses comma-separated values', () {
      expect(parseFrets('22,22,22,22,5'), equals([22, 22, 22, 22, 5]));
    });

    test('handles whitespace', () {
      expect(parseFrets('  22  '), equals([22]));
      expect(parseFrets(' 22 , 20 , 18 '), equals([22, 20, 18]));
    });
  }, tags: ['unit']);

  group('Custom instrument config', () {
    test('creates custom instrument with all fields', () {
      const config = MusicTheoryConfig(
        instrument: '7-string',
        tuningNotes: 'B1 E2 A2 D3 G3 B3 E4',
        isCustom: true,
        frets: [24],
      );
      expect(config.instrument, equals('7-string'));
      expect(config.isCustom, isTrue);
      expect(config.frets, equals([24]));
    });

    test('toInstrument builds custom instrument', () {
      const config = MusicTheoryConfig(
        instrument: '7-string',
        tuningNotes: 'B1 E2 A2 D3 G3 B3 E4',
        isCustom: true,
        frets: [24],
      );
      final instrument = config.toInstrument();
      expect(instrument.stringCount, equals(7));
      expect(instrument.strings[0].openNote, equals(PitchClass.b));
      expect(instrument.strings[0].fretCount, equals(24));
    });

    test('toInstrument applies capo to custom instrument', () {
      const config = MusicTheoryConfig(
        instrument: '7-string',
        tuningNotes: 'B1 E2 A2 D3 G3 B3 E4',
        isCustom: true,
        frets: [24],
        capo: 2,
      );
      final instrument = config.toInstrument();
      expect(instrument.capo, equals(2));
    });

    test('toInstrument uses per-string frets', () {
      const config = MusicTheoryConfig(
        instrument: 'custom banjo',
        tuningNotes: 'G4 D3 G3 B3 D4',
        isCustom: true,
        frets: [5, 22, 22, 22, 22],
      );
      final instrument = config.toInstrument();
      expect(instrument.strings[0].fretCount, equals(5));
      expect(instrument.strings[1].fretCount, equals(22));
    });

    test('toInstrument defaults to 22 frets when not specified', () {
      const config = MusicTheoryConfig(
        instrument: 'custom',
        tuningNotes: 'E2 A2 D3 G3',
        isCustom: true,
      );
      final instrument = config.toInstrument();
      expect(instrument.strings[0].fretCount, equals(22));
    });

    test('toInstrument throws if fret count does not match string count', () {
      const config = MusicTheoryConfig(
        instrument: 'custom',
        tuningNotes: 'E2 A2 D3 G3 B3 E4',
        isCustom: true,
        frets: [22, 22, 22], // Only 3 frets for 6 strings
      );
      expect(() => config.toInstrument(), throwsArgumentError);
    });

    test('round-trips custom config through JSON', () {
      const original = MusicTheoryConfig(
        instrument: '7-string',
        tuningNotes: 'B1 E2 A2 D3 G3 B3 E4',
        isCustom: true,
        frets: [24, 24, 24, 24, 24, 24, 24],
        capo: 1,
      );
      final json = original.toJson();
      final restored = MusicTheoryConfig.fromJson(json);
      expect(restored, equals(original));
    });

    test('toString shows custom indicator', () {
      const config = MusicTheoryConfig(
        instrument: '7-string',
        tuningNotes: 'B1 E2 A2 D3 G3 B3 E4',
        isCustom: true,
        frets: [24],
      );
      expect(config.toString(), contains('(custom)'));
      expect(config.toString(), contains('24 frets'));
    });

    test('toString shows per-string frets', () {
      const config = MusicTheoryConfig(
        instrument: 'banjo',
        tuningNotes: 'G4 D3 G3 B3 D4',
        isCustom: true,
        frets: [5, 22, 22, 22, 22],
      );
      expect(config.toString(), contains('frets: 5,22,22,22,22'));
    });
  }, tags: ['unit']);
}
