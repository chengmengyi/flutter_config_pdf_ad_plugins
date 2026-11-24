// ignore_for_file: prefer_initializing_formals

import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';

import '../bean/ad_info_bean.dart';
import '../enum/ad_placement.dart';
import '../enum/ad_type.dart';
import 'ad_remote_request.dart';

class AdRemoteConfig {
  const AdRemoteConfig({
    required this.adsJson,
    required this.placements,
    required this.blockedPlacements,
    required this.maxImpressions,
    required this.maxClicks,
    required this.accidentalClickProbabilityPercent,
  });

  final Map<String, dynamic> adsJson;
  final Map<AdPlacement, List<AdInfoBean>> placements;
  final Set<AdPlacement> blockedPlacements;
  final int? maxImpressions;
  final int? maxClicks;

  /// 当前仅保存后台值，暂不参与广告请求或点击逻辑。
  final double? accidentalClickProbabilityPercent;
}

class AdRemoteConfigManager {
  AdRemoteConfigManager({
    Dio? dio,
    Future<void> Function(Duration duration)? delay,
    Future<void> Function(Map<String, dynamic> ads)? saveConfiguration,
    Future<Map<String, dynamic>?> Function()? readConfiguration,
  }) : _dio = dio ?? Dio(),
       _delay = delay ?? Future<void>.delayed,
       _saveConfiguration = saveConfiguration,
       _readConfiguration = readConfiguration;

  static const int maxAttempts = 4;
  static const Duration retryDelay = Duration(seconds: 2);
  static const String _storageContainer =
      'flutter_config_pdf_ad_plugins_remote_config';
  static const String _configKey = 'ads_config_v1';

  final Dio _dio;
  final Future<void> Function(Duration duration) _delay;
  final Future<void> Function(Map<String, dynamic> ads)? _saveConfiguration;
  final Future<Map<String, dynamic>?> Function()? _readConfiguration;
  GetStorage? _storage;
  Future<void>? _storageReadyFuture;

  Future<AdRemoteConfig?> load({
    required AdRemoteRequest remoteRequest,
    required String defaultAd,
  }) async {
    try {
      remoteRequest.validate();
      for (var attempt = 1; attempt <= maxAttempts; attempt++) {
        try {
          _log('request start attempt=$attempt/$maxAttempts');
          _logJson('request url', remoteRequest.url);
          _logJson('request headers', remoteRequest.headers);
          _logJson('request body', remoteRequest.body);
          final response = await _dio
              .post<dynamic>(
                remoteRequest.url,
                data: remoteRequest.body,
                options: Options(
                  headers: remoteRequest.headers,
                  responseType: ResponseType.json,
                  validateStatus: (_) => true,
                ),
                cancelToken: null,
              )
              .timeout(remoteRequest.timeout);
          _log('response httpStatus=${response.statusCode}');
          _logJson('response', response.data);
          final statusCode = response.statusCode ?? -1;
          if (statusCode < 200 || statusCode >= 300) {
            throw StateError('HTTP status is $statusCode');
          }
          final encrypted = _asJsonMap(response.data, label: 'response');
          final decoder = AdRemoteMappingDecoder(remoteRequest.mapping);
          final decoded = decoder.decode(encrypted);
          _logJson('decoded response', decoded);
          final businessCode = _readExactInt(decoded['code'], 'code');
          if (businessCode != 200) {
            throw StateError('Business code is $businessCode');
          }
          final data = _asJsonMap(decoded['data'], label: 'data');
          final ads = _asJsonMap(data['ads'], label: 'data.ads');
          final config = AdRemoteConfigParser.parseAds(ads);
          await _save(config.adsJson);
          _log('configuration source=remote saved=true');
          return config;
        } catch (error, stackTrace) {
          _log('request failed attempt=$attempt/$maxAttempts error=$error');
          _logStack(stackTrace);
          if (attempt < maxAttempts) {
            _log('request retry after ${retryDelay.inSeconds}s');
            await _delay(retryDelay);
          }
        }
      }
    } catch (error, stackTrace) {
      _log('remote request validation failed error=$error');
      _logStack(stackTrace);
    }

    final local = await _readLocal();
    if (local != null) {
      try {
        final config = AdRemoteConfigParser.parseAds(local);
        _log('configuration source=local');
        return config;
      } catch (error, stackTrace) {
        _log('local configuration invalid error=$error');
        _logStack(stackTrace);
      }
    }

    try {
      final decodedDefault = jsonDecode(defaultAd);
      final defaultMap = _asJsonMap(decodedDefault, label: 'defaultAd');
      final ads = defaultMap['ads'] == null
          ? defaultMap
          : _asJsonMap(defaultMap['ads'], label: 'defaultAd.ads');
      final config = AdRemoteConfigParser.parseAds(ads);
      _logJson('default configuration', config.adsJson);
      _log('configuration source=default');
      return config;
    } catch (error, stackTrace) {
      _log('default configuration invalid error=$error');
      _logStack(stackTrace);
      return null;
    }
  }

