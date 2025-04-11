import 'dart:io';
import 'package:build_tool/src/artifacts_provider.dart';
import 'package:build_tool/src/builder.dart';
import 'package:build_tool/src/cargo.dart';
import 'package:build_tool/src/options.dart';
import 'package:build_tool/src/target.dart';
import 'package:test/test.dart';

class _MockBuildEnvironment implements BuildEnvironment {
  @override
  final BuildConfiguration configuration = BuildConfiguration.debug;

  @override
  final CargokitCrateOptions crateOptions = CargokitCrateOptions();

  @override
  final String targetTempDir =
      Directory.systemTemp.createTempSync('artifact_provider_test_').path;

  @override
  final String manifestDir = '/mock/manifest/dir';

  @override
  final CrateInfo crateInfo = CrateInfo(packageName: 'test_crate');

  @override
  final bool isAndroid = false;

  @override
  final String? androidSdkPath = null;

  @override
  final String? androidNdkVersion = null;

  @override
  final int? androidMinSdkVersion = null;

  @override
  final String? javaHome = null;

  void cleanup() {
    Directory(targetTempDir).deleteSync(recursive: true);
  }
}

void main() {
  late _MockBuildEnvironment environment;

  setUp(() {
    environment = _MockBuildEnvironment();
  });

  tearDown(() {
    environment.cleanup();
  });

  test('_generatePossibleArtifactNames with no features', () {
    final userOptions = CargokitUserOptions(
      usePrecompiledBinaries: true,
      verboseLogging: false,
      enabledFeatures: [],
    );

    final provider = ArtifactProvider(
      environment: environment,
      userOptions: userOptions,
    );

    final target = Target.forRustTriple('x86_64-apple-darwin')!;

    // Use reflection to access private method
    final possibleNames = provider.generatePossibleArtifactNames(
      target,
      'test_crate',
      userOptions.enabledFeatures,
    );

    expect(possibleNames, ['libtest_crate.a']);
  });

  test('_generatePossibleArtifactNames with features', () {
    final userOptions = CargokitUserOptions(
      usePrecompiledBinaries: true,
      verboseLogging: false,
      enabledFeatures: ['foo', 'bar'],
    );

    final provider = ArtifactProvider(
      environment: environment,
      userOptions: userOptions,
    );

    final target = Target.forRustTriple('x86_64-apple-darwin')!;

    // Use reflection to access private method
    final possibleNames = provider.generatePossibleArtifactNames(
      target,
      'test_crate',
      userOptions.enabledFeatures,
    );

    // Should have feature-specific name first, then fallback
    expect(
        possibleNames, ['libtest_crate.a_features_bar_foo', 'libtest_crate.a']);
  });
}
