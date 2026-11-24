import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config_pdf_ad_plugins/flutter_config_pdf_ad_plugins.dart';
import 'package:flutter_tba_info_new/flutter_tba_info_new.dart';

const Map<String, String> mapping = <String, String>{
  "code": "decal",
  "msg": "earpiece",
  "data": "concur",
  "data.ads": "concur.shore",
  "data.ads.daily_limits": "concur.shore.suburb",
  "data.ads.daily_limits.impressions": "concur.shore.suburb.eldercare",
  "data.ads.daily_limits.clicks": "concur.shore.suburb.sank",
  "data.ads.daily_limits.accidental_click_probability_percent":
      "concur.shore.suburb.ipod",
  "data.ads.ad_scenes": "concur.shore.unread",
  "data.ads.ad_scenes.*.scene_id": "concur.shore.unread.*.revival",
  "data.ads.ad_scenes.*.blocked": "concur.shore.unread.*.pumice",
  "data.ads.ad_scenes.*.placements": "concur.shore.unread.*.detective",
  "data.ads.ad_scenes.*.placements.*.sort":
      "concur.shore.unread.*.detective.*.atonable",
  "data.ads.ad_scenes.*.placements.*.ad_source":
      "concur.shore.unread.*.detective.*.angles",
  "data.ads.ad_scenes.*.placements.*.ad_type":
      "concur.shore.unread.*.detective.*.septum",
  "data.ads.ad_scenes.*.placements.*.ad_id":
      "concur.shore.unread.*.detective.*.provoking",
  "data.ads.ad_scenes.*.placements.*.interval_secs":
      "concur.shore.unread.*.detective.*.silliness",
};

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {
                  _init();
                },
                child: Text("初始化"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _init() async {
    FlutterConfigPdfAdPlugins.instance.initPlugins(
      remoteRequest: AdRemoteRequest(
        url: "https://client.docnovapdftoolreaderscanner.com/api/dwarf",
        headers: await _getHeaderMap(),
        body: await _getBodyMap(),
        mapping: mapping,
      ),
      defaultAd: "",
      nativeAdHeadlineCallback:
          ({required String? headline, required bool isNextGenAdmob}) {},
    );
  }

  Future<Map<String, dynamic>> _getHeaderMap() async => {
    "x-yearling": kDebugMode
        ? "com.docnova.pdftool.reader.scanner"
        : await FlutterTbaInfoNew.instance.getBundleId(),
    "x-humid": await FlutterTbaInfoNew.instance.getAppVersion(),
  };

  Future<Map<String, dynamic>> _getBodyMap() async {
    var referrerMap = await FlutterTbaInfoNew.instance.getReferrerMap();
    return {
      "comment": Platform.isAndroid ? "android" : "ios",
      "tractor": await FlutterTbaInfoNew.instance.getDistinctId(),
      "encore": "86690fd94f984a09e472c2cd5ba3aa7a",
      "fraction": await FlutterTbaInfoNew.instance.getManufacturer(),
      "recess": await FlutterTbaInfoNew.instance.getBrand(),
      "oasis": await FlutterTbaInfoNew.instance.getDeviceModel(),
      "expand": await FlutterTbaInfoNew.instance.getOsVersion(),
      "prison": await FlutterTbaInfoNew.instance.getSystemLanguage(),
      "narrow": await FlutterTbaInfoNew.instance.getOsCountry(),
      "badge": referrerMap["referrer_url"],
      "myspace": DateTime.now().millisecondsSinceEpoch,
      "headed": await FlutterTbaInfoNew.instance.getAndroidId(),
      "saddled": await FlutterTbaInfoNew.instance.getGaid(),
      "whisking": await FlutterTbaInfoNew.instance.getIdfa(),
      "thicket": await FlutterTbaInfoNew.instance.isEmulator(),
      "daily": await FlutterTbaInfoNew.instance.isDeveloper(),
      "unexposed": await FlutterTbaInfoNew.instance.isAdb(),
      "density": await FlutterTbaInfoNew.instance.hasSim(),
      "senate": await FlutterTbaInfoNew.instance.isFirebaseTestLab(),
    };
  }
}