  Future<void> _save(Map<String, dynamic> ads) async {
    final saveConfiguration = _saveConfiguration;
    if (saveConfiguration != null) {
      await saveConfiguration(ads);
      return;
    }
    await _ensureStorageReady();
    await _storage?.write(_configKey, jsonEncode(ads));
  }

  Future<Map<String, dynamic>?> _readLocal() async {
    try {
      final readConfiguration = _readConfiguration;
      if (readConfiguration != null) {
        return readConfiguration();
      }
      await _ensureStorageReady();
      final raw = _storage?.read<dynamic>(_configKey);
      if (raw == null) {
        return null;
      }
      final decoded = raw is String ? jsonDecode(raw) : raw;
      return _asJsonMap(decoded, label: 'local configuration');
    } catch (error, stackTrace) {
      _log('read local configuration failed error=$error');
      _logStack(stackTrace);
      return null;
    }
  }

  Future<void> _ensureStorageReady() {
    final inFlight = _storageReadyFuture;
    if (inFlight != null) {
      return inFlight;
    }
    final future = () async {
      await GetStorage.init(_storageContainer);
      _storage = GetStorage(_storageContainer);
    }();
    _storageReadyFuture = future;
    return future;
  }

  void _log(String message) {
    if (!kReleaseMode) {
      debugPrint('[AdRemoteConfig] $message');
    }
  }

  void _logJson(String label, Object? value) {
    if (kReleaseMode) {
      return;
    }
    String output;
    try {
      output = const JsonEncoder.withIndent('  ').convert(value);
    } catch (_) {
      output = value.toString();
    }
    debugPrint('[AdRemoteConfig] $label:\n$output');
  }

  void _logStack(StackTrace stackTrace) {
    if (!kReleaseMode) {
      debugPrint('[AdRemoteConfig] $stackTrace');
    }
  }
}

class AdRemoteConfigParser {
  const AdRemoteConfigParser._();

  static const Set<String> supportedAdTypes = <String>{
    'interstitial',
    'rewarded',
    'app_open',
    'banner',
    'native',
    'native_fullscreen',
  };

  static AdRemoteConfig parseAds(Map<String, dynamic> source) {
    final ads = _deepJsonMap(source);
    final dailyLimits = ads['daily_limits'] == null
        ? null
        : _asJsonMap(ads['daily_limits'], label: 'daily_limits');
    final maxImpressions = _readOptionalDailyLimit(
      dailyLimits?['impressions'],
      'daily_limits.impressions',
    );
    final maxClicks = _readOptionalDailyLimit(
      dailyLimits?['clicks'],
      'daily_limits.clicks',
    );
    final accidentalClickProbabilityPercent =
        dailyLimits?['accidental_click_probability_percent'] == null
        ? null
        : _readNonNegativeDouble(
            dailyLimits!['accidental_click_probability_percent'],
            'daily_limits.accidental_click_probability_percent',
          );
    final rawScenes = ads['ad_scenes'];
    if (rawScenes != null && rawScenes is! List) {
      throw const FormatException('ad_scenes must be an array');
    }
    final scenes = rawScenes as List? ?? const <dynamic>[];

    final placements = <AdPlacement, List<AdInfoBean>>{};
    final blockedPlacements = <AdPlacement>{};
    for (var sceneIndex = 0; sceneIndex < scenes.length; sceneIndex++) {
      final scene = _asJsonMap(
        scenes[sceneIndex],
        label: 'ad_scenes[$sceneIndex]',
      );
      final sceneId = _readNonEmptyString(
        scene['scene_id'],
        'ad_scenes[$sceneIndex].scene_id',
      );
      if (sceneId.length > 128) {
        throw FormatException('ad_scenes[$sceneIndex].scene_id is too long');
      }
      final placement = AdPlacement.parse(sceneId);
      if (placements.containsKey(placement)) {
        throw FormatException('Duplicate scene_id: $sceneId');
      }
      final blocked = scene['blocked'];
      if (blocked is! bool) {
        throw FormatException('ad_scenes[$sceneIndex].blocked must be bool');
      }
      final rawPlacementConfigs = scene['placements'];
      if (rawPlacementConfigs != null && rawPlacementConfigs is! List) {
        throw FormatException(
          'ad_scenes[$sceneIndex].placements must be an array',
        );
      }
      if (blocked) {
        blockedPlacements.add(placement);
      }
      final placementConfigs =
          rawPlacementConfigs as List? ?? const <dynamic>[];
      final configs = <AdInfoBean>[];
      for (
        var configIndex = 0;
        configIndex < placementConfigs.length;
        configIndex++
      ) {
        final path = 'ad_scenes[$sceneIndex].placements[$configIndex]';
        final rawConfig = _asJsonMap(
          placementConfigs[configIndex],
          label: path,
        );
        final adType = _readNonEmptyString(
          rawConfig['ad_type'],
          '$path.ad_type',
        );
        final parsedAdType = AdTypeX.tryParse(adType);
        if (parsedAdType == null) {
          throw FormatException('Unsupported $path.ad_type: $adType');
        }
        final intervalSecs = _readExactInt(
          rawConfig['interval_secs'],
          '$path.interval_secs',
        );
        if (intervalSecs < 1) {
          throw FormatException('$path.interval_secs must be at least 1');
        }
        final sort = _readExactInt(rawConfig['sort'], '$path.sort');
        if (sort < 0) {
          throw FormatException('$path.sort must be non-negative');
        }
        final adId = _readNonEmptyString(rawConfig['ad_id'], '$path.ad_id');
        if (adId.length > 256) {
          throw FormatException('$path.ad_id is too long');
        }
        configs.add(
          AdInfoBean(
            adId: adId,
            adSource: _readNonEmptyString(
              rawConfig['ad_source'],
              '$path.ad_source',
            ),
            adType: parsedAdType,
            sort: sort,
            intervalSecs: intervalSecs,
          ),
        );
      }
      placements[placement] = List<AdInfoBean>.unmodifiable(configs);
    }

    return AdRemoteConfig(
      adsJson: ads,
      placements: Map<AdPlacement, List<AdInfoBean>>.unmodifiable(placements),
      blockedPlacements: Set<AdPlacement>.unmodifiable(blockedPlacements),
      maxImpressions: maxImpressions,
      maxClicks: maxClicks,
      accidentalClickProbabilityPercent: accidentalClickProbabilityPercent,
    );
  }
}

