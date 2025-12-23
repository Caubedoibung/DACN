/// API Configuration for the application
///
/// For Android Emulator, use: 10.0.2.2 (maps to host's localhost)
/// For iOS Simulator, use: localhost or 127.0.0.1
/// For physical devices on same network, use your computer's IP address
class ApiConfig {
  // Change this based on your environment:
  // - Android Emulator: 'http://10.0.2.2:60491'
  // - iOS Simulator: '${ApiConfig.baseUrl}'
  // - Physical device: 'http://YOUR_COMPUTER_IP:60491' (e.g., 'http://192.168.1.100:60491')
  static const String baseUrl = 'http://localhost:60491';

  // Alternative: Auto-detect platform
  // static String get baseUrl {
  //   if (Platform.isAndroid) {
  //     return 'http://10.0.2.2:60491'; // Android emulator
  //   } else if (Platform.isIOS) {
  //     return '${ApiConfig.baseUrl}'; // iOS simulator
  //   }
  //   return '${ApiConfig.baseUrl}'; // Default
  // }
}
