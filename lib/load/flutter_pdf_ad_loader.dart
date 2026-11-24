// ignore_for_file: implementation_imports, prefer_initializing_formals

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_mobile_ads/src/ad_instance_manager.dart'
    show instanceManager;

import '../bean/ad_info_bean.dart';
import '../enum/ad_placement.dart';
import '../enum/ad_pos_id.dart';
import '../enum/ad_type.dart';
import 'loaded_ad_cache_entry.dart';

const String _fallbackAdNetwork = 'Admob';

class _LoaderLeasedAdWidget extends StatefulWidget {
  const _LoaderLeasedAdWidget({required this.entry});

  final LoadedAdCacheEntry entry;

  @override
  State<_LoaderLeasedAdWidget> createState() => _LoaderLeasedAdWidgetState();
}

class _LoaderLeasedAdWidgetState extends State<_LoaderLeasedAdWidget> {
  late final bool _leaseAttached;

  @override
  void initState() {
    super.initState();
    _leaseAttached = widget.entry.attachReservedWidget();
  }

  @override
  Widget build(BuildContext context) {
    final ad = widget.entry.ad;
    if (!_leaseAttached ||
        ad is! AdWithView ||
        instanceManager.adIdFor(ad) == null) {
      return const SizedBox.shrink();
    }
    return AdWidget(ad: ad);
  }

  @override
  void dispose() {
    if (_leaseAttached) {
      unawaited(widget.entry.releaseWidgetLease());
    }
    super.dispose();
  }
}

class FlutterPdfAdLoader {
  FlutterPdfAdLoader({
    AdRequest? defaultAdRequest,
    AdSize? bannerSize,
    AdSize? Function(AdPlacement placement)? bannerSizeBuilder,
    AdRequest? Function(AdPlacement placement, AdRequest defaultRequest)?
    adRequestBuilder,
    String? Function(AdPlacement placement, AdInfoBean info)?
    nativeAdFactoryIdBuilder,
    NativeAdOptions? Function(AdPlacement placement, AdInfoBean info)?
    nativeAdOptionsBuilder,
    NativeTemplateStyle? nativeTemplateStyle,
    NativeTemplateStyle? Function(AdPlacement placement)?
    nativeTemplateStyleBuilder,
    void Function(AdPlacement placement, LoadedAdCacheEntry entry)?
    onPlacementLoaded,
    void Function(AdPlacement placement, AdInfoBean info)? onAdRequestStart,
    void Function(
      AdPlacement placement,
      AdInfoBean info,
      String adNetwork,
      String adSourceName,
      double loadDurationSeconds,
    )?
    onAdRequestSuccess,
    void Function(
      AdPlacement placement,
      AdInfoBean info,
      String failReason,
      String adNetwork,
      String adSourceName,
      double loadDurationSeconds,
    )?
    onAdRequestFailure,
    void Function(
      AdPlacement placement,
      AdInfoBean info,
      AdPosId adPosId,
      String adNetwork,
      String adSourceName,
    )?
    onAdShowStart,
    void Function(
      AdPlacement placement,
      AdInfoBean info,
      AdPosId adPosId,
      String adNetwork,
      String adSourceName,
    )?
    onAdShowed,
    void Function(
      AdPlacement placement,
      AdInfoBean info,
      AdPosId adPosId,
      String adNetwork,
      String adSourceName,
    )?
    onAdClicked,
    void Function(
      AdPlacement placement,
      AdInfoBean info,
      AdPosId adPosId,
      String adNetwork,
      String adSourceName,
    )?
    onAdClosed,
    void Function(
      AdPlacement placement,
      AdInfoBean info,
      AdPosId adPosId,
      Ad ad,
      double valueMicros,
      PrecisionType precision,
      String currencyCode,
    )?
    onPaidEvent,
    Future<bool> Function()? canRequestAd,
    void Function(AdPlacement placement, AdInfoBean info)? onAdImpression,
  }) : _defaultAdRequest = defaultAdRequest ?? const AdRequest(),
       _bannerSize = bannerSize ?? AdSize.banner,
       _bannerSizeBuilder = bannerSizeBuilder,
       _adRequestBuilder = adRequestBuilder,
       _nativeAdFactoryIdBuilder = nativeAdFactoryIdBuilder,
       _nativeAdOptionsBuilder = nativeAdOptionsBuilder,
       _nativeTemplateStyle =
           nativeTemplateStyle ??
           NativeTemplateStyle(templateType: TemplateType.medium),
       _nativeTemplateStyleBuilder = nativeTemplateStyleBuilder,
       _onPlacementLoaded = onPlacementLoaded,
       _onAdRequestStart = onAdRequestStart,
       _onAdRequestSuccess = onAdRequestSuccess,
       _onAdRequestFailure = onAdRequestFailure,
       _onAdShowStart = onAdShowStart,
       _onAdShowed = onAdShowed,
       _onAdClicked = onAdClicked,
       _onAdClosed = onAdClosed,
       _onPaidEvent = onPaidEvent,
       _canRequestAd = canRequestAd,
       _onAdImpression = onAdImpression;

  final AdRequest _defaultAdRequest;
  final AdSize _bannerSize;
  final AdSize? Function(AdPlacement placement)? _bannerSizeBuilder;
  final AdRequest? Function(AdPlacement placement, AdRequest defaultRequest)?
  _adRequestBuilder;
  final String? Function(AdPlacement placement, AdInfoBean info)?
  _nativeAdFactoryIdBuilder;
  final NativeAdOptions? Function(AdPlacement placement, AdInfoBean info)?
  _nativeAdOptionsBuilder;
  final NativeTemplateStyle _nativeTemplateStyle;
  final NativeTemplateStyle? Function(AdPlacement placement)?
  _nativeTemplateStyleBuilder;
  final void Function(AdPlacement placement, LoadedAdCacheEntry entry)?
  _onPlacementLoaded;
  final void Function(AdPlacement placement, AdInfoBean info)?
  _onAdRequestStart;
  final void Function(
    AdPlacement placement,
    AdInfoBean info,
    String adNetwork,
    String adSourceName,
    double loadDurationSeconds,
  )?
  _onAdRequestSuccess;
  final void Function(
    AdPlacement placement,
    AdInfoBean info,
    String failReason,
    String adNetwork,
    String adSourceName,
    double loadDurationSeconds,
  )?
  _onAdRequestFailure;
  final void Function(
    AdPlacement placement,
    AdInfoBean info,
    AdPosId adPosId,
    String adNetwork,
    String adSourceName,
  )?
  _onAdShowStart;
  final void Function(
    AdPlacement placement,
    AdInfoBean info,
    AdPosId adPosId,
    String adNetwork,
    String adSourceName,
  )?
  _onAdShowed;
  final void Function(
    AdPlacement placement,
    AdInfoBean info,
    AdPosId adPosId,
    String adNetwork,
    String adSourceName,
  )?
  _onAdClicked;
  final void Function(
    AdPlacement placement,
    AdInfoBean info,
    AdPosId adPosId,
    String adNetwork,
    String adSourceName,
  )?
  _onAdClosed;
  final void Function(
    AdPlacement placement,
    AdInfoBean info,
    AdPosId adPosId,
    Ad ad,
    double valueMicros,
    PrecisionType precision,
    String currencyCode,
  )?
  _onPaidEvent;
  final Future<bool> Function()? _canRequestAd;
  final void Function(AdPlacement placement, AdInfoBean info)? _onAdImpression;

  final Map<AdPlacement, List<AdInfoBean>> _configs = {};
  final Map<AdPlacement, List<LoadedAdCacheEntry>> _cacheMap = {};
  final Map<AdPlacement, Future<LoadedAdCacheEntry?>> _loadingTasks = {};
  final Map<AdPlacement, int> _activeRequestCounts = {};
  final Set<AdPlacement> _skipReloadAfterClosePlacements = <AdPlacement>{};
  final Set<AdPlacement> _programmaticClosingPlacements = <AdPlacement>{};
  final Set<AdPlacement> _reloadWhenActiveRequestsFinish = <AdPlacement>{};
  final Expando<AdPosId> _adPosIds = Expando<AdPosId>('flutter_pdf_ad_pos_id');

  Map<AdPlacement, List<AdInfoBean>> get configs => Map.unmodifiable(_configs);

  Map<AdPlacement, LoadedAdCacheEntry> get cacheMap {
    return Map<AdPlacement, LoadedAdCacheEntry>.unmodifiable(
      _cacheMap.map((key, value) => MapEntry(key, value.first)),
    );
  }

  void replaceConfigsFromRemote(Map<AdPlacement, List<AdInfoBean>> configs) {
    _configs
      ..clear()
      ..addAll(
        configs.map(
          (key, value) => MapEntry(key, List<AdInfoBean>.unmodifiable(value)),
        ),
      );
  }

  void updateSkipReloadAfterClosePlacements(Iterable<AdPlacement> placements) {
    _skipReloadAfterClosePlacements
      ..clear()
      ..addAll(placements);
  }

  void markProgrammaticClose(Iterable<AdPlacement> placements) {
    _programmaticClosingPlacements.addAll(placements);
  }

  void unmarkProgrammaticClose(Iterable<AdPlacement> placements) {
    _programmaticClosingPlacements.removeAll(placements);
  }

  bool _consumeProgrammaticCloseMark(AdPlacement placement) {
    return _programmaticClosingPlacements.remove(placement);
  }

  Future<LoadedAdCacheEntry?> loadPlacement(
    AdPlacement placement, {
    List<AdInfoBean>? configs,
    bool force = false,
  }) async {
    final inFlight = _loadingTasks[placement];
    if (inFlight != null) {
      return inFlight;
    }

    final cacheExpired = await _evictExpiredCacheIfNeeded(
      placement,
      reloadOnExpire: false,
    );
    if (cacheExpired) {
      _logCacheExpired(placement, trigger: 'load');
    }

    final cachedEntry = _cacheMap[placement];
    if (!force && cachedEntry != null && cachedEntry.isNotEmpty) {
      return cachedEntry.first;
    }

    if ((_activeRequestCounts[placement] ?? 0) > 0) {
      if (!kReleaseMode) {
        debugPrint(
          '[FlutterPdfAdLoader] ad-load-blocked '
          'placement=${_placementLabel(placement)} '
          'reason=active-request',
        );
      }
      return cachedEntry == null || cachedEntry.isEmpty
          ? null
          : cachedEntry.first;
    }

    final latestInFlight = _loadingTasks[placement];
    if (latestInFlight != null) {
      return latestInFlight;
    }

    final placementConfigs =
        configs ?? _configs[placement] ?? const <AdInfoBean>[];
    final canRequestAd = _canRequestAd;
    if (canRequestAd != null && !await canRequestAd()) {
      if (!kReleaseMode) {
        debugPrint(
          '[FlutterPdfAdLoader] ad-load-blocked '
          'placement=${_placementLabel(placement)} '
          'reason=daily-show-or-click-limit',
        );
      }
      return null;
    }

    // The asynchronous limit check may have allowed another caller to start
    // loading this placement while we were waiting.
    final inFlightAfterLimitCheck = _loadingTasks[placement];
    if (inFlightAfterLimitCheck != null) {
      return inFlightAfterLimitCheck;
    }

    final future = _loadPlacementInternal(
      placement,
      placementConfigs,
      clearCacheOnNoFill: !force,
    );
    _loadingTasks[placement] = future;

    try {
      return await future;
    } finally {
      _loadingTasks.remove(placement);
      if ((_activeRequestCounts[placement] ?? 0) <= 0 &&
          placementConfigs.isNotEmpty) {
        unawaited(
          _maybeReloadAfterActiveRequestsFinish(
            placement,
            placementConfigs.first,
          ),
        );
      }
    }
  }

