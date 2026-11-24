import Flutter
import UIKit

public class FlutterConfigPdfAdPluginsPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_config_pdf_ad_plugins", binaryMessenger: registrar.messenger())
    let instance = FlutterConfigPdfAdPluginsPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "getAndroidId":
      result(nil)
    case "closeFullScreenAd":
      result(false)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