int? _readOptionalDailyLimit(dynamic value, String label) {
  if (value == null) {
    return null;
  }
  final result = _readExactInt(value, label);
  if (result < 1 || result > 99999) {
    throw FormatException('$label must be between 1 and 99999');
  }
  return result;
}

class AdRemoteMappingDecoder {
  AdRemoteMappingDecoder(Map<String, String> mapping)
    : _root = _buildTree(mapping);

  final _MappingNode _root;

  Map<String, dynamic> decode(Map<String, dynamic> source) {
    return _decodeObject(source, _root);
  }

  static _MappingNode _buildTree(Map<String, String> mapping) {
    if (mapping.isEmpty) {
      throw const FormatException('mapping must not be empty');
    }
    final fullPaths = <String, List<String>>{};
    final canonicalByEncryptedPath = <String, String>{};
    for (final entry in mapping.entries) {
      final canonicalPath = entry.key.trim();
      final encryptedPath = entry.value.trim();
      final canonicalSegments = _splitPath(canonicalPath, 'mapping key');
      final encryptedSegments = _splitPath(encryptedPath, 'mapping value');
      if (canonicalSegments.length != encryptedSegments.length) {
        throw FormatException(
          'Mapping paths must have the same depth: '
          '$canonicalPath -> $encryptedPath',
        );
      }
      for (var index = 0; index < canonicalSegments.length; index++) {
        if ((canonicalSegments[index] == '*') !=
            (encryptedSegments[index] == '*')) {
          throw FormatException(
            'Mapping array markers must align: '
            '$canonicalPath -> $encryptedPath',
          );
        }
      }
      final previous = canonicalByEncryptedPath[encryptedPath];
      if (previous != null) {
        throw FormatException(
          'Mapping must be one-to-one: $previous and $canonicalPath',
        );
      }
      canonicalByEncryptedPath[encryptedPath] = canonicalPath;
      fullPaths[canonicalPath] = encryptedSegments;
    }

    for (final entry in fullPaths.entries) {
      final canonicalSegments = entry.key.split('.');
      for (var length = 1; length < canonicalSegments.length; length++) {
        if (canonicalSegments[length - 1] == '*') {
          continue;
        }
        final parentPath = canonicalSegments.take(length).join('.');
        final encryptedParent = fullPaths[parentPath];
        if (encryptedParent == null ||
            !_listEquals(
              encryptedParent,
              entry.value.take(length).toList(growable: false),
            )) {
          throw FormatException(
            'Mapping parent path is missing or inconsistent: ${entry.key}',
          );
        }
      }
    }

    final arrayContainerPaths = <String>{};
    for (final canonicalPath in fullPaths.keys) {
      final segments = canonicalPath.split('.');
      for (var index = 0; index < segments.length; index++) {
        if (segments[index] == '*') {
          arrayContainerPaths.add(
            segments.take(index).where((segment) => segment != '*').join('.'),
          );
        }
      }
    }

    final root = _MappingNode(canonicalName: '', encryptedKey: '');
    for (final entry in fullPaths.entries) {
      final canonicalSegments = entry.key.split('.');
      var current = root;
      final canonicalPrefix = <String>[];
      for (var index = 0; index < canonicalSegments.length; index++) {
        final canonicalSegment = canonicalSegments[index];
        if (canonicalSegment == '*') {
          continue;
        }
        canonicalPrefix.add(canonicalSegment);
        final encryptedKey = entry.value[index];
        final isArray = arrayContainerPaths.contains(canonicalPrefix.join('.'));
        final existing = current.children[canonicalSegment];
        if (existing != null &&
            (existing.encryptedKey != encryptedKey ||
                existing.isArray != isArray)) {
          throw FormatException('Mapping path conflict at ${entry.key}');
        }
        current = current.children.putIfAbsent(
          canonicalSegment,
          () => _MappingNode(
            canonicalName: canonicalSegment,
            encryptedKey: encryptedKey,
            isArray: isArray,
          ),
        );
      }
    }
    return root;
  }