  Future<void> preloadAll({
    Iterable<AdPlacement>? placements,
    bool force = false,
  }) async {
    final targets = placements ?? _configs.keys;
    await Future.wait(
      targets.map((placement) => loadPlacement(placement, force: force)),
    );
  }

  Future<LoadedAdCacheEntry?> getCachedEntry(AdPlacement placement) async {
    await _evictExpiredCacheIfNeeded(placement, reloadOnExpire: false);
    final entries = _cacheMap[placement];
    if (entries == null || entries.isEmpty) {
      return null;
    }
    return entries.first;
  }

  Future<LoadedAdCacheEntry?> getUnleasedCachedEntry(
    AdPlacement placement,
  ) async {
    await _evictExpiredCacheIfNeeded(placement, reloadOnExpire: false);
    final entries = _cacheMap[placement];
    if (entries == null || entries.isEmpty) {
      return null;
    }
    for (final entry in entries) {
      if (!entry.hasWidgetLease) {
        return entry;
      }
    }
    return null;
  }

  Future<LoadedAdCacheEntry?> reserveCachedWidgetEntry(
    AdPlacement placement, {
    required AdPosId adPosId,
  }) async {
    await _evictExpiredCacheIfNeeded(placement, reloadOnExpire: false);
    final entries = _cacheMap[placement];
    if (entries == null || entries.isEmpty) {
      return null;
    }
    for (final entry in entries) {
      final ad = entry.ad;
      if (ad is! AdWithView || instanceManager.adIdFor(ad) == null) {
        continue;
      }
      if (!entry.reserveForWidget()) {
        continue;
      }
      _bindEntryAdPosId(entry, adPosId);
      return entry;
    }
    return null;
  }

  Future<Ad?> getCachedAd(AdPlacement placement) async {
    return (await getCachedEntry(placement))?.ad;
  }

  void bindCachedEntryAdPosId(LoadedAdCacheEntry entry, AdPosId adPosId) {
    _bindEntryAdPosId(entry, adPosId);
  }

  Future<LoadedAdCacheEntry?> takeCachedEntry(
    AdPlacement placement, {
    required AdPosId adPosId,
    bool reloadAfterTake = false,
    LoadedAdCacheEntry? expectedEntry,
  }) async {
    await _evictExpiredCacheIfNeeded(placement, reloadOnExpire: false);
    final entries = _cacheMap[placement];
    if (entries == null || entries.isEmpty) {
      return null;
    }
    final entryIndex = expectedEntry == null
        ? entries.indexWhere((entry) => !entry.hasWidgetLease)
        : entries.indexWhere(
            (entry) => identical(entry, expectedEntry) && !entry.hasWidgetLease,
          );
    if (entryIndex < 0) {
      return null;
    }
    final entry = entries.removeAt(entryIndex);
    _bindEntryAdPosId(entry, adPosId);
    if (entries.isEmpty) {
      _cacheMap.remove(placement);
    }
    if (reloadAfterTake) {
      unawaited(loadPlacement(placement, force: true));
    }
    return entry;
  }

  Future<Widget?> buildCachedAdWidget(
    AdPlacement placement, {
    required AdPosId adPosId,
  }) async {
    final entry = await reserveCachedWidgetEntry(placement, adPosId: adPosId);
    if (entry == null) {
      return null;
    }
    final ad = entry.ad;
    if (ad is AdWithView && instanceManager.adIdFor(ad) != null) {
      return _LoaderLeasedAdWidget(entry: entry);
    }
    await entry.releaseWidgetLease();
    return null;
  }

  Future<bool?> showCachedAd(
    AdPlacement placement, {
    required AdPosId adPosId,
    OnUserEarnedRewardCallback? onUserEarnedReward,
  }) async {
    final result = await showCachedAdWithResult(
      placement,
      adPosId: adPosId,
      onUserEarnedReward: onUserEarnedReward,
    );
    return result.shown;
  }

