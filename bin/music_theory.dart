import 'dart:io';

import 'package:music_theory/src/cli/cli_runner.dart';

/// CLI entry point for the music_theory package.
Future<void> main(List<String> arguments) async {
  final exitCode = await CliRunner().run(arguments);
  exit(exitCode);
}
