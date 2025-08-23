import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:peak_pass/main.dart';
import 'package:peak_pass/utils/binary_database.dart';
import 'package:peak_pass/utils/common_utils.dart';

void main() {
  group('BinaryDatabase Tests', () {
    testWidgets('write and read data', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // 假设测试使用的路径为'/tmp/test_database.dat'
      final dirObj = await getApplicationCacheDirectory();
      final path = '${dirObj.path}/test_database.dat';
      logger.d(path);

      // 打开数据库实例
      final database = await BinaryDatabase.getInstance(path);

      // 创建一些数据
      final dataToWrite = Uint8List.fromList([1, 2, 3, 4, 5]);

      // 将数据写入数据库
      await database.addData(dataToWrite);

      // 从数据库读取数据
      final dataStream = database.readData();

      // 收集数据
      List<Uint8List> readDataChunks = [];
      await for (final chunk in dataStream) {
        readDataChunks.add(chunk);
      }

      // 合并读取的数据
      final readData = Uint8List.fromList(
        readDataChunks.expand((e) => e).toList(),
      );

      // 验证写入和读取的数据一致
      expect(readData, equals(dataToWrite));

      // 停止数据库
      await database.stop();
    });

    test('read empty database', () async {
      // 使用一个空数据库路径
      final dirObj = await getApplicationCacheDirectory();
      final path = '${dirObj.path}/test_empty_database.dat';
      logger.d(path);

      // 打开数据库实例
      final database = await BinaryDatabase.getInstance(path);

      // 从数据库读取数据
      final dataStream = database.readData();

      // 收集数据
      List<Uint8List> readDataChunks = [];
      await for (final chunk in dataStream) {
        readDataChunks.add(chunk);
      }

      // 合并读取的数据
      final readData = Uint8List.fromList(
        readDataChunks.expand((e) => e).toList(),
      );

      // 验证读取的数据为空
      expect(readData.isEmpty, isTrue);

      // 停止数据库
      await database.stop();
    });
  });
}
