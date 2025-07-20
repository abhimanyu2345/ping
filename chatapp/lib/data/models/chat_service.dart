import 'dart:convert'; // for jsonDecode
import 'package:chatapp/data/models/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatService {
  final ValueNotifier<List<ChatMessage>> latestMessages =
      ValueNotifier<List<ChatMessage>>([]);
  final WebSocketChannel ws;

  ChatService({required this.ws});

  void listenForUpdates() {
    ws.stream.listen(
      (data) {
        try {
          // Parse JSON string to a Map
          final jsonData = jsonDecode(data);
          final chatId = jsonData['chatId'];
          final message = ChatMessage.fromJson(jsonData);
          
          // Copy existing list
          final updatedList = List<ChatMessage>.from(latestMessages.value);

          // Find existing chat
          final existingIndex = updatedList.indexWhere(
            (m) => m.chatId == chatId,
          );

          if (existingIndex != -1) {
            // Update latest message
            updatedList[existingIndex] = message;
          } else {
            // Add new chat
            updatedList.add(message);
          }

          // Update the ValueNotifier
          latestMessages.value = updatedList;

        } catch (e) {
          print('Error parsing data: $e');
        }
      },
      onError: (error) {
        print('WebSocket error: $error');
      },
      onDone: () {
        print('WebSocket closed.');
      },
    );
  }
}