  Future<ShowAdResult> showCachedAdWithResult(
    AdPlacement placement, {
    required AdPosId adPosId,
    OnUserEarnedRewardCallback? onUserEarnedReward,
  }) async {
    await _evictExpiredCacheIfNeeded(placement, reloadOnExpire: true);

    final entries = _cacheMap[placement];
    final entry = entries == null || entries.isEmpty ? null : entries.first;
    if (entry == null) {
      return const ShowAdResult.failure('no-cached-ad');
    }
    _bindEntryAdPosId(entry, adPosId);

    final ad = entry.ad;
    if (ad is AppOpenAd) {
      final completer = Completer<ShowAdResult>();
      ad.fullScreenContentCallback = FullScreenContentCallback<AppOpenAd>(
        onAdShowedFullScreenContent: (_) {
          _dispatchAdShowed(placement, entry.info, entry.ad);
          unawaited(_preloadReplacementAfterShow(placement, entry));
        },
        onAdDismissedFullScreenContent: (_) async {
          final programmaticClose = _consumeProgrammaticCloseMark(placement);
          _dispatchAdClosed(placement, entry.info, entry.ad);
          await _consumeShownEntryAfterShow(
            placement,
            entry,
            trigger: programmaticClose ? 'programmatic-close' : 'close',
          );
          if (!completer.isCompleted) {
            completer.complete(
              programmaticClose
                  ? const ShowAdResult.programmaticClose()
                  : const ShowAdResult.success(),
            );
          }
        },
        onAdFailedToShowFullScreenContent: (_, error) {
          if (!completer.isCompleted) {
            completer.complete(
              ShowAdResult.failure(
                'code=${error.code} message=${error.message} domain=${error.domain}',
              ),
            );
          }
          unawaited(
            _consumeShownEntryAfterShow(
              placement,
              entry,
              trigger: 'failed-show',
            ),
          );
        },
        onAdClicked: (_) {
          _dispatchAdClicked(placement, entry.info, entry.ad);
        },
      );
      try {
        _dispatchAdShowStart(placement, entry.info, entry.ad);
        await ad.show();
      } catch (error) {
        return ShowAdResult.failure('exception=$error');
      }
      return completer.future;
    }

    if (ad is InterstitialAd) {
      final completer = Completer<ShowAdResult>();
      ad.fullScreenContentCallback = FullScreenContentCallback<InterstitialAd>(
        onAdShowedFullScreenContent: (_) {
          _dispatchAdShowed(placement, entry.info, entry.ad);
          unawaited(_preloadReplacementAfterShow(placement, entry));
        },
        onAdDismissedFullScreenContent: (_) async {
          final programmaticClose = _consumeProgrammaticCloseMark(placement);
          _dispatchAdClosed(placement, entry.info, entry.ad);
          await _consumeShownEntryAfterShow(
            placement,
            entry,
            trigger: programmaticClose ? 'programmatic-close' : 'close',
          );
          if (!completer.isCompleted) {
            completer.complete(
              programmaticClose
                  ? const ShowAdResult.programmaticClose()
                  : const ShowAdResult.success(),
            );
          }
        },
        onAdFailedToShowFullScreenContent: (_, error) {
          if (!completer.isCompleted) {
            completer.complete(
              ShowAdResult.failure(
                'code=${error.code} message=${error.message} domain=${error.domain}',
              ),
            );
          }
          unawaited(
            _consumeShownEntryAfterShow(
              placement,
              entry,
              trigger: 'failed-show',
            ),
          );
        },
        onAdClicked: (_) {
          _dispatchAdClicked(placement, entry.info, entry.ad);
        },
      );
      try {
        _dispatchAdShowStart(placement, entry.info, entry.ad);
        await ad.show();
      } catch (error) {
        return ShowAdResult.failure('exception=$error');
      }
      return completer.future;
    }

    if (ad is RewardedAd) {
      final completer = Completer<ShowAdResult>();
      ad.fullScreenContentCallback = FullScreenContentCallback<RewardedAd>(
        onAdShowedFullScreenContent: (_) {
          _dispatchAdShowed(placement, entry.info, entry.ad);
          unawaited(_preloadReplacementAfterShow(placement, entry));
        },
        onAdDismissedFullScreenContent: (_) async {
          final programmaticClose = _consumeProgrammaticCloseMark(placement);
          _dispatchAdClosed(placement, entry.info, entry.ad);
          await _consumeShownEntryAfterShow(
            placement,
            entry,
            trigger: programmaticClose ? 'programmatic-close' : 'close',
          );
          if (!completer.isCompleted) {
            completer.complete(
              programmaticClose
                  ? const ShowAdResult.programmaticClose()
                  : const ShowAdResult.success(),
            );
          }
        },
        onAdFailedToShowFullScreenContent: (_, error) {
          if (!completer.isCompleted) {
            completer.complete(
              ShowAdResult.failure(
                'code=${error.code} message=${error.message} domain=${error.domain}',
              ),
            );
          }
          unawaited(
            _consumeShownEntryAfterShow(
              placement,
              entry,
              trigger: 'failed-show',
            ),
          );
        },
        onAdClicked: (_) {
          _dispatchAdClicked(placement, entry.info, entry.ad);
        },
      );
      try {
        _dispatchAdShowStart(placement, entry.info, entry.ad);
        await ad.show(
          onUserEarnedReward:
              onUserEarnedReward ??
              (_, __) {
                // No-op when caller does not need reward callbacks.
              },
        );
      } catch (error) {
        return ShowAdResult.failure('exception=$error');
      }
      return completer.future;
    }

    return ShowAdResult.failure('unsupported-ad-class=${ad.runtimeType}');
  }

  Future<bool?> loadAndShow(
    AdPlacement placement, {
    required AdPosId adPosId,
    List<AdInfoBean>? configs,
    bool forceReload = false,
    OnUserEarnedRewardCallback? onUserEarnedReward,
  }) async {
    final cachedShown = await showCachedAd(
      placement,
      adPosId: adPosId,
      onUserEarnedReward: onUserEarnedReward,
    );
    if (cachedShown == null) {
      return null;
    }
    if (cachedShown && !forceReload) {
      return true;
    }

    final entry = await loadPlacement(
      placement,
      configs: configs,
      force: forceReload,
    );
    if (entry == null) {
      return false;
    }

    return showCachedAd(
      placement,
      adPosId: adPosId,
      onUserEarnedReward: onUserEarnedReward,
    );
  }

  Future<void> clearPlacementCache(AdPlacement placement) async {
    final entries = _cacheMap.remove(placement);
    if (entries != null) {
      for (final entry in entries) {
        await entry.dispose();
      }
    }
  }

  Future<void> consumeShownEntryAfterClose(
    AdPlacement placement,
    LoadedAdCacheEntry entry,
  ) {
    return _consumeShownEntryAfterShow(placement, entry, trigger: 'close');
  }

