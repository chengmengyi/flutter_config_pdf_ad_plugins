import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_config_pdf_ad_plugins_method_channel.dart';

abstract class FlutterConfigPdfAdPluginsPlatform extends PlatformInterface {
  /// Constructs a FlutterConfigPdfAdPluginsPlatform.
  FlutterConfigPdfAdPluginsPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterConfigPdfAdPluginsPlatform _instance =
      MethodChannelFlutterConfigPdfAdPlugins();

  /// The default instance of [FlutterConfigPdfAdPluginsPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterConfigPdfAdPlugins].
  static FlutterConfigPdfAdPluginsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterConfigPdfAdPluginsPlatform] when
  /// they register themselves.
  static set instance(FlutterConfigPdfAdPluginsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> configureSmallNativeAdLayout(String? layoutName) {
    throw UnimplementedError(
      'configureSmallNativeAdLayout() has not been implemented.',
    );
  }

  Stream<Map<String, dynamic>> get nativeAdHeadlineStream {
    throw UnimplementedError(
      'nativeAdHeadlineStream has not been implemented.',
    );
  }

  Future<bool> closeFullScreenAd() {
    throw UnimplementedError('closeFullScreenAd() has not been implemented.');
  }

  Future<void> updateCloseableFullScreenAdActivityNames(
    Iterable<String> activityNames,
  ) {
    throw UnimplementedError(
      'updateCloseableFullScreenAdActivityNames() has not been implemented.',
    );
  }
}
