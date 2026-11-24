# flutter_config_pdf_ad_plugins

基于 `google_mobile_ads` 的广告封装插件。广告位和打点位置由插件内置枚举约束，广告配置通过远程接口获取。

## 安装

```yaml
dependencies:
  flutter_config_pdf_ad_plugins:
    git:
      url: https://github.com/chengmengyi/flutter_config_pdf_ad_plugins
```

宿主工程仍需在 Android `AndroidManifest.xml` 和 iOS `Info.plist` 中配置 AdMob App ID。

## 内置枚举

广告位使用 `AdPlacement`：

```dart
AdPlacement.pr_new_launch
AdPlacement.pr_launch
AdPlacement.pr_ban1
AdPlacement.pr_user_use
AdPlacement.pr_exit
AdPlacement.pr_ban2
AdPlacement.pr_ban3
AdPlacement.pr_new_int
```

广告展示位置使用 `AdPosId`，例如：

```dart
AdPosId.pr_new_open
AdPosId.pr_open_cold
AdPosId.pr_main_banner1
AdPosId.pr_guide_full
```

插件 API 不再接收业务自定义广告位泛型或 `Object adPosId`。

## 初始化远程配置

`initPlugins` 使用 Dio POST 请求远程配置。请求失败、HTTP 非 2xx、业务码非 200、映射失败或配置校验失败都会重试；首次请求加三次重试，最多四次，相邻请求间隔两秒。

远程请求全部失败后，插件优先使用本地最后一次成功配置；本地不存在或无效时使用 `defaultAd`。`defaultAd` 只包含广告配置主体，不包含 `code/msg/data`：

```dart
const defaultAd = '''
{
  "daily_limits": {
    "impressions": 20,
    "clicks": 5,
    "accidental_click_probability_percent": 0.25
  },
  "ad_scenes": [
    {
      "scene_id": "pr_new_launch",
      "blocked": false,
      "placements": [
        {
          "sort": 0,
          "ad_source": "admob",
          "ad_type": "app_open",
          "ad_id": "ca-app-pub-xxx/launch",
          "interval_secs": 3
        }
      ]
    }
  ]
}
''';
```

初始化示例：

```dart
final initialized = await FlutterConfigPdfAdPlugins.instance.initPlugins(
  remoteRequest: const AdRemoteRequest(
    url: 'https://example.com/ad-config',
    headers: <String, dynamic>{'Authorization': 'token'},
    body: <String, dynamic>{'language': 'en'},
    mapping: <String, String>{
      'code': 'decal',
      'msg': 'earpiece',
      'data': 'concur',
      'data.ads': 'concur.shore',
      'data.ads.daily_limits': 'concur.shore.suburb',
      'data.ads.daily_limits.impressions':
          'concur.shore.suburb.eldercare',
      'data.ads.daily_limits.clicks': 'concur.shore.suburb.sank',
      'data.ads.daily_limits.accidental_click_probability_percent':
          'concur.shore.suburb.ipod',
      'data.ads.ad_scenes': 'concur.shore.unread',
      'data.ads.ad_scenes.*.scene_id':
          'concur.shore.unread.*.revival',
      'data.ads.ad_scenes.*.blocked':
          'concur.shore.unread.*.pumice',
      'data.ads.ad_scenes.*.placements':
          'concur.shore.unread.*.detective',
      'data.ads.ad_scenes.*.placements.*.sort':
          'concur.shore.unread.*.detective.*.atonable',
      'data.ads.ad_scenes.*.placements.*.ad_source':
          'concur.shore.unread.*.detective.*.angles',
      'data.ads.ad_scenes.*.placements.*.ad_type':
          'concur.shore.unread.*.detective.*.septum',
      'data.ads.ad_scenes.*.placements.*.ad_id':
          'concur.shore.unread.*.detective.*.provoking',
      'data.ads.ad_scenes.*.placements.*.interval_secs':
          'concur.shore.unread.*.detective.*.silliness',
    },
  ),
  defaultAd: defaultAd,
  nativeAdHeadlineCallback: ({
    required headline,
    required isNextGenAdmob,
  }) {
    debugPrint('headline=$headline nextGen=$isNextGenAdmob');
  },
);

if (initialized) {
  await FlutterConfigPdfAdPlugins.instance.initializeAdmob();
}
```

远程成功配置只在完整解密和校验通过后保存。本地保存的内容为 `daily_limits/ad_scenes` 广告配置主体，不包含 `code/msg/data`。

Debug 构建会打印原始请求 URL、请求头、请求 Body、原始响应和解密结果；Release 构建不打印。解密结果保持加密响应的字段顺序和数组顺序。

支持的后台 `ad_type`：`interstitial`、`rewarded`、`app_open`、`banner`、`native`、`native_fullscreen`。

`daily_limits` 以及其中的 `impressions`、`clicks` 都允许为 `null`，表示不限制。展示和点击次数按设备、按天、所有广告类型合计；达到任一上限后只阻止新的广告请求，已经缓存的广告仍然可以展示。`accidental_click_probability_percent` 当前只保存，暂不参与逻辑。

`ad_scenes` 为 `null` 或空数组时表示没有广告，不会回退到默认配置。场景 `blocked=true` 时不发起该场景的新请求，但保留配置和已有缓存。

同一场景内的广告按 `sort` 从小到大稳定排序，相同 `sort` 保持后台数组顺序。先请求第一项；超过该项的 `interval_secs` 仍未返回时再请求下一项。如果当前项提前失败则立即请求下一项。首个成功结果会结束本次等待并阻止尚未发起的请求，已经发起的请求仍继续执行，后续成功结果也会写入缓存。`interval_secs` 至少为 1 秒。

广告缓存有效期固定为：`app_open` 13800 秒，其他类型 3000 秒。

## 加载与展示

```dart
await FlutterConfigPdfAdPlugins.instance.preloadAll(
  placements: <AdPlacement>[
    AdPlacement.pr_new_launch,
    AdPlacement.pr_ban1,
  ],
);

await FlutterConfigPdfAdPlugins.instance.loadPlacement(
  AdPlacement.pr_new_launch,
);

final shown = await FlutterConfigPdfAdPlugins.instance.loadAndShow(
  AdPlacement.pr_new_int,
  adPosId: AdPosId.pr_up_int,
  context: context,
);
```

缓存广告接口同样要求 `AdPosId`：

```dart
final widget = await FlutterConfigPdfAdPlugins.instance.buildCachedAdWidget(
  AdPlacement.pr_ban1,
  adPosId: AdPosId.pr_main_banner1,
);

final shown = await FlutterConfigPdfAdPlugins.instance.showCachedAd(
  AdPlacement.pr_new_launch,
  adPosId: AdPosId.pr_open_cold,
  context: context,
);
```

## 事件监听

```dart
class AppAdListener extends FlutterPdfAdListener {
  @override
  void onAdShowSuccess(
    AdPlacement placement,
    AdInfoBean info,
    AdPosId adPosId,
    String adNetwork,
    String adSourceName,
  ) {
    debugPrint('placement=${placement.name} adPosId=${adPosId.name}');
  }
}
```

回调中的 `adNetwork` 是后台 `ad_source` 原值，`adSourceName` 是 SDK 实际返回的广告源名称。

Adjust、install referrer、UMP、收益统计和展示样式配置接口暂时保持原有行为。

## 销毁

```dart
await FlutterConfigPdfAdPlugins.instance.disposeLoader();
```