  Future<void> _preloadReplacementAfterShow(
    AdPlacement placement,
    LoadedAdCacheEntry shownEntry,
  ) async {
    if (_skipReloadAfterClosePlacements.contains(placement)) {
      _log(
        'skip-preload-after-show',
        placement,
        info: shownEntry.info,
        extra: 'reason=skip-reload-after-close',
      );
      return;
    }

    final configs = _configs[placement] ?? const <AdInfoBean>[];
    final hasLoadableConfig = configs.isNotEmpty;
    if (!hasLoadableConfig) {
      _log(
        'skip-preload-after-show',
        placement,
        info: shownEntry.info,
        extra: 'reason=no-loadable-config',
      );
      return;
    }

    _logCacheReload(placement, trigger: 'showed-preload');
    await loadPlacement(placement, force: true);
  }

  Future<void> dispose() async {
    final placements = _cacheMap.keys.toList(growable: false);
    for (final placement in placements) {
      await clearPlacementCache(placement);
    }
    _configs.clear();
    _loadingTasks.clear();
    _activeRequestCounts.clear();
    _programmaticClosingPlacements.clear();
    _reloadWhenActiveRequestsFinish.clear();
  }

  Future<LoadedAdCacheEntry?> _loadPlacementInternal(
    AdPlacement placement,
    List<AdInfoBean> configs, {
    required bool clearCacheOnNoFill,
  }) async {
    final sortedConfigs = configs.indexed.toList(growable: false)
      ..sort((left, right) {
        final bySort = left.$2.sort.compareTo(right.$2.sort);
        return bySort != 0 ? bySort : left.$1.compareTo(right.$1);
      });

    if (sortedConfigs.isEmpty) {
      if (clearCacheOnNoFill) {
        await clearPlacementCache(placement);
      }
      return null;
    }

    final completer = Completer<LoadedAdCacheEntry?>();
    final startedIndexes = <int>{};
    final completedIndexes = <int>{};
    final timers = <Timer>[];
    var hasSuccessfulFill = false;

    bool allDone() =>
        completedIndexes.length == sortedConfigs.length &&
        startedIndexes.length == sortedConfigs.length;

    Future<void> tryCompleteNoFill() async {
      if (completer.isCompleted) {
        return;
      }
      if (!allDone()) {
        return;
      }
      if (clearCacheOnNoFill) {
        await clearPlacementCache(placement);
      }
      completer.complete(null);
    }

    Future<void> startLoadAt(int index) async {
      if (index >= sortedConfigs.length) {
        return;
      }
      if (hasSuccessfulFill) {
        return;
      }
      if (!startedIndexes.add(index)) {
        return;
      }
      final config = sortedConfigs[index].$2;
      _logLoadStart(placement, config);
      _activeRequestCounts[placement] =
          (_activeRequestCounts[placement] ?? 0) + 1;

      Timer? fallbackTimer;
      if (index + 1 < sortedConfigs.length) {
        fallbackTimer = Timer(Duration(seconds: config.intervalSecs), () {
          if (completedIndexes.contains(index)) {
            return;
          }
          unawaited(startLoadAt(index + 1));
        });
        timers.add(fallbackTimer);
      }

      final loadStopwatch = Stopwatch()..start();
      final result = await _loadAd(placement, config);
      loadStopwatch.stop();
      final loadDurationSeconds =
          loadStopwatch.elapsedMicroseconds / Duration.microsecondsPerSecond;
      completedIndexes.add(index);
      fallbackTimer?.cancel();
      final nextActiveCount = (_activeRequestCounts[placement] ?? 1) - 1;
      final activeRequestsBecameIdle = nextActiveCount <= 0;
      if (nextActiveCount <= 0) {
        _activeRequestCounts.remove(placement);
      } else {
        _activeRequestCounts[placement] = nextActiveCount;
      }

      final ad = result.ad;
      if (ad == null) {
        _logLoadFailure(
          placement,
          config,
          reason: result.failureReason,
          adNetwork: result.adNetwork,
          loadDurationSeconds: loadDurationSeconds,
        );
        if (index + 1 < sortedConfigs.length) {
          unawaited(startLoadAt(index + 1));
        }
        await tryCompleteNoFill();
        if (activeRequestsBecameIdle) {
          unawaited(_maybeReloadAfterActiveRequestsFinish(placement, config));
        }
        return;
      }

      final entry = LoadedAdCacheEntry(
        info: config,
        ad: ad,
        cachedAt: DateTime.now(),
        requestOrder: index,
      );
      hasSuccessfulFill = true;
      for (final timer in timers) {
        timer.cancel();
      }
      await _insertCacheEntry(placement, entry);
      _logLoadSuccess(
        placement,
        entry,
        cacheCount: _cacheMap[placement]?.length ?? 0,
        loadDurationSeconds: loadDurationSeconds,
      );
      _onPlacementLoaded?.call(placement, entry);
      if (!completer.isCompleted) {
        completer.complete(entry);
      }
      await tryCompleteNoFill();
      if (activeRequestsBecameIdle) {
        unawaited(_maybeReloadAfterActiveRequestsFinish(placement, config));
      }
    }

    unawaited(startLoadAt(0));
    final firstResult = await completer.future;
    for (final timer in timers) {
      timer.cancel();
    }
    return firstResult;
  }

  Future<void> _insertCacheEntry(
    AdPlacement placement,
    LoadedAdCacheEntry nextEntry,
  ) async {
    final entries = _cacheMap.putIfAbsent(
      placement,
      () => <LoadedAdCacheEntry>[],
    );
    var insertAt = entries.length;
    for (var index = 0; index < entries.length; index++) {
      if (nextEntry.requestOrder <= entries[index].requestOrder) {
        insertAt = index;
        break;
      }
    }
    entries.insert(insertAt, nextEntry);
  }

