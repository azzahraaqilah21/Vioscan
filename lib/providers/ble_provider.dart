import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ble_service.dart';

/// Singleton BleService provider
final bleServiceProvider = Provider<BleService>((ref) {
  return BleService();
});

/// Stream provider for BLE scan results
final bleScanResultsProvider = StreamProvider<List<BleDevice>>((ref) {
  final service = ref.watch(bleServiceProvider);
  return service.scanResults;
});

/// StateNotifier to keep track of the current BLE connection status
class BleStatusNotifier extends StateNotifier<BleConnectionState> {
  BleStatusNotifier(this._service) : super(_service.currentState) {
    _service.statusStream.listen((state) {
      if (mounted) this.state = state;
    });
  }

  final BleService _service;

  Future<void> startScan() => _service.startScan();
  void stopScan() => _service.stopScan();
  Future<void> connect(BleDevice device) => _service.connect(device);
  Future<void> disconnect() => _service.disconnect();
  Future<void> sendStartScanCommand() => _service.sendStartScanCommand();
}

final bleStatusProvider =
    StateNotifierProvider<BleStatusNotifier, BleConnectionState>((ref) {
  final service = ref.watch(bleServiceProvider);
  return BleStatusNotifier(service);
});

/// StateNotifier to hold the final captured image from the hardware
class CapturedImageNotifier extends StateNotifier<Uint8List?> {
  CapturedImageNotifier(this._service) : super(null) {
    _service.imageDataStream.listen((data) {
      if (mounted) state = data;
    });
  }

  final BleService _service;

  void clear() {
    state = null;
  }
}

final capturedImageProvider =
    StateNotifierProvider<CapturedImageNotifier, Uint8List?>((ref) {
  final service = ref.watch(bleServiceProvider);
  return CapturedImageNotifier(service);
});
