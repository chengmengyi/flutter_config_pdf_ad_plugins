enum AdType {
  interstitial,
  rewarded,
  appOpen,
  banner,
  native,
  nativeFullscreen,
}

extension AdTypeX on AdType {
  String get rawValue {
    switch (this) {
      case AdType.appOpen:
        return 'app_open';
      case AdType.interstitial:
        return 'interstitial';
      case AdType.native:
        return 'native';
      case AdType.nativeFullscreen:
        return 'native_fullscreen';
      case AdType.rewarded:
        return 'rewarded';
      case AdType.banner:
        return 'banner';
    }
  }

  bool get isFullScreen {
    return this == AdType.appOpen ||
        this == AdType.interstitial ||
        this == AdType.rewarded ||
        this == AdType.nativeFullscreen;
  }

  bool get isInlineView {
    return this == AdType.banner || this == AdType.native;
  }

  static AdType? tryParse(String? rawValue) {
    switch (rawValue) {
      case 'app_open':
        return AdType.appOpen;
      case 'interstitial':
        return AdType.interstitial;
      case 'native':
        return AdType.native;
      case 'native_fullscreen':
        return AdType.nativeFullscreen;
      case 'rewarded':
        return AdType.rewarded;
      case 'banner':
        return AdType.banner;
      default:
        return null;
    }
  }
}
