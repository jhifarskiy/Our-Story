import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;

class BluetoothService {
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  StreamSubscription<fbp.BluetoothAdapterState>? _stateSubscription;
  StreamSubscription<List<fbp.ScanResult>>? _scanSubscription;

  final StreamController<List<fbp.BluetoothDevice>> _devicesController =
      StreamController<List<fbp.BluetoothDevice>>.broadcast();

  Stream<List<fbp.BluetoothDevice>> get devicesStream =>
      _devicesController.stream;

  final List<fbp.BluetoothDevice> _discoveredDevices = [];

  // Инициализация Bluetooth сервиса
  Future<void> initialize() async {
    _stateSubscription = fbp.FlutterBluePlus.adapterState.listen((
      fbp.BluetoothAdapterState state,
    ) {
      print('Bluetooth state: $state');
    });
  }

  // Проверка состояния Bluetooth
  Future<bool> isBluetoothEnabled() async {
    final state = await fbp.FlutterBluePlus.adapterState.first;
    return state == fbp.BluetoothAdapterState.on;
  }

  // Сканирование устройств
  Future<void> startScan({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (!await isBluetoothEnabled()) {
      throw Exception('Bluetooth не включен');
    }

    _discoveredDevices.clear();

    _scanSubscription = fbp.FlutterBluePlus.scanResults.listen((
      List<fbp.ScanResult> results,
    ) {
      _discoveredDevices.clear();
      for (fbp.ScanResult result in results) {
        if (!_discoveredDevices.contains(result.device)) {
          _discoveredDevices.add(result.device);
        }
      }
      _devicesController.add(List.from(_discoveredDevices));
    });

    await fbp.FlutterBluePlus.startScan(timeout: timeout);
  }

  // Остановка сканирования
  Future<void> stopScan() async {
    await fbp.FlutterBluePlus.stopScan();
    await _scanSubscription?.cancel();
  }

  // Подключение к устройству
  Future<fbp.BluetoothDevice?> connectToDevice(
    fbp.BluetoothDevice device,
  ) async {
    try {
      await device.connect(timeout: const Duration(seconds: 10));
      return device;
    } catch (e) {
      print('Ошибка подключения к устройству: $e');
      return null;
    }
  }

  // Отключение от устройства
  Future<void> disconnectFromDevice(fbp.BluetoothDevice device) async {
    try {
      await device.disconnect();
    } catch (e) {
      print('Ошибка отключения от устройства: $e');
    }
  }

  // Получение подключенных устройств
  Future<List<fbp.BluetoothDevice>> getConnectedDevices() async {
    return fbp.FlutterBluePlus.connectedDevices;
  }

  // Отправка данных устройству (пример для кастомного сервиса)
  Future<void> sendData(fbp.BluetoothDevice device, String data) async {
    try {
      List<fbp.BluetoothService> services = await device.discoverServices();
      // Здесь нужно найти нужный сервис и характеристику для отправки данных
      // Это зависит от конкретного протокола обмена данными
      print('Найдено сервисов: ${services.length}');
    } catch (e) {
      print('Ошибка отправки данных: $e');
    }
  }

  // Очистка ресурсов
  void dispose() {
    _stateSubscription?.cancel();
    _scanSubscription?.cancel();
    _devicesController.close();
  }
}
