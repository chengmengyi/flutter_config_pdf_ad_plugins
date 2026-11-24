import '../enum/ad_type.dart';

class AdInfoBean {
  AdInfoBean({
    this.adId,
    this.adPlat,
    this.exportTime,
    this.adType,
    this.sort,
    this.userGroup,
  });

  AdInfoBean.fromJson(dynamic json) {
    adId = json['adId'];
    adPlat = json['adPlat'];
    exportTime = json['exportTime'];
    sort = json['sort'];
    adType = json['adType'];
    userGroup = json['userGroup'] != null ? json['userGroup'].cast<int>() : [];
  }

  factory AdInfoBean.fromPlacementJson(Map<String, dynamic> json) {
    return AdInfoBean(
      adId: json['jsk'] as String?,
      adPlat: json['iwk'] as String?,
      adType: json['iwn'] as String?,
      exportTime: _readInt(json['isk']),
      sort: _readInt(json['ipn']),
      userGroup: _readIntList(json['grp']),
    );
  }

  String? adId;
  String? adPlat;
  String? adType;
  int? exportTime;
  int? sort;
  List<int>? userGroup;

  AdType? get parsedAdType => AdTypeX.tryParse(adType);

  /// 当前实际使用的广告缓存有效期，单位秒。
  ///
  /// 开屏广告固定为 13800 秒，其他广告类型固定为 3000 秒。
  int? get effectiveExportTime {
    return parsedAdType == AdType.appOpen ? 13800 : 3000;
  }

  String get logSummary {
    return 'adId=$adId, '
        'adPlat=$adPlat, '
        'adType=$adType, '
        'sort=$sort, '
        'exportTime=$exportTime, '
        'userGroup=$userGroup';
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['adId'] = adId;
    map['adPlat'] = adPlat;
    map['exportTime'] = exportTime;
    map['sort'] = sort;
    map['userGroup'] = userGroup;
    map['adType'] = adType;
    return map;
  }
}

int? _readInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}

List<int> _readIntList(dynamic value) {
  if (value is! List) {
    return <int>[];
  }
  return value.map(_readInt).whereType<int>().toList(growable: false);
}