  Future<bool> _evictExpiredCacheIfNeeded(
    AdPlacement placement, {
    required bool reloadOnExpire,
  }) async {
    final entries = _cacheMap[placement];
    if (entries == null || entries.isEmpty) {
      return false;
    }

    final expiredEntries = entries
        .where((entry) => entry.isExpired)
        .toList(growable: false);
    if (expiredEntries.isEmpty) {
      return false;
    }

    for (final expiredEntry in expiredEntries) {
      entries.remove(expiredEntry);
      await expiredEntry.dispose();
    }

    if (entries.isEmpty) {
      _cacheMap.remove(placement);
      if (reloadOnExpire) {
        unawaited(loadPlacement(placement, force: true));
      }
    }
    return true;
  }

  Future<_AdLoadResult> _loadAd(AdPlacement placement, AdInfoBean info) async {
    final adType = info.parsedAdType;
    final adId = info.adId;
    if (adId.isEmpty) {
      return const _AdLoadResult.failure('invalid-ad-config');
    }

    switch (adType) {
      case AdType.appOpen:
        return _loadAppOpenAd(placement, info, adId);
      case AdType.interstitial:
        return _loadInterstitialAd(placement, info, adId);
      case AdType.native:
      case AdType.nativeFullscreen:
        return _loadNativeAd(placement, info, adId);
      case AdType.rewarded:
        return _loadRewardedAd(placement, info, adId);
      case AdType.banner:
        return _loadBannerAd(placement, info, adId);
    }
  }

