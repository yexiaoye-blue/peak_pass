import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:kdbx/kdbx.dart';

Future<void> worker() async {
  await Future.delayed(Duration(seconds: 2));
  throw Exception('Error occurred');
}

void main() {
  test('Future test', () async {
    final watch = Stopwatch()..start();
    try {
      await worker();
    } catch (e) {
      print('Error occurred: $e');
    }
    watch.stop();
    print(watch.elapsed.inMilliseconds);
  });
  test('Future test', () {
    final watch = Stopwatch()..start();
    unawaited(worker());
    watch.stop();

    print(watch.elapsed.inMilliseconds);
  });

  test('Future test', () {
    final watch = Stopwatch()..start();
    worker();
    watch.stop();
    print(watch.elapsed.inMilliseconds);
  });

  test('create kdbx file', () async {
    final watch = Stopwatch()..start();
    final kdbx = KdbxFormat().create(
      Credentials(ProtectedValue.fromString('Lorem Ipsum')),
      'Example',
    );

    final group = kdbx.body.rootGroup;
    final entry = KdbxEntry.create(kdbx, group);
    group.addEntry(entry);
    entry.setString(KdbxKeyCommon.USER_NAME, PlainValue('example user'));
    entry.setString(
      KdbxKeyCommon.PASSWORD,
      ProtectedValue.fromString('password'),
    );
    final bytes = await kdbx.save();
    final file = File('example.kdbx');
    await file.writeAsBytes(bytes);

    watch.stop();
    print(watch.elapsed.inMilliseconds);
  });
  test('read kdbx file', () async {
    final watch = Stopwatch()..start();
    final file = File('Database.kdbx');
    final bytes = await file.readAsBytes();
    final kdbx = await KdbxFormat().read(
      bytes,
      Credentials(ProtectedValue.fromString('123')),
    );
    final rootGroup = kdbx.body.rootGroup;
    final allGroups = rootGroup.getAllGroups();
    for (var group in allGroups) {
      print(group.name.name);
    }
    print('----------------------');
    final allEntries = rootGroup.getAllEntries();
    for (var entry in allEntries) {
      print(entry.label);
    }

    watch.stop();
    print(watch.elapsedMilliseconds);
  });
}
