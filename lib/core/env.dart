/// Build-time configuration injected via `--dart-define-from-file=env.json`
/// (see env.json.example). Credentials are compiled into the APK; changing
/// them requires a rebuild.
class Env {
  static const volcanoTtsAppId = String.fromEnvironment("VOLCANO_TTS_APPID");
  static const volcanoTtsToken = String.fromEnvironment("VOLCANO_TTS_TOKEN");
  static const volcanoTtsCluster = String.fromEnvironment("VOLCANO_TTS_CLUSTER",
      defaultValue: "volcano_tts");
  static const volcanoTtsDefaultVoice = String.fromEnvironment(
      "VOLCANO_TTS_VOICE",
      defaultValue: "zh_female_cancan_mars_bigtts");

  static bool get hasVolcanoTts =>
      volcanoTtsAppId.isNotEmpty && volcanoTtsToken.isNotEmpty;
}
