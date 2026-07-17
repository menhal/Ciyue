import "dart:convert";
import "dart:io";
import "dart:math";
import "dart:typed_data";

import "package:ciyue/core/env.dart";
import "package:ciyue/repositories/settings.dart";
import "package:dio/dio.dart";
import "package:path/path.dart";
import "package:path_provider/path_provider.dart";

/// Chinese-English bilingual voices of the v1 bigtts API (from the official
/// voice list, entries whose language is 中英; labels keep both names).
const volcanoVoices = <(String, String)>[
  ("zh_female_cancan_mars_bigtts", "灿灿 / Shiny"),
  ("zh_female_shuangkuaisisi_moon_bigtts", "爽快思思 / Skye"),
  ("zh_male_wennuanahu_moon_bigtts", "温暖阿虎 / Alvin"),
  ("zh_male_shaonianzixin_moon_bigtts", "少年梓辛 / Brayan"),
  ("zh_male_jingqiangkanye_moon_bigtts", "京腔侃爷 / Harmony"),
  ("zh_male_jieshuonansheng_mars_bigtts", "磁性解说男声 / Morgan"),
  ("zh_female_jitangmeimei_mars_bigtts", "鸡汤妹妹 / Hope"),
  ("zh_female_tiexinnvsheng_mars_bigtts", "贴心女声 / Candy"),
  ("zh_female_mengyatou_mars_bigtts", "萌丫头 / Cutey"),
  ("zh_female_yingyujiaoyu_mars_bigtts", "Tina 老师"),
];

/// Volcano Engine (Doubao) speech synthesis, v1 one-shot HTTP API.
/// Synthesized audio is cached on disk so repeated words don't hit the network.
class VolcanoTts {
  static const _url = "https://openspeech.bytedance.com/api/v1/tts";
  static final _dio = Dio();

  static bool get isConfigured => Env.hasVolcanoTts;

  static Future<Uint8List> synthesize(String text) async {
    final voice = settings.volcanoTtsVoice;

    final cacheFile = await _cacheFileOf(voice, text);
    if (await cacheFile.exists()) {
      return await cacheFile.readAsBytes();
    }

    final reqid =
        "${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(1 << 30)}";
    final response = await _dio.post(
      _url,
      options: Options(headers: {
        "Content-Type": "application/json",
        // Volcano v1 auth scheme is "Bearer;<token>" (semicolon, not space)
        "Authorization": "Bearer;${Env.volcanoTtsToken}",
      }),
      data: {
        "app": {
          "appid": Env.volcanoTtsAppId,
          "token": Env.volcanoTtsToken,
          "cluster": Env.volcanoTtsCluster,
        },
        "user": {"uid": "ciyue"},
        "audio": {
          "voice_type": voice,
          "encoding": "mp3",
          "speed_ratio": 1,
        },
        "request": {"reqid": reqid, "text": text, "operation": "query"},
      },
    );

    final json = response.data as Map<String, dynamic>;
    if (json["code"] != 3000 || json["data"] == null) {
      throw Exception(
          "Volcano TTS ${json["code"]}: ${json["message"] ?? "no audio returned"}");
    }

    final bytes = base64Decode(json["data"] as String);
    try {
      await cacheFile.writeAsBytes(bytes);
    } catch (_) {}
    return bytes;
  }

  static Future<File> _cacheFileOf(String voice, String text) async {
    final dir = Directory(
        join((await getApplicationCacheDirectory()).path, "volcano_tts"));
    await dir.create(recursive: true);
    final name = Uri.encodeComponent("${voice}_$text");
    return File(join(dir.path, "$name.mp3"));
  }
}