  Future<_AdLoadResult> _loadAppOpenAd(
    AdPlacement placement,
    AdInfoBean info,
    String adId,
  ) async {
    final completer = Completer<_AdLoadResult>();

    void completeFailure(String reason, {String? adNetwork}) {
      if (!completer.isCompleted) {
        completer.complete(_AdLoadResult.failure(reason, adNetwork: adNetwork));
      }
    }

    try {
      await AppOpenAd.load(
        adUnitId: adId,
        request: _defaultAdRequest,
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            if (completer.isCompleted) {
              ad.dispose();
              return;
            }
            ad.onPaidEvent = _buildOnPaidEvent(placement, info);
            completer.complete(_AdLoadResult.success(ad));
          },
          onAdFailedToLoad: (error) {
            completeFailure(
              'code=${error.code} message=${error.message} domain=${error.domain}',
              adNetwork: _resolveResponseInfoAdNetwork(error.responseInfo),
            );
          },
        ),
      );
    } catch (error) {
      completeFailure('exception=$error');
    }
    return completer.future;
  }

  Future<_AdLoadResult> _loadInterstitialAd(
    AdPlacement placement,
    AdInfoBean info,
    String adId,
  ) async {
    final completer = Completer<_AdLoadResult>();

    void completeFailure(String reason, {String? adNetwork}) {
      if (!completer.isCompleted) {
        completer.complete(_AdLoadResult.failure(reason, adNetwork: adNetwork));
      }
    }

    try {
      await InterstitialAd.load(
        adUnitId: adId,
        request: _defaultAdRequest,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            if (completer.isCompleted) {
              ad.dispose();
              return;
            }
            ad.onPaidEvent = _buildOnPaidEvent(placement, info);
            completer.complete(_AdLoadResult.success(ad));
          },
          onAdFailedToLoad: (error) {
            completeFailure(
              'code=${error.code} message=${error.message} domain=${error.domain}',
              adNetwork: _resolveResponseInfoAdNetwork(error.responseInfo),
            );
          },
        ),
      );
    } catch (error) {
      completeFailure('exception=$error');
    }
    return completer.future;
  }

  Future<_AdLoadResult> _loadRewardedAd(
    AdPlacement placement,
    AdInfoBean info,
    String adId,
  ) async {
    final completer = Completer<_AdLoadResult>();

    void completeFailure(String reason, {String? adNetwork}) {
      if (!completer.isCompleted) {
        completer.complete(_AdLoadResult.failure(reason, adNetwork: adNetwork));
      }
    }

    try {
      await RewardedAd.load(
        adUnitId: adId,
        request: _defaultAdRequest,
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            if (completer.isCompleted) {
              ad.dispose();
              return;
            }
            ad.onPaidEvent = _buildOnPaidEvent(placement, info);
            completer.complete(_AdLoadResult.success(ad));
          },
          onAdFailedToLoad: (error) {
            completeFailure(
              'code=${error.code} message=${error.message} domain=${error.domain}',
              adNetwork: _resolveResponseInfoAdNetwork(error.responseInfo),
            );
          },
        ),
      );
    } catch (error) {
      completeFailure('exception=$error');
    }
    return completer.future;
  }

  Future<_AdLoadResult> _loadBannerAd(
    AdPlacement placement,
    AdInfoBean info,
    String adId,
  ) async {
    final completer = Completer<_AdLoadResult>();

    void completeFailure(String reason, {String? adNetwork}) {
      if (!completer.isCompleted) {
        completer.complete(_AdLoadResult.failure(reason, adNetwork: adNetwork));
      }
    }

    final ad = BannerAd(
      size: _bannerSizeBuilder?.call(placement) ?? _bannerSize,
      adUnitId: adId,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (completer.isCompleted) {
            ad.dispose();
            return;
          }
          completer.complete(_AdLoadResult.success(ad));
        },
        onAdFailedToLoad: (ad, error) async {
          final adNetwork = _resolveAdNetwork(ad);
          await ad.dispose();
          completeFailure(
            'code=${error.code} message=${error.message} domain=${error.domain}',
            adNetwork: adNetwork,
          );
        },
        onAdClicked: (ad) {
          _dispatchAdClicked(placement, info, ad);
        },
        onAdImpression: (ad) {
          _onAdImpression?.call(placement, info);
        },
        onPaidEvent: _buildOnPaidEvent(placement, info),
      ),
      request:
          _adRequestBuilder?.call(placement, _defaultAdRequest) ??
          _defaultAdRequest,
    );

    try {
      await ad.load();
    } catch (error) {
      await ad.dispose();
      completeFailure('exception=$error');
    }

    return completer.future;
  }

  Future<_AdLoadResult> _loadNativeAd(
    AdPlacement placement,
    AdInfoBean info,
    String adId,
  ) async {
    final completer = Completer<_AdLoadResult>();

    void completeFailure(String reason, {String? adNetwork}) {
      if (!completer.isCompleted) {
        completer.complete(_AdLoadResult.failure(reason, adNetwork: adNetwork));
      }
    }

    final factoryId = _nativeAdFactoryIdBuilder?.call(placement, info);
    final ad = NativeAd(
      adUnitId: adId,
      factoryId: factoryId,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (completer.isCompleted) {
            ad.dispose();
            return;
          }
          completer.complete(_AdLoadResult.success(ad));
        },
        onAdFailedToLoad: (ad, error) async {
          final adNetwork = _resolveAdNetwork(ad);
          await ad.dispose();
          completeFailure(
            'code=${error.code} message=${error.message} domain=${error.domain}',
            adNetwork: adNetwork,
          );
        },
        onAdClicked: (ad) {
          _dispatchAdClicked(placement, info, ad);
        },
        onAdImpression: (ad) {
          _onAdImpression?.call(placement, info);
        },
        onPaidEvent: _buildOnPaidEvent(placement, info),
      ),
      request: _defaultAdRequest,
      nativeAdOptions: _nativeAdOptionsBuilder?.call(placement, info),
      nativeTemplateStyle: factoryId == null
          ? (_nativeTemplateStyleBuilder?.call(placement) ??
                _nativeTemplateStyle)
          : null,
    );

    try {
      await ad.load();
    } catch (error) {
      await ad.dispose();
      completeFailure('exception=$error');
    }

    return completer.future;
  }

  OnPaidEventCallback? _buildOnPaidEvent(
    AdPlacement placement,
    AdInfoBean info,
  ) {
    final onPaidEvent = _onPaidEvent;
    if (onPaidEvent == null) {
      return null;
    }
    return (ad, valueMicros, precision, currencyCode) {
      onPaidEvent(
        placement,
        info,
        _requireAdPosId(ad),
        ad,
        valueMicros,
        precision,
        currencyCode,
      );
    };
  }

  void _bindAdPosId(Ad ad, AdPosId adPosId) {
    _adPosIds[ad] = adPosId;
  }

  void _bindEntryAdPosId(LoadedAdCacheEntry entry, AdPosId adPosId) {
    entry.bindAdPosId(adPosId);
    _bindAdPosId(entry.ad, adPosId);
  }

  AdPosId _requireAdPosId(Ad ad) {
    final adPosId = _adPosIds[ad];
    if (adPosId == null) {
      throw StateError('AdPosId has not been bound to the ad');
    }
    return adPosId;
  }

  void _logLoadStart(AdPlacement placement, AdInfoBean info) {
    _onAdRequestStart?.call(placement, info);
    _log('load-start', placement, info: info);
  }

  void _logLoadFailure(
    AdPlacement placement,
    AdInfoBean info, {
    String? reason,
    String? adNetwork,
    required double loadDurationSeconds,
  }) {
    final failReason = reason ?? 'unknown';
    final adSourceName = adNetwork ?? _fallbackAdNetwork;
    _onAdRequestFailure?.call(
      placement,
      info,
      failReason,
      info.adSource,
      adSourceName,
      loadDurationSeconds,
    );
    _log(
      'load-failed',
      placement,
      info: info,
      extra:
          'reason=$failReason '
          'loadDurationSeconds=${loadDurationSeconds.toStringAsFixed(3)}',
    );
  }

  void _logLoadSuccess(
    AdPlacement placement,
    LoadedAdCacheEntry entry, {
    required int cacheCount,
    required double loadDurationSeconds,
  }) {
    final adSourceName = _resolveAdNetwork(entry.ad);
    _onAdRequestSuccess?.call(
      placement,
      entry.info,
      entry.info.adSource,
      adSourceName,
      loadDurationSeconds,
    );
    _log(
      'load-success',
      placement,
      info: entry.info,
      extra:
          'requestOrder=${entry.requestOrder} '
          'cacheCount=$cacheCount '
          'loadedAt=${entry.cachedAt.toIso8601String()} '
          'expireAt=${entry.expireAt?.toIso8601String() ?? 'never'} '
          'loadDurationSeconds=${loadDurationSeconds.toStringAsFixed(3)} '
          'adClass=${entry.ad.runtimeType}',
    );
  }

  String _resolveAdNetwork(Ad? ad) {
    return _normalizeAdNetwork(
      ad?.responseInfo?.loadedAdapterResponseInfo?.adSourceName,
    );
  }

  String _resolveResponseInfoAdNetwork(ResponseInfo? responseInfo) {
    return _normalizeAdNetwork(
      responseInfo?.loadedAdapterResponseInfo?.adSourceName,
    );
  }

  String _normalizeAdNetwork(String? adNetwork) {
    final normalized = adNetwork?.trim();
    if (normalized == null || normalized.isEmpty) {
      return _fallbackAdNetwork;
    }
    return normalized;
  }

  void _dispatchAdShowStart(AdPlacement placement, AdInfoBean info, Ad ad) {
    final adSourceName = _resolveAdNetwork(ad);
    _onAdShowStart?.call(
      placement,
      info,
      _requireAdPosId(ad),
      info.adSource,
      adSourceName,
    );
  }

  void _dispatchAdShowed(AdPlacement placement, AdInfoBean info, Ad ad) {
    _onAdImpression?.call(placement, info);
    final adSourceName = _resolveAdNetwork(ad);
    _onAdShowed?.call(
      placement,
      info,
      _requireAdPosId(ad),
      info.adSource,
      adSourceName,
    );
  }

  void _dispatchAdClicked(AdPlacement placement, AdInfoBean info, Ad ad) {
    final adSourceName = _resolveAdNetwork(ad);
    _onAdClicked?.call(
      placement,
      info,
      _requireAdPosId(ad),
      info.adSource,
      adSourceName,
    );
  }

  void _dispatchAdClosed(AdPlacement placement, AdInfoBean info, Ad ad) {
    final adSourceName = _resolveAdNetwork(ad);
    _onAdClosed?.call(
      placement,
      info,
      _requireAdPosId(ad),
      info.adSource,
      adSourceName,
    );
  }

  void _logCacheExpired(AdPlacement placement, {required String trigger}) {
    if (kReleaseMode) {
      return;
    }

    debugPrint(
      '[FlutterPdfAdLoader] cache-expired placement=${_placementLabel(placement)} '
      'trigger=$trigger',
    );
  }

  void _logCacheReload(AdPlacement placement, {required String trigger}) {
    if (kReleaseMode) {
      return;
    }

    debugPrint(
      '[FlutterPdfAdLoader] cache-reload placement=${_placementLabel(placement)} '
      'trigger=$trigger',
    );
  }

  Future<void> _consumeShownEntryAfterShow(
    AdPlacement placement,
    LoadedAdCacheEntry shownEntry, {
    required String trigger,
  }) async {
    final entries = _cacheMap[placement];
    if (entries == null || entries.isEmpty) {
      return;
    }

    final removed = entries.remove(shownEntry);
    if (!removed) {
      return;
    }

    await shownEntry.dispose();

    if (entries.isEmpty) {
      _cacheMap.remove(placement);
      final closed = trigger == 'close' || trigger == 'programmatic-close';
      if (closed && _skipReloadAfterClosePlacements.contains(placement)) {
        _log('skip-reload-after-close', placement, info: shownEntry.info);
        return;
      }

      final activeRequestCount = _activeRequestCounts[placement] ?? 0;
      if (activeRequestCount > 0) {
        _reloadWhenActiveRequestsFinish.add(placement);
        _log(
          'cache-empty-await-pending',
          placement,
          info: shownEntry.info,
          extra: 'trigger=$trigger activeRequestCount=$activeRequestCount',
        );
        return;
      }

      _logCacheReload(placement, trigger: '$trigger-empty-reload');
      unawaited(loadPlacement(placement, force: true));
      return;
    }

    _log(
      'cache-advance-after-show',
      placement,
      info: entries.first.info,
      extra:
          'remainingCount=${entries.length} '
          'nextRequestOrder=${entries.first.requestOrder}',
    );
  }

  Future<void> _maybeReloadAfterActiveRequestsFinish(
    AdPlacement placement,
    AdInfoBean info,
  ) async {
    if (!_reloadWhenActiveRequestsFinish.contains(placement)) {
      return;
    }
    if (_loadingTasks.containsKey(placement)) {
      _log(
        'skip-pending-reload-after-active',
        placement,
        info: info,
        extra: 'reason=loading-task-active',
      );
      return;
    }
    _reloadWhenActiveRequestsFinish.remove(placement);
    if ((_cacheMap[placement]?.isNotEmpty ?? false)) {
      _log(
        'skip-pending-reload-after-active',
        placement,
        info: info,
        extra: 'reason=cache-filled',
      );
      return;
    }
    _logCacheReload(placement, trigger: 'active-finished-empty-reload');
    await loadPlacement(placement, force: true);
  }

  void _log(
    String stage,
    AdPlacement placement, {
    required AdInfoBean info,
    String? extra,
  }) {
    if (kReleaseMode) {
      return;
    }

    final buffer = StringBuffer()
      ..write('[FlutterPdfAdLoader] ')
      ..write(stage)
      ..write(' placement=')
      ..write(_placementLabel(placement))
      ..write(' adInfo={')
      ..write(info.logSummary)
      ..write('}');

    if (extra != null && extra.isNotEmpty) {
      buffer
        ..write(' ')
        ..write(extra);
    }

    debugPrint(buffer.toString());
  }

  String _placementLabel(AdPlacement placement) {
    return placement.name;
  }
}

class _AdLoadResult {
  const _AdLoadResult._({this.ad, this.failureReason, this.adNetwork});

  const _AdLoadResult.success(Ad ad) : this._(ad: ad);

  const _AdLoadResult.failure(String reason, {String? adNetwork})
    : this._(failureReason: reason, adNetwork: adNetwork);

  final Ad? ad;
  final String? failureReason;
  final String? adNetwork;
}

class ShowAdResult {
  const ShowAdResult._({required this.shown, this.failureReason});

  const ShowAdResult.success() : this._(shown: true);

  const ShowAdResult.failure(String reason)
    : this._(shown: false, failureReason: reason);

  const ShowAdResult.programmaticClose()
    : this._(shown: null, failureReason: 'programmatic-close');

  final bool? shown;
  final String? failureReason;
}
