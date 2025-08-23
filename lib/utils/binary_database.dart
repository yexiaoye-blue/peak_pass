import 'dart:async';
import 'dart:collection' show Queue;
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// 命令代码，用于在 [BinaryDatabase] 和 [_BinaryDatabaseServer] 之间通信。
enum _Codes { init, add, read, ack, result, done }

/// 通信命令类。
class _Command {
  const _Command(this.code, {this.data});

  final _Codes code;
  final Object? data;
}

/// 单例的BinaryDatabase类
class BinaryDatabase with WidgetsBindingObserver {
  // 私有构造函数，防止外部创建多个实例
  BinaryDatabase._(this._isolate) {
    WidgetsBinding.instance.addObserver(this);
  }

  static BinaryDatabase? _instance;

  final Isolate _isolate;
  late final SendPort _sendPort;
  final Queue<Completer<void>> _completers = Queue<Completer<void>>();
  final Queue<StreamController<Uint8List>> _resultsStream =
      Queue<StreamController<Uint8List>>();

  /// 提供唯一的实例
  static Future<BinaryDatabase> getInstance(String path) async {
    if (_instance == null) {
      final ReceivePort receivePort = ReceivePort();
      final Isolate isolate = await Isolate.spawn<(SendPort, String)>(
        _BinaryDatabaseServer._run,
        (receivePort.sendPort, path),
      );
      _instance = BinaryDatabase._(isolate);
      Completer<void> completer = Completer<void>();
      _instance!._completers.addFirst(completer);
      receivePort.listen((message) {
        _instance!._handleCommand(message as _Command);
      });
      await completer.future;
    }
    return _instance!;
  }

  /// 将二进制数据写入数据库，覆盖原有内容。
  Future<void> addData(Uint8List data) {
    Completer<void> completer = Completer<void>();
    _completers.addFirst(completer);
    _sendPort.send(_Command(_Codes.add, data: data));
    return completer.future;
  }

  /// 读取文件中所有二进制数据，以流的形式返回。
  Stream<Uint8List> readData() {
    StreamController<Uint8List> resultsStream = StreamController<Uint8List>();
    _resultsStream.addFirst(resultsStream);
    _sendPort.send(const _Command(_Codes.read));
    return resultsStream.stream;
  }

  /// 处理从后台隔离进程接收到的命令。
  void _handleCommand(_Command command) {
    switch (command.code) {
      case _Codes.init:
        _sendPort = command.data as SendPort;
        RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
        _sendPort.send(_Command(_Codes.init, data: rootIsolateToken));
        break;
      case _Codes.ack:
        _completers.removeLast().complete();
        break;
      case _Codes.result:
        _resultsStream.last.add(command.data as Uint8List);
        break;
      case _Codes.done:
        _resultsStream.removeLast().close();
        break;
      default:
        debugPrint('BinaryDatabase unrecognized command: ${command.code}');
    }
  }

  /// 停止后台隔离进程并关闭数据库。
  Future<void> stop() async {
    _isolate.kill();
    WidgetsBinding.instance.removeObserver(this);
  }

  /// Flutter应用生命周期监听，程序停止时销毁资源
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      stop();
    }
  }
}

/// 在后台隔离进程中运行的数据库服务器部分。
class _BinaryDatabaseServer {
  _BinaryDatabaseServer(this._sendPort, this._path);

  final SendPort _sendPort;
  final String _path;

  /// 后台隔离进程的主入口。
  static void _run((SendPort, String) args) {
    final SendPort sendPort = args.$1;
    final String path = args.$2;
    sendPort.send(_Command(_Codes.init, data: sendPort));
    final _BinaryDatabaseServer server = _BinaryDatabaseServer(sendPort, path);
    final ReceivePort receivePort = ReceivePort();
    receivePort.listen((message) async {
      final _Command command = message as _Command;
      await server._handleCommand(command);
    });
  }

  /// 处理接收到的命令。
  Future<void> _handleCommand(_Command command) async {
    switch (command.code) {
      case _Codes.init:
        RootIsolateToken rootIsolateToken = command.data as RootIsolateToken;
        BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
        _sendPort.send(const _Command(_Codes.ack));
        break;
      case _Codes.add:
        await _doAddData(command.data as Uint8List);
        break;
      case _Codes.read:
        await _doReadData();
        break;
      default:
        debugPrint(
          '_BinaryDatabaseServer unrecognized command: ${command.code}',
        );
    }
  }

  /// 执行添加二进制数据的操作，覆盖文件内容。
  Future<void> _doAddData(Uint8List data) async {
    try {
      File file = File(_path);
      RandomAccessFile writer = await file.open(mode: FileMode.write);
      await writer.setPosition(0); // 将文件指针设置为开头
      await writer.truncate(0); // 清空文件内容
      await writer.writeFrom(data); // 写入新数据
      await writer.close();
      _sendPort.send(const _Command(_Codes.ack));
    } catch (e) {
      debugPrint('Error adding data: $e');
      _sendPort.send(const _Command(_Codes.ack));
    }
  }

  /// 执行读取二进制数据的操作。
  Future<void> _doReadData() async {
    try {
      File file = File(_path);
      if (file.existsSync()) {
        RandomAccessFile reader = await file.open();
        const int chunkSize = 1024; // 每次读取 1KB 数据
        Uint8List buffer = Uint8List(chunkSize);
        int bytesRead;
        while ((bytesRead = await reader.readInto(buffer)) > 0) {
          _sendPort.send(
            _Command(_Codes.result, data: buffer.sublist(0, bytesRead)),
          );
        }
        await reader.close();
      }
      _sendPort.send(const _Command(_Codes.done));
    } catch (e) {
      debugPrint('Error reading data: $e');
      _sendPort.send(const _Command(_Codes.done));
    }
  }
}