  static Map<String, dynamic> _decodeObject(
    Map<String, dynamic> source,
    _MappingNode parent,
  ) {
    final output = <String, dynamic>{};
    final nodesByEncryptedKey = <String, _MappingNode>{
      for (final node in parent.children.values) node.encryptedKey: node,
    };
    for (final entry in source.entries) {
      final node = nodesByEncryptedKey[entry.key];
      if (node == null) {
        continue;
      }
      output[node.canonicalName] = _decodeValue(entry.value, node);
    }
    return output;
  }

  static dynamic _decodeValue(dynamic value, _MappingNode node) {
    if (value == null) {
      return null;
    }
    if (node.isArray) {
      if (value is! List) {
        throw FormatException('${node.canonicalName} must be an array');
      }
      if (node.children.isEmpty) {
        return List<dynamic>.from(value);
      }
      return value
          .map(
            (item) => _decodeObject(
              _asJsonMap(item, label: '${node.canonicalName} item'),
              node,
            ),
          )
          .toList(growable: false);
    }
    if (node.children.isEmpty) {
      return value;
    }
    return _decodeObject(_asJsonMap(value, label: node.canonicalName), node);
  }
}

class _MappingNode {
  _MappingNode({
    required this.canonicalName,
    required this.encryptedKey,
    this.isArray = false,
  });

  final String canonicalName;
  final String encryptedKey;
  final bool isArray;
  final Map<String, _MappingNode> children = <String, _MappingNode>{};
}

List<String> _splitPath(String path, String label) {
  if (path.isEmpty) {
    throw FormatException('$label must not be empty');
  }
  final segments = path.split('.');
  if (segments.any((segment) => segment.isEmpty)) {
    throw FormatException('$label contains an empty segment: $path');
  }
  if (segments.last == '*') {
    throw FormatException('$label must not end with *: $path');
  }
  for (var index = 0; index < segments.length; index++) {
    final segment = segments[index];
    if (segment == '*' && (index == 0 || segments[index - 1] == '*')) {
      throw FormatException('$label contains an invalid array marker: $path');
    }
    if (segment != '*' && segment.contains('*')) {
      throw FormatException('$label must use * as a standalone segment: $path');
    }
  }
  return segments;
}

Map<String, dynamic> _asJsonMap(dynamic value, {required String label}) {
  if (value is String) {
    return _asJsonMap(jsonDecode(value), label: label);
  }
  if (value is! Map) {
    throw FormatException('$label must be a JSON object');
  }
  return <String, dynamic>{
    for (final entry in value.entries) entry.key.toString(): entry.value,
  };
}

Map<String, dynamic> _deepJsonMap(Map<String, dynamic> value) {
  return <String, dynamic>{
    for (final entry in value.entries) entry.key: _deepJsonValue(entry.value),
  };
}

dynamic _deepJsonValue(dynamic value) {
  if (value is Map) {
    return <String, dynamic>{
      for (final entry in value.entries)
        entry.key.toString(): _deepJsonValue(entry.value),
    };
  }
  if (value is List) {
    return value.map(_deepJsonValue).toList(growable: false);
  }
  return value;
}

String _readNonEmptyString(dynamic value, String path) {
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$path must be a non-empty string');
  }
  return value.trim();
}

int _readExactInt(dynamic value, String path) {
  if (value is! num || !value.isFinite || value.toInt().toDouble() != value) {
    throw FormatException('$path must be an integer');
  }
  return value.toInt();
}

double _readNonNegativeDouble(dynamic value, String path) {
  if (value is! num || !value.isFinite || value < 0) {
    throw FormatException('$path must be a non-negative number');
  }
  return value.toDouble();
}

bool _listEquals(List<String> left, List<String> right) {
  if (left.length != right.length) {
    return false;
  }
  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) {
      return false;
    }
  }
  return true;
}
