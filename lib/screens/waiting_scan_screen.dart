import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ble_provider.dart';
import '../services/ble_service.dart';

class WaitingScanScreen extends ConsumerStatefulWidget {
  final Function(String) navigate;
  const WaitingScanScreen({super.key, required this.navigate});

  @override
  ConsumerState<WaitingScanScreen> createState() => _WaitingScanScreenState();
}

class _WaitingScanScreenState extends ConsumerState<WaitingScanScreen> {
  @override
  void initState() {
    super.initState();
  }

  void _startScanCommand() {
    ref.read(bleStatusProvider.notifier).sendStartScanCommand();
  }

  void _cancel() {
    // If we want to cancel the BLE process we should implement cancel in BleService
    // For now we'll just disconnect and go back to dashboard
    ref.read(bleStatusProvider.notifier).disconnect();
    widget.navigate('dashboard');
  }

  @override
  Widget build(BuildContext context) {
    // Listen to BLE status changes
    ref.listen<BleConnectionState>(bleStatusProvider, (previous, next) {
      if (next == BleConnectionState.done) {
        // Data transfer complete, image is ready
        widget.navigate('processing');
      }
    });

    final bleState = ref.watch(bleStatusProvider);
    final isScanning = bleState == BleConnectionState.capturing ||
        bleState == BleConnectionState.transferring;

    return Scaffold(
      backgroundColor: const Color(0xFF111827), // Dark mode for scanning
      appBar: AppBar(
        title: const Text('Pemindaian UV',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: _cancel,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        if (isScanning)
                          Container(
                            width: 240,
                            height: 240,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF77DAD7).withOpacity(0.15),
                            ),
                          ),
                        if (isScanning)
                          Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF77DAD7).withOpacity(0.25),
                            ),
                          ),
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF36B8B7), Color(0xFF0A858C)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: isScanning
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF77DAD7)
                                          .withOpacity(0.6),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    )
                                  ]
                                : [],
                          ),
                          child: Icon(
                            bleState == BleConnectionState.transferring
                                ? Icons.sync_rounded
                                : Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                    Text(
                      bleState == BleConnectionState.capturing
                          ? 'Menganalisis...'
                          : bleState == BleConnectionState.transferring
                              ? 'Mentransfer Data...'
                              : 'Siap Memindai',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        bleState == BleConnectionState.capturing
                            ? 'Pastikan perangkat tetap diam pada area lesi. LED UV sedang menyala.'
                            : bleState == BleConnectionState.transferring
                                ? 'Mengirim data gambar resolusi tinggi dari perangkat ke smartphone Anda.'
                                : 'Tempatkan perangkat BC-Care tepat di atas lesi kulit dan tekan tombol di bawah ini.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!isScanning)
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: _startScanCommand,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A858C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Mulai Pemindaian',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            if (isScanning)
              const Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(
                  color: Color(0xFF77DAD7),
                ),
              )
          ],
        ),
      ),
    );
  }
}
