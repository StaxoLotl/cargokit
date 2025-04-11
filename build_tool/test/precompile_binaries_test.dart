import 'dart:io';
import 'package:build_tool/src/precompile_binaries.dart';
import 'package:build_tool/src/target.dart';
import 'package:build_tool/src/options.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;

// Mock environment for testing
class _MockEnvironment {
  static String setupMockUserOptions(Map<String, dynamic> options) {
    final tempDir = Directory.systemTemp.createTempSync('cargokit_test_');
    final optionsFile = File(path.join(tempDir.path, 'cargokit_options.yaml'));

    final yamlContent = StringBuffer();
    for (final entry in options.entries) {
      if (entry.value is List) {
        yamlContent.writeln('${entry.key}:');
        for (final item in entry.value) {
          yamlContent.writeln('  - $item');
        }
      } else {
        yamlContent.writeln('${entry.key}: ${entry.value}');
      }
    }

    optionsFile.writeAsStringSync(yamlContent.toString());
    return tempDir.path;
  }

  static void cleanupMockUserOptions(String tempDirPath) {
    Directory(tempDirPath).deleteSync(recursive: true);
  }
}

void main() {
  final target = Target.forRustTriple('x86_64-apple-darwin')!;

  group('PrecompileBinaries', () {
    test('fileName without features', () {
      final result = PrecompileBinaries.fileName(target, 'libtest.a');
      expect(result, 'x86_64-apple-darwin_libtest.a');
    });

    test('fileName with existing features in name', () {
      final result =
          PrecompileBinaries.fileName(target, 'libtest_features_foo_bar.a');
      expect(result, 'x86_64-apple-darwin_libtest_features_foo_bar.a');
    });

    test('signatureFileName', () {
      final result = PrecompileBinaries.signatureFileName(target, 'libtest.a');
      expect(result, 'x86_64-apple-darwin_libtest.a.sig');
    });
  });
}
