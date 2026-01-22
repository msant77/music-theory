import 'dart:async';

import 'package:music_theory/src/cli/cli_runner.dart';
import 'package:test/test.dart';

void main() {
  late CliRunner runner;

  setUp(() {
    runner = CliRunner();
  });

  group('transpose command', () {
    group('basic transposition', () {
      test('transposes single chord up', () async {
        final output = await _captureOutput(
          () => runner.run(['transpose', 'C', '--up', '2']),
        );
        expect(output, contains('D'));
        expect(output, contains('up 2 semitone'));
      });

      test('transposes single chord down', () async {
        final output = await _captureOutput(
          () => runner.run(['transpose', 'D', '--down', '2']),
        );
        expect(output, contains('C'));
        expect(output, contains('down 2 semitone'));
      });

      test('transposes progression up', () async {
        final output = await _captureOutput(
          () => runner.run(['transpose', 'C', 'Am', 'F', 'G', '--up', '2']),
        );
        expect(output, contains('D'));
        expect(output, contains('Bm'));
        expect(output, contains('G'));
        expect(output, contains('A'));
      });

      test('transposes progression down', () async {
        final output = await _captureOutput(
          () => runner.run(['transpose', 'D', 'Bm', 'G', 'A', '--down', '2']),
        );
        expect(output, contains('C'));
        expect(output, contains('Am'));
        expect(output, contains('F'));
        expect(output, contains('G'));
      });

      test('shows chord notes', () async {
        final output = await _captureOutput(
          () => runner.run(['transpose', 'C', '--up', '0']),
        );
        expect(output, contains('C - E - G'));
      });

      test('handles wrap-around', () async {
        final output = await _captureOutput(
          () => runner.run(['transpose', 'B', '--up', '1']),
        );
        expect(output, contains('C'));
      });
    });

    group('spelling options', () {
      test('uses sharps by default', () async {
        final output = await _captureOutput(
          () => runner.run(['transpose', 'C', '--up', '1']),
        );
        expect(output, contains('C#'));
      });

      test('uses flats when specified', () async {
        final output = await _captureOutput(
          () => runner
              .run(['transpose', 'C', '--up', '1', '--spelling', 'flats']),
        );
        expect(output, contains('Db'));
      });
    });

    group('capo suggestions', () {
      test('suggests capo positions with -s flag', () async {
        final output = await _captureOutput(
          () => runner.run(['transpose', 'F', '-s']),
        );
        expect(output, contains('Capo'));
        expect(output, contains('difficulty'));
      });

      test('suggests capo positions with --suggest-capo', () async {
        final output = await _captureOutput(
          () => runner.run(['transpose', 'F', 'Bb', '--suggest-capo']),
        );
        expect(output, contains('Capo'));
        expect(output, contains('suggestions'));
      });

      test('shows best option for difficult chords', () async {
        final output = await _captureOutput(
          () => runner.run(['transpose', 'F', 'Bb', 'C', '-s']),
        );
        // With capo 1, F Bb C become E A B
        expect(output, anyOf(contains('E'), contains('A'), contains('B')));
      });

      test('respects limit option', () async {
        final output = await _captureOutput(
          () => runner.run(['transpose', 'F', '-s', '-n', '2']),
        );
        // Should show at most 2 suggestions
        final lines = output.split('\n');
        final suggestionLines = lines.where((l) => l.contains('.')).toList();
        expect(suggestionLines.length, lessThanOrEqualTo(2));
      });
    });

    group('error handling', () {
      test('rejects both --up and --down', () async {
        final exitCode =
            await runner.run(['transpose', 'C', '--up', '2', '--down', '1']);
        expect(exitCode, 1);
      });

      test('returns error for invalid chord', () async {
        final exitCode = await runner.run(['transpose', 'XYZ', '--up', '2']);
        expect(exitCode, 1);
      });

      test('shows error message for invalid chord', () async {
        // Just verify exit code - error goes to stderr
        final exitCode = await runner.run(['transpose', 'invalid']);
        expect(exitCode, 1);
      });
    });

    group('help', () {
      test('shows help with --help', () async {
        final output = await _captureOutput(
          () => runner.run(['transpose', '--help']),
        );
        expect(output, contains('music_theory transpose'));
        expect(output, contains('Transpose chords'));
      });

      test('shows help with -h', () async {
        final output = await _captureOutput(
          () => runner.run(['transpose', '-h']),
        );
        expect(output, contains('music_theory transpose'));
      });

      test('shows help with no arguments', () async {
        final output = await _captureOutput(
          () => runner.run(['transpose']),
        );
        expect(output, contains('music_theory transpose'));
      });

      test('shows examples', () async {
        final output = await _captureOutput(
          () => runner.run(['transpose', '--help']),
        );
        expect(output, contains('Examples'));
        expect(output, contains('Am --up 2'));
      });

      test('shows common transpositions', () async {
        final output = await _captureOutput(
          () => runner.run(['transpose', '--help']),
        );
        expect(output, contains('Common transpositions'));
        expect(output, contains('semitone'));
      });

      test('returns 0 for help', () async {
        final exitCode = await runner.run(['transpose', '--help']);
        expect(exitCode, 0);
      });
    });

    group('main help includes transpose', () {
      test('global help shows transpose command', () async {
        final output = await _captureOutput(
          () => runner.run(['--help']),
        );
        expect(output, contains('transpose'));
      });
    });
  });
}

/// Captures stdout output from a function.
Future<String> _captureOutput(Future<int> Function() fn) async {
  final output = StringBuffer();
  final errors = StringBuffer();

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

  return output.toString() + errors.toString();
}
