import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../constants/storage_keys.dart';

class DeviceManager {
  static const _secureStorage = FlutterSecureStorage();
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  static Future<String> getDeviceId() async {
    final stored = await _secureStorage.read(key: SecureStorageKeys.deviceId);
    if (stored != null && stored.isNotEmpty) {
      return stored;
    }

    String deviceId;
    try {
      final androidInfo = await _deviceInfo.androidInfo;
      deviceId = androidInfo.id;
    } catch (_) {
      deviceId = DateTime.now().millisecondsSinceEpoch.toString();
    }

    await _secureStorage.write(key: SecureStorageKeys.deviceId, value: deviceId);
    return deviceId;
  }
}