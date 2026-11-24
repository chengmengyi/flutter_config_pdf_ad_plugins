import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../bean/ad_info_bean.dart';

class LoadedAdCacheEntry {
  LoadedAdCacheEntry({
    required this.info,
    required this.ad,
    required this.cachedAt,
    required this.requestOrder,
  });

  final AdInfoBean info;
  final Ad ad;
  Object? adPosId;
  final DateTime cachedAt;
  final int requestOrder;
  final CachedAdWidgetLease _widgetLease = CachedAdWidgetLease();
  bool _disposeRequested = false;
  bool _disposed = false;

  bool get hasWidgetLease => _widgetLease.isHeld;

  bool reserveForWidget({Duration timeout = const Duration(seconds: 2)}) {
    return _widgetLease.tryReserve(
      timeout: timeout,
      onReservationExpired: () => unawaited(_disposeIfRequested()),
    );
  }

  bool attachReservedWidget() => _widgetLease.attach();

  Future<void> releaseWidgetLease() async {
    _widgetLease.release();
    await _disposeIfRequested();
  }

  void bindAdPosId(Object value) {
    adPosId = value;
  }

  DateTime? get expireAt {
    final exportTime = info.effectiveExportTime;
    if (exportTime == null || exportTime <= 0) {
      return null;
    }
    return cachedAt.add(Duration(seconds: exportTime));
  }

  bool get isExpired {
    final expireAt = this.expireAt;
    if (expireAt == null) {
      return false;
    }
    return DateTime.now().isAfter(expireAt);
  }

  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    if (_widgetLease.isHeld) {
      _disposeRequested = true;
      return;
    }
    await _disposeNow();
  }

  Future<void> _disposeIfRequested() async {
    if (!_disposeRequested || _widgetLease.isHeld) {
      return;
    }
    await _disposeNow();
  }

  Future<void> _disposeNow() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _disposeRequested = false;
    await ad.dispose();
  }
}

class CachedAdWidgetLease {
  Timer? _reservationTimer;
  bool _reserved = false;
  bool _attached = false;

  bool get isHeld => _reserved || _attached;

  bool tryReserve({
    required Duration timeout,
    void Function()? onReservationExpired,
  }) {
    if (isHeld) {
      return false;
    }
    _reserved = true;
    _reservationTimer = Timer(timeout, () {
      if (!_reserved || _attached) {
        return;
      }
      _reserved = false;
      _reservationTimer = null;
      onReservationExpired?.call();
    });
    return true;
  }

  bool attach() {
    if (!_reserved || _attached) {
      return false;
    }
    _reserved = false;
    _attached = true;
    _reservationTimer?.cancel();
    _reservationTimer = null;
    return true;
  }

  void release() {
    _reserved = false;
    _attached = false;
    _reservationTimer?.cancel();
    _reservationTimer = null;
  }
}
