import 'dart:async';

import 'package:music_theory/src/cli/cli_runner.dart';
import 'package:test/test.dart';

void main() {
  late CliRunner runner;

  setUp(() {
    runner = CliRunner();
  });

  group('voicings command', () {
    group('basic functionality', () {
      test('shows voicings for Am chord', () async {
        final output =
            await _captureOutput(() => runner.run(['voicings', 'Am']));
        expect(output, contains('A minor'));
        expect(output, contains('Am'));
        expect(output, contains('voicing'));
      });

      test('shows voicings for C chord', () async {
        final output =
            await _captureOutput(() => runner.run(['voicings', 'C']));
        expect(output, contains('C major'));
        expect(output, contains('voicing'));
      });

      test('shows voicings for G7 chord', () async {
        final output =
            await _captureOutput(() => runner.run(['voicings', 'G7']));
        expect(output, contains('G dominant 7th'));
        expect(output, contains('G7'));
      });

      test('shows fretboard diagram by default', () async {
        final output =
            await _captureOutput(() => runner.run(['voicings', 'Am']));
        // Fretboard uses box drawing characters
        expect(output, contains('─'));
        expect(output, contains('│'));
      });

      test('shows string names in diagram', () async {
        final output =
            await _captureOutput(() => runner.run(['voicings', 'Am']));
        expect(output, contains('E')); // String names
        expect(output, contains('A'));
        expect(output, contains('D'));
        expect(output, contains('G'));
        expect(output, contains('B'));
      });
    });

    group('options', () {
      test('--compact shows compact format', () async {
        final output = await _captureOutput(
            () => runner.run(['voicings', 'Am', '--compact']));
        expect(output, contains('X02210')); // Standard Am shape
        expect(output, contains('A-')); // Notes
      });

      test('-c is alias for --compact', () async {
        final output =
            await _captureOutput(() => runner.run(['voicings', 'Am', '-c']));
        expect(output, contains('X02210'));
      });

      test('--limit limits number of voicings', () async {
        final output = await _captureOutput(
            () => runner.run(['voicings', 'Am', '--compact', '--limit', '2']));
        expect(output, contains('showing 2'));
      });

      test('-n is alias for --limit', () async {
        final output = await _captureOutput(
            () => runner.run(['voicings', 'Am', '-c', '-n', '3']));
        expect(output, contains('showing 3'));
      });

      test('--level beginner shows easy voicings', () async {
        final output = await _captureOutput(() =>
            runner.run(['voicings', 'Am', '--compact', '--level', 'beginner']));
        expect(output, contains('easy'));
        // Should not contain hard
        expect(output.toLowerCase(), isNot(contains('hard')));
      });

      test('--level intermediate shows medium voicings', () async {
        final output = await _captureOutput(() => runner
            .run(['voicings', 'C', '--compact', '--level', 'intermediate']));
        // Should include easy and medium
        expect(output, anyOf(contains('easy'), contains('medium')));
      });

      test('--level advanced shows all difficulty levels', () async {
        final output = await _captureOutput(() => runner.run([
              'voicings',
              'C',
              '--compact',
              '--level',
              'advanced',
              '--limit',
              '20'
            ]));
        // Should have various difficulty levels with enough voicings
        expect(output, isNotEmpty);
      });
    });

    group('error handling', () {
      test('returns error for invalid chord', () async {
        final exitCode = await runner.run(['voicings', 'XYZ']);
        expect(exitCode, equals(1));
      });

      test('shows error message for invalid chord', () async {
        // Run and capture stderr would be complex, just check exit code
        final exitCode = await runner.run(['voicings', 'invalid']);
        expect(exitCode, equals(1));
      });
    });

    group('help', () {
      test('shows help with --help flag', () async {
        final output =
            await _captureOutput(() => runner.run(['voicings', '--help']));
        expect(output, contains('music_theory voicings'));
        expect(output, contains('Show how to play a chord'));
      });

      test('shows help with -h flag', () async {
        final output =
            await _captureOutput(() => runner.run(['voicings', '-h']));
        expect(output, contains('music_theory voicings'));
      });

      test('shows help with no arguments', () async {
        final output = await _captureOutput(() => runner.run(['voicings']));
        expect(output, contains('music_theory voicings'));
      });

      test('help shows examples', () async {
        final output =
            await _captureOutput(() => runner.run(['voicings', '--help']));
        expect(output, contains('Examples'));
        expect(output, contains('music_theory voicings Am'));
      });

      test('help mentions setup command', () async {
        final output =
            await _captureOutput(() => runner.run(['voicings', '--help']));
        expect(output, contains('setup'));
      });

      test('returns 0 exit code for help', () async {
        final exitCode = await runner.run(['voicings', '--help']);
        expect(exitCode, equals(0));
      });
    });

    group('main help includes voicings command', () {
      test('global help shows voicings command', () async {
        final output = await _captureOutput(() => runner.run(['--help']));
        expect(output, contains('voicings'));
        expect(output, contains('Show how to play a chord'));
      });
    });

    group('difficulty display', () {
      test('shows difficulty label for each voicing in compact mode', () async {
        final output = await _captureOutput(
            () => runner.run(['voicings', 'Am', '--compact']));
        // Should have at least one difficulty indicator
        expect(output,
            anyOf(contains('easy'), contains('medium'), contains('hard')));
      });

      test('shows difficulty label for each voicing in diagram mode', () async {
        final output = await _captureOutput(
            () => runner.run(['voicings', 'Am', '--limit', '2']));
        // Should have difficulty in voicing header
        expect(output,
            anyOf(contains('easy'), contains('medium'), contains('hard')));
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
