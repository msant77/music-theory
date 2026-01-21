import 'dart:async';

import 'package:music_theory/src/cli/cli_runner.dart';
import 'package:test/test.dart';

void main() {
  late CliRunner runner;

  setUp(() {
    runner = CliRunner();
  });

  group('chord command', () {
    group('single chord', () {
      test('shows major chord info', () async {
        final output = await _captureOutput(() => runner.run(['chord', 'C']));
        expect(output, contains('C major'));
        expect(output, contains('C - E - G'));
        expect(output, contains('R - M3 - P5'));
      });

      test('shows minor chord info', () async {
        final output = await _captureOutput(() => runner.run(['chord', 'Am']));
        expect(output, contains('A minor'));
        expect(output, contains('A - C - E'));
        expect(output, contains('R - m3 - P5'));
      });

      test('shows seventh chord info', () async {
        final output = await _captureOutput(() => runner.run(['chord', 'G7']));
        expect(output, contains('G dominant 7th'));
        expect(output, contains('G - B - D - F'));
        expect(output, contains('R - M3 - P5 - m7'));
      });

      test('shows major seventh chord info', () async {
        final output = await _captureOutput(() => runner.run(['chord', 'Cmaj7']));
        expect(output, contains('C major 7th'));
        expect(output, contains('C - E - G - B'));
        expect(output, contains('R - M3 - P5 - M7'));
      });

      test('shows chord with sharp', () async {
        final output = await _captureOutput(() => runner.run(['chord', 'F#m']));
        expect(output, contains('F# minor'));
        expect(output, contains('F# - A - C#'));
      });

      test('shows chord with flat input (displayed as sharp)', () async {
        // Bb is enharmonically equivalent to A#, PitchClass uses sharps
        final output = await _captureOutput(() => runner.run(['chord', 'Bb']));
        expect(output, contains('A# major'));
        expect(output, contains('A# - D - F'));
      });

      test('shows diminished chord', () async {
        final output = await _captureOutput(() => runner.run(['chord', 'Bdim']));
        expect(output, contains('B diminished'));
        expect(output, contains('B - D - F'));
        expect(output, contains('d5'));
      });

      test('shows augmented chord', () async {
        final output = await _captureOutput(() => runner.run(['chord', 'Caug']));
        expect(output, contains('C augmented'));
        expect(output, contains('C - E - G#'));
      });

      test('shows suspended chord', () async {
        final output = await _captureOutput(() => runner.run(['chord', 'Dsus4']));
        expect(output, contains('D suspended 4th'));
        expect(output, contains('D - G - A'));
      });

      test('shows beginner-friendly interval explanations', () async {
        final output = await _captureOutput(() => runner.run(['chord', 'Am']));
        expect(output, contains('Root'));
        expect(output, contains('minor third'));
        expect(output, contains('perfect fifth'));
      });
    });

    group('chord comparison', () {
      test('compares two chords', () async {
        final output = await _captureOutput(() => runner.run(['chord', 'C', 'Am']));
        expect(output, contains('Comparing C and Am'));
        expect(output, contains('C - E - G'));
        expect(output, contains('A - C - E'));
      });

      test('shows common notes', () async {
        final output = await _captureOutput(() => runner.run(['chord', 'C', 'Am']));
        expect(output, contains('Common notes'));
        expect(output, contains('C'));
        expect(output, contains('E'));
      });

      test('shows unique notes', () async {
        final output = await _captureOutput(() => runner.run(['chord', 'C', 'Am']));
        expect(output, contains('Only in C'));
        expect(output, contains('G'));
        expect(output, contains('Only in Am'));
        expect(output, contains('A'));
      });

      test('compares chords with no common notes', () async {
        final output = await _captureOutput(() => runner.run(['chord', 'C', 'F#']));
        expect(output, contains('No common notes'));
      });
    });

    group('error handling', () {
      test('returns error for invalid chord', () async {
        final exitCode = await runner.run(['chord', 'XYZ']);
        expect(exitCode, equals(1));
      });

      test('returns error for invalid first chord in comparison', () async {
        final exitCode = await runner.run(['chord', 'XYZ', 'Am']);
        expect(exitCode, equals(1));
      });

      test('returns error for invalid second chord in comparison', () async {
        final exitCode = await runner.run(['chord', 'Am', 'XYZ']);
        expect(exitCode, equals(1));
      });

      test('returns error for too many arguments', () async {
        final exitCode = await runner.run(['chord', 'C', 'Am', 'G']);
        expect(exitCode, equals(64));
      });
    });

    group('help', () {
      test('shows help with --help flag', () async {
        final output = await _captureOutput(() => runner.run(['chord', '--help']));
        expect(output, contains('music_theory chord'));
        expect(output, contains('Show chord notes and formula'));
      });

      test('shows help with -h flag', () async {
        final output = await _captureOutput(() => runner.run(['chord', '-h']));
        expect(output, contains('music_theory chord'));
      });

      test('shows help with no arguments', () async {
        final output = await _captureOutput(() => runner.run(['chord']));
        expect(output, contains('music_theory chord'));
      });

      test('help shows examples', () async {
        final output = await _captureOutput(() => runner.run(['chord', '--help']));
        expect(output, contains('Examples'));
        expect(output, contains('music_theory chord Am'));
      });

      test('help shows supported chord types', () async {
        final output = await _captureOutput(() => runner.run(['chord', '--help']));
        expect(output, contains('Supported chord types'));
        expect(output, contains('Major'));
        expect(output, contains('Minor'));
        expect(output, contains('Seventh'));
      });

      test('returns 0 exit code for help', () async {
        final exitCode = await runner.run(['chord', '--help']);
        expect(exitCode, equals(0));
      });
    });

    group('main help includes chord command', () {
      test('global help shows chord command', () async {
        final output = await _captureOutput(() => runner.run(['--help']));
        expect(output, contains('chord'));
        expect(output, contains('Show chord notes and formula'));
      });
    });
  });
}

/// Captures stdout output from a function.
Future<String> _captureOutput(Future<int> Function() fn) async {
  final output = StringBuffer();
  await runZoned(
    () async {
      await fn();
    },
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) {
        output.writeln(line);
      },
    ),
  );
  return output.toString();
}
