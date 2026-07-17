import "package:ciyue/core/app_router.dart";
import "package:ciyue/repositories/settings.dart";
import "package:ciyue/services/ai.dart";
import "package:ciyue/src/generated/i18n/app_localizations.dart";
import "package:flutter/material.dart";

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatViewModel extends ChangeNotifier {
  final textController = TextEditingController();
  final focusNode = FocusNode();

  final List<ChatMessage> _messages = [];
  late final AI _ai;

  ChatViewModel() {
    final config = settings.getAiProviderConfig(settings.aiProvider);
    _ai = AI(
      provider: settings.aiProvider,
      model: config["model"] ?? "",
      apikey: config["apiKey"] ?? "",
    );
  }

  @override
  void dispose() {
    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  List<ChatMessage> get messages => _messages;

  Future<void> sendMessage() async {
    final text = textController.text;
    if (text.isEmpty) {
      return;
    }

    textController.clear();
    _messages.add(ChatMessage(text: text, isUser: true));
    notifyListeners();

    try {
      final response = await _ai.request(text);
      _messages.add(ChatMessage(text: response, isUser: false));
    } catch (e) {
      final locale = AppLocalizations.of(navigatorKey.currentContext!)!;
      _messages.add(ChatMessage(
          text: locale.errorWithMessage(e.toString()), isUser: false));
    }
    notifyListeners();
  }
}
