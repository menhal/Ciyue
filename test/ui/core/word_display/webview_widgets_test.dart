import "package:ciyue/ui/core/word_display/webview_helpers.dart";
import "package:flutter_test/flutter_test.dart";
import "package:flutter_inappwebview/flutter_inappwebview.dart";

void main() {
  test("regular WebView navigation is allowed", () {
    expect(
      navigationPolicyForUrl(WebUri("http://127.0.0.1:42433/")),
      NavigationActionPolicy.ALLOW,
    );
    expect(
      navigationPolicyForUrl(WebUri("entry://word")),
      NavigationActionPolicy.CANCEL,
    );
    expect(
      navigationPolicyForUrl(WebUri("sound://word.mp3")),
      NavigationActionPolicy.CANCEL,
    );
  });
}
