import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_config_pdf_ad_plugins_platform_interface.dart';

/// An implementation of [FlutterConfigPdfAdPluginsPlatform] that uses method channels.
class MethodChannelFlutterConfigPdfAdPlugins extends FlutterConfigPdfAdPluginsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_config_pdf_ad_plugins');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
