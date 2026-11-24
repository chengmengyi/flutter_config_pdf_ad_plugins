import 'package:flutter_config_pdf_ad_plugins/enum/ad_placement.dart';
import 'package:flutter_config_pdf_ad_plugins/enum/ad_type.dart';
import 'package:flutter_config_pdf_ad_plugins/remote/ad_remote_config_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('nullable limits and null scenes mean no configured ads', () {
    final config = AdRemoteConfigParser.parseAds(<String, dynamic>{
      'daily_limits': <String, dynamic>{
        'impressions': null,
        'clicks': null,
        'accidental_click_probability_percent': null,
      },
      'ad_scenes': null,
    });

    expect(config.maxImpressions, isNull);
    expect(config.maxClicks, isNull);
    expect(config.accidentalClickProbabilityPercent, isNull);
    expect(config.placements, isEmpty);
  });

  test('blocked scene preserves its placement configuration', () {
    final config = AdRemoteConfigParser.parseAds(<String, dynamic>{
      'daily_limits': null,
      'ad_scenes': <dynamic>[
        <String, dynamic>{
          'scene_id': 'pr_new_launch',
          'blocked': true,
          'placements': <dynamic>[
            <String, dynamic>{
              'sort': 2,
              'ad_source': 'admob',
              'ad_type': 'app_open',
              'ad_id': 'unit-a',
              'interval_secs': 3,
            },
          ],
        },
      ],
    });

    expect(config.blockedPlacements, contains(AdPlacement.pr_new_launch));
    final placement = config.placements[AdPlacement.pr_new_launch]!.single;
    expect(placement.adSource, 'admob');
    expect(placement.adType, AdType.appOpen);
    expect(placement.intervalSecs, 3);
  });

  test('daily limits must be in the backend range', () {
    expect(
      () => AdRemoteConfigParser.parseAds(<String, dynamic>{
        'daily_limits': <String, dynamic>{'impressions': 0},
        'ad_scenes': <dynamic>[],
      }),
      throwsFormatException,
    );
    expect(
      () => AdRemoteConfigParser.parseAds(<String, dynamic>{
        'daily_limits': <String, dynamic>{'clicks': 100000},
        'ad_scenes': <dynamic>[],
      }),
      throwsFormatException,
    );
  });
}
