import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class PermissionUtils {
  static Future<bool> areAllPermissionsGranted() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    // Check camera permission
    final cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) return false;

    // Check storage/photos permission
    PermissionStatus storageStatus;
    if (sdkInt >= 30) { // Android 11+
      storageStatus = await Permission.manageExternalStorage.status;
    } else {
      storageStatus = await Permission.storage.status;
    }
    if (!storageStatus.isGranted) return false;

    // Check location permission
    final locationStatus = await Permission.location.status;
    if (!locationStatus.isGranted) return false;

    // Check contacts permission
    final contactsStatus = await Permission.contacts.status;
    if (!contactsStatus.isGranted) return false;

    return true;
  }

  static Future<void> requestNecessaryPermissions() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    // Request camera permission
    await Permission.camera.request();

    // Request storage/photos permission
    if (sdkInt >= 30) { // Android 11+
      await Permission.manageExternalStorage.request();
    } else {
      await Permission.storage.request();
    }

    // Request location permission
    await Permission.location.request();

    // Request contacts permission
    await Permission.contacts.request();
  }
}
