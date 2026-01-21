/// Music theory CLI tool.
///
/// Provides command-line utilities for working with music theory concepts.
library;

import 'dart:io';

import 'package:args/args.dart';

/// CLI entry point for the music_theory package.
void main(List<String> arguments) {
  final parser = ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Show this help message.',
    )
    ..addFlag(
      'version',
      abbr: 'v',
      negatable: false,
      help: 'Show version information.',
    );

  try {
    final results = parser.parse(arguments);

    if (results['help'] as bool) {
      _printUsage(parser);
      return;
    }

    if (results['version'] as bool) {
      print('music_theory 0.1.0');
      return;
    }

    // No command specified - show usage
    _printUsage(parser);
  } on FormatException catch (e) {
    stderr.writeln('Error: ${e.message}');
    stderr.writeln();
    _printUsage(parser);
    exit(64); // EX_USAGE
  }
}

void _printUsage(ArgParser parser) {
  print('Music Theory CLI');
  print('');
  print('A command-line tool for working with music theory concepts.');
  print('');
  print('Usage: music_theory [options]');
  print('');
  print('Options:');
  print(parser.usage);
  print('');
  print('Commands (coming soon):');
  print('  transpose    Transpose notes or chords');
  print('  analyze      Analyze chord progressions');
  print('  voicings     Show chord voicings for instruments');
}
