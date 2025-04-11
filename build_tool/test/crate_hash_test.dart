import 'dart:io';
import 'package:build_tool/src/crate_hash.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;

void main() {
  late Directory tempDir;
  late String crateDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('crate_hash_test_');
    crateDir = path.join(tempDir.path, 'test_crate');
    Directory(crateDir).createSync();

    // Create a minimal crate structure
    File(path.join(crateDir, 'Cargo.toml')).writeAsStringSync(
        '[package]\nname = "test_crate"\nversion = "0.1.0"\n');

    final srcDir = Directory(path.join(crateDir, 'src'));
    srcDir.createSync();
    File(path.join(srcDir.path, 'lib.rs')).writeAsStringSync(
        'pub fn hello() -> &\'static str { "Hello, World!" }\n');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  test('compute hash without features', () {
    final hash1 = CrateHash.compute(crateDir);
    expect(hash1, isNotEmpty);

    // Computing it twice should yield the same result
    final hash2 = CrateHash.compute(crateDir);
    expect(hash2, equals(hash1));
  });

  test('compute hash with features', () {
    final hash1 = CrateHash.compute(crateDir);
    final hashWithFeatures =
        CrateHash.compute(crateDir, features: ['foo', 'bar']);

    // Hash with features should be different from hash without features
    expect(hashWithFeatures, isNot(equals(hash1)));

    // Order of features shouldn't matter
    final hashWithFeaturesDifferentOrder =
        CrateHash.compute(crateDir, features: ['bar', 'foo']);
    expect(hashWithFeaturesDifferentOrder, equals(hashWithFeatures));
  });
}
