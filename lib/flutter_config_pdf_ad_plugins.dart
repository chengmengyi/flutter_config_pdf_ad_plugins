
import 'flutter_config_pdf_ad_plugins_platform_interface.dart';

class FlutterConfigPdfAdPlugins {
  Future<String?> getPlatformVersion() {
    return FlutterConfigPdfAdPluginsPlatform.instance.getPlatformVersion();
  }
}
