import '../enum/ad_type.dart';

class AdInfoBean {
  const AdInfoBean({
    required this.adId,
    required this.adSource,
    required this.adType,
    required this.sort,
    required this.intervalSecs,
  });

  final String adId;
  final String adSource;
  final AdType adType;
  final int sort;
  final int intervalSecs;

  AdType get parsedAdType => adType;
  String get adPlat => adSource;

  /// 当前实际使用的广告缓存有效期，单位秒。
  ///
  /// 开屏广告固定为 13800 秒，其他广告类型固定为 3000 秒。
  int get effectiveExportTime => adType == AdType.appOpen ? 13800 : 3000;

  String get logSummary {
    return 'adId=$adId, '
        'adSource=$adSource, '
        'adType=${adType.rawValue}, '
        'sort=$sort, '
        'intervalSecs=$intervalSecs';
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['adId'] = adId;
    map['adSource'] = adSource;
    map['sort'] = sort;
    map['adType'] = adType.rawValue;
    map['intervalSecs'] = intervalSecs;
    return map;
  }
}
