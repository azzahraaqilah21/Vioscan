// ignore_for_type: deprecated_member_use
// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ble_provider.dart';
import '../services/ble_service.dart';

class HardwareConnectionScreen extends ConsumerStatefulWidget {
  final Function(String) navigate;
  const HardwareConnectionScreen({super.key, required this.navigate});

  @override
  ConsumerState<HardwareConnectionScreen> createState() =>
      _HardwareConnectionScreenState();
}

class _HardwareConnectionScreenState
    extends ConsumerState<HardwareConnectionScreen> {
  @override
  void initState() {
    super.initState();
    // Start scanning when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bleStatusProvider.notifier).startScan();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _connectToDevice(BleDevice device) async {
    await ref.read(bleStatusProvider.notifier).connect(device);
    // After connecting, wait 1 sec and navigate to scanning screen
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      widget.navigate('waiting_scan');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bleState = ref.watch(bleStatusProvider);
    final scanResultsAsync = ref.watch(bleScanResultsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Koneksi Perangkat',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            ref.read(bleStatusProvider.notifier).stopScan();
            widget.navigate('lesion_info');
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE6F7F7), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A858C).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    bleState == BleConnectionState.scanning
                        ? Icons.bluetooth_searching_rounded
                        : bleState == BleConnectionState.connecting
                            ? Icons.bluetooth_connected_rounded
                            : Icons.bluetooth_rounded,
                    size: 36,
                    color: const Color(0xFF0A858C),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  bleState == BleConnectionState.scanning
                      ? 'Mencari Perangkat VioTech...'
                      : bleState == BleConnectionState.connecting
                          ? 'Menghubungkan...'
                          : 'Pilih Perangkat',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pastikan perangkat BC-Care dalam keadaan menyala dan berada di dekat smartphone Anda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                ),
              ],
            ),
          ),
          Expanded(
            child: scanResultsAsync.when(
              data: (devices) {
                if (devices.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'Belum ada perangkat yang ditemukan. Mencari...',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF9CA3AF)),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: devices.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      tileColor: Colors.white,
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.bluetooth,
                            color: Color(0xFF4B5563)),
                      ),
                      title: Text(
                        device.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      subtitle: Text(
                        device.id,
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: bleState == BleConnectionState.connecting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF0A858C),
                              ),
                            )
                          : const Icon(Icons.chevron_right_rounded),
                      onTap: bleState == BleConnectionState.connecting
                          ? null
                          : () => _connectToDevice(device),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
