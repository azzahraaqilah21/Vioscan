import 'dart:async';
import 'package:flutter/services.dart';

enum BleConnectionState {
  disconnected,
  scanning,
  connecting,
  connected,
  capturing,
  transferring,
  done,
  error
}

class BleDevice {
  final String id;
  final String name;
  BleDevice({required this.id, required this.name});
}

/// A Mock BLE Service simulating the BC-Care hardware connection and image transfer.
/// Set [isSimulation] to false when the actual flutter_blue_plus implementation is ready.
class BleService {
  final bool isSimulation = true;

  final _statusController = StreamController<BleConnectionState>.broadcast();
  Stream<BleConnectionState> get statusStream => _statusController.stream;

  final _devicesController = StreamController<List<BleDevice>>.broadcast();
  Stream<List<BleDevice>> get scanResults => _devicesController.stream;

  final _imageDataController = StreamController<Uint8List>.broadcast();
  Stream<Uint8List> get imageDataStream => _imageDataController.stream;

  BleConnectionState _currentState = BleConnectionState.disconnected;
  BleConnectionState get currentState => _currentState;

  Timer? _simulationTimer;

  void _updateStatus(BleConnectionState state) {
    _currentState = state;
    _statusController.add(state);
  }

  Future<void> startScan() async {
    if (!isSimulation) {
      // TODO: Implement flutter_blue_plus scan
      return;
    }

    _updateStatus(BleConnectionState.scanning);
    _devicesController.add([]);

    // Simulate finding a device after 1.5 seconds
    await Future.delayed(const Duration(milliseconds: 1500));
    _devicesController.add([
      BleDevice(id: 'BCC-001-SIM', name: 'BC-Care UV-Scan Pro'),
    ]);
  }

  void stopScan() {
    if (!isSimulation) {
      // TODO: Implement flutter_blue_plus stop scan
      return;
    }
    if (_currentState == BleConnectionState.scanning) {
      _updateStatus(BleConnectionState.disconnected);
    }
  }

  Future<void> connect(BleDevice device) async {
    if (!isSimulation) {
      // TODO: Implement flutter_blue_plus connect
      return;
    }
    _updateStatus(BleConnectionState.connecting);

    // Simulate connection delay
    await Future.delayed(const Duration(seconds: 2));
    _updateStatus(BleConnectionState.connected);
  }

  Future<void> disconnect() async {
    _simulationTimer?.cancel();
    if (!isSimulation) {
      // TODO: Implement flutter_blue_plus disconnect
      return;
    }
    _updateStatus(BleConnectionState.disconnected);
  }

  /// Sends the START_SCAN command to the hardware.
  Future<void> sendStartScanCommand() async {
    if (_currentState != BleConnectionState.connected) return;

    if (!isSimulation) {
      // TODO: Write 0x01 to FFE1 characteristic
      return;
    }

    // SIMULATION FLOW:
    _updateStatus(BleConnectionState.capturing);

    // 1. Hardware takes photo (3 seconds)
    _simulationTimer = Timer(const Duration(seconds: 3), () async {
      _updateStatus(BleConnectionState.transferring);

      // 2. Hardware transfers photo (simulate loading a demo image from assets or generating dummy bytes)
      await Future.delayed(const Duration(seconds: 2));

      // For simulation, we'll send a tiny valid dummy image (1x1 transparent PNG)
      // so that Image.memory doesn't crash, or rely on the UI to load a real asset.
      final dummyBytes = Uint8List.fromList([
        137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1,
        0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137, 0, 0, 0, 10, 73, 68, 65, 84,
        120, 156, 99, 0, 1, 0, 0, 5, 0, 1, 13, 10, 45, 180, 0, 0, 0, 0, 73, 69,
        78, 68, 174, 66, 96, 130
      ]);

      _imageDataController.add(dummyBytes);
      _updateStatus(BleConnectionState.done);
    });
  }
}
