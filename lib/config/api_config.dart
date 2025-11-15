import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

class ApiConfig {
  static String get baseUrl {
    // Priority 1: explicit override
    const defined = String.fromEnvironment('BASE_URL');
    if (defined.isNotEmpty) return defined.endsWith('/api') ? defined : '$defined/api';

    // Optional flags for quick switching without code changes
    const useAdbReverse = bool.fromEnvironment('USE_ADB_REVERSE'); // 127.0.0.1 -> via `adb reverse`
    const deviceBase = String.fromEnvironment('DEVICE_BASE_URL'); // e.g. http://10.144.129.8:8000
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        if (useAdbReverse) return 'http://127.0.0.1:8000/api';
        if (deviceBase.isNotEmpty) {
          final base = deviceBase.endsWith('/api') ? deviceBase : '$deviceBase/api';
          return base;
        }
        // 🎯 UNTUK HP FISIK - gunakan IP laptop Anda
        // Ubah IP ini sesuai IP laptop di network hotspot
        // Cek IP dengan: ipconfig (Windows) atau ifconfig (Linux/Mac)
        // return 'http://10.144.129.8:8000/api';
        
        // UNTUK EMULATOR - uncomment line dibawah ini dan comment line diatas
        return 'http://10.0.2.2:8000/api';
      case TargetPlatform.iOS:
        return 'http://localhost:8000/api';
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return 'http://localhost:8000/api';
      default:
        // ⚠️ UNTUK HP FISIK - UBAH IP INI ⚠️
        // Dari ipconfig Anda, IP Wi-Fi = 10.144.129.8
        // Jadi ganti line dibawah ini dengan IP laptop Anda
        return 'http://10.144.129.8:8000/api';  // ⬅️ INI SUDAH BENAR untuk HP Anda!
    }
  }
}
