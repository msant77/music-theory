import 'dart:async';

import 'package:music_theory/src/cli/cli_runner.dart';
import 'package:test/test.dart';

void main() {
  late CliRunner runner;

  setUp(() {
    runner = CliRunner();
  });

  group('analyze command', () {
    group('basic functionality', () {
      test('analyzes pop progression', () async {
        final output = await _captureOutput(
          () => runner.run(['analyze', 'C', 'Am', 'F', 'G']),
        );
        expect(output, contains('Detected key'));
        expect(output, contains('Roman numerals'));
        expect(output, contains('I'));
        expect(output, contains('vi'));
        expect(output, contains('IV'));
        expect(output, contains('V'));
      });

      test('detects C major key', () async {
        final output = await _captureOutput(
          () => runner.run(['analyze', 'C', 'G', 'Am', 'F']),
        );
        expect(output, contains('C'));
        expect(output, contains('confidence'));
      });

      test('shows chord functions', () async {
        final output = await _captureOutput(
          () => runner.run(['analyze', 'C', 'Am', 'F', 'G']),
        );
        expect(output, contains('tonic'));
        expect(output, contains('submediant'));
        expect(output, contains('subdominant'));
        expect(output, contains('dominant'));
      });

      test('recognizes 50s progression pattern', () async {
        final output = await _captureOutput(
          () => runner.run(['analyze', 'C', 'Am', 'F', 'G']),
        );
        expect(output, contains('50s progression'));
      });

      test('recognizes pop progression pattern', () async {
        final output = await _captureOutput(
          () => runner.run(['analyze', 'C', 'G', 'Am', 'F']),
        );
        expect(output, contains('Pop progression'));
      });

      test('recognizes ii-V-I pattern', () async {
        final output = await _captureOutput(
          () => runner.run(['analyze', 'Dm7', 'G7', 'Cmaj7']),
        );
        expect(output, contains('ii-V-I'));
      });
    });

    group('--key-only option', () {
      test('shows only detected key', () async {
        final output = await _captureOutput(
          () => runner.run(['analyze', 'C', 'Am', 'F', 'G', '--key-only']),
        );
        expect(output, contains('Detected key'));
        expect(output, isNot(contains('Roman numerals')));
      });

      test('-k is alias for --key-only', () async {
        final output = await _captureOutput(
          () => runner.run(['analyze', 'C', 'Am', 'F', 'G', '-k']),
        );
        expect(output, contains('Detected key'));
        expect(output, isNot(contains('Roman numerals')));
      });

      test('shows alternative keys', () async {
        final output = await _captureOutput(
          () => runner.run(['analyze', 'C', 'Am', '-k']),
        );
        expect(output, contains('Other possibilities'));
      });
    });

    group('--key option', () {
      test('analyzes in specified key', () async {
        final output = await _captureOutput(
          () => runner.run(['analyze', 'Am', 'G', 'F', 'E', '--key', 'Am']),
        );
        expect(output, contains('Key: Am'));
        expect(output, contains('i'));
        expect(output, contains('VII'));
        expect(output, contains('VI'));
        expect(output, contains('V'));
      });

      test('handles minor key specification', () async {
        final output = await _captureOutput(
          () => runner.run(['analyze', 'Am', 'Dm', 'E', '--key', 'Am']),
        );
        expect(output, contains('Key: Am'));
      });

      test('handles sharp keys', () async {
        final output = await _captureOutput(
          () => runner.run(['analyze', 'F#', 'B', 'C#', '--key', 'F#']),
        );
        // F# and Gb are enharmonic - either is acceptable
        expect(output, anyOf(contains('Key: F#'), contains('Key: Gb')));
      });
    });

    group('error handling', () {
      test('returns error for invalid chords', () async {
        final exitCode = await runner.run(['analyze', 'XYZ']);
        expect(exitCode, 1);
      });

      test('returns error for invalid key', () async {
        final exitCode =
            await runner.run(['analyze', 'C', 'G', '--key', 'XYZ']);
        expect(exitCode, 1);
      });
    });

    group('help', () {
      test('shows help with --help', () async {
        final output = await _captureOutput(
          () => runner.run(['analyze', '--help']),
        );
        expect(output, contains('music_theory analyze'));
        expect(output, contains('Analyze a chord progression'));
      });

      test('shows help with -h', () async {
        final output = await _captureOutput(
          () => runner.run(['analyze', '-h']),
        );
        expect(output, contains('music_theory analyze'));
      });

      test('shows help with no arguments', () async {
        final output = await _captureOutput(
          () => runner.run(['analyze']),
        );
        expect(output, contains('music_theory analyze'));
      });

      test('shows examples', () async {
        final output = await _captureOutput(
          () => runner.run(['analyze', '--help']),
        );
        expect(output, contains('Examples'));
      });

      test('explains Roman numerals', () async {
        final output = await _captureOutput(
          () => runner.run(['analyze', '--help']),
        );
        expect(output, contains('Understanding Roman numerals'));
        expect(output, contains('tonic'));
        expect(output, contains('dominant'));
      });

      test('returns 0 for help', () async {
        final exitCode = await runner.run(['analyze', '--help']);
        expect(exitCode, 0);
      });
    });

    group('main help includes analyze', () {
      test('global help shows analyze command', () async {
        final output = await _captureOutput(
          () => runner.run(['--help']),
        );
        expect(output, contains('analyze'));
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
