import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class HardwareApiService {
  // IP default Raspberry Pi disesuaikan dengan port 5000
  static String raspiBaseUrl = "http://192.168.209.249:5000";

  /// Fungsi untuk memperbarui IP Raspi secara dinamis dari UI
  static void updateBaseUrl(String newIp) {
    String formattedIp = newIp.trim();
    if (!formattedIp.startsWith('http://') && !formattedIp.startsWith('https://')) {
      raspiBaseUrl = "http://$formattedIp:5000";
    } else {
      raspiBaseUrl = formattedIp;
    }
  }

  /// Cek koneksi ke Raspberry Pi (/ping)
  static Future<bool> checkConnection() async {
    try {
      final res = await http
          .get(Uri.parse('$raspiBaseUrl/ping'))
          .timeout(const Duration(seconds: 4));

      return res.statusCode == 200;
    } catch (e) {
      debugPrint("Check Connection Error: $e");
      return false;
    }
  }

  /// Mengecek status pemindaian ke server Raspberry Pi (/status)
  static Future<Map<String, dynamic>?> checkStatusOrGetResult() async {
    try {
      final response = await http
          .get(Uri.parse('$raspiBaseUrl/status'))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint("Check Status Error: $e");
    }
    return null;
  }

  /// Panggil API scan di Raspberry Pi (/scan) dan menormalisasi response JSON
  static Future<Map<String, dynamic>> triggerScan() async {
    try {
      final response = await http
          .post(
            Uri.parse('$raspiBaseUrl/scan'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // Ambil payload baik langsung dari root maupun terbungkus di 'data'
        final Map<String, dynamic> payload = (data['data'] is Map<String, dynamic>)
            ? data['data'] as Map<String, dynamic>
            : data;

        // Mendukung status 'success' maupun 'ready'
        if (payload['success'] == true || data['status'] == 'ready' || data['status'] == 'success') {
          return {
            'success': true,
            'prediction': payload['prediction'] ?? '',
            'risk_level': payload['risk_level'] ?? '',
            'confidence': payload['confidence'] ?? 0.0,
            'image_base64': payload['image_base64'] ?? payload['image_base64_fluor'] ?? payload['image_base64_derm'] ?? '',
            'image_base64_derm': payload['image_base64_derm'] ?? '',
            'image_base64_fluor': payload['image_base64_fluor'] ?? '',
            'probabilities': payload['probabilities'] ?? {},
          };
        } else {
          throw Exception(data['message'] ?? "Gagal memproses gambar dari kamera Raspi");
        }
      } else {
        throw Exception("Server Error (${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      debugPrint("Trigger Scan Error: $e");
      rethrow;
    }
  }

  /// Cek apakah Raspberry Pi sudah menyediakan hasil scan terbaru dari tombol fisik (/scan/latest)
  static Future<Map<String, dynamic>?> checkLatestScan() async {
    try {
      final response = await http
          .get(Uri.parse('$raspiBaseUrl/scan/latest'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic> && (data['status'] == 'ready' || data['status'] == 'success') && data['data'] != null) {
        final payload = data['data'] as Map<String, dynamic>;

        return {
          'success': true,
          'prediction': payload['prediction'] ?? '',
          'risk_level': payload['risk_level'] ?? '',
          'confidence': payload['confidence'] ?? 0.0,
          'image_base64': payload['image_base64'] ?? payload['image_base64_fluor'] ?? payload['image_base64_derm'] ?? '',
          'image_base64_derm': payload['image_base64_derm'] ?? '',
          'image_base64_fluor': payload['image_base64_fluor'] ?? '',
          'probabilities': payload['probabilities'] ?? {},
        };
      }
      return null;
    } catch (e) {
      debugPrint("Check Latest Scan Error: $e");
      return null;
    }
  }

  /// Jalankan scan dari tombol alternatif di aplikasi
  static Future<Map<String, dynamic>?> triggerSoftwareScan() async {
    try {
      return await triggerScan();
    } catch (_) {
      return null;
    }
  }
}