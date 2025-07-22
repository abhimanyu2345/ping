import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:chatapp/data/models/chat_message.dart';
import 'package:chatapp/state_management/riverpods.dart';
import 'package:file_picker/file_picker.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';


class ChatController extends Notifier<Map<String, List<ChatMessage>>> {
  String? currentUserId;
  @override
  Map<String, List<ChatMessage>> build() {
    currentUserId=ref.watch(userIdProvider);
  

    return {};
  }
void receiveMessage(dynamic decoded){
  final message = ChatMessage.fromJson(decoded);
          final chatId = message.chatId;
          addMessage(chatId!, message, false);
  final AudioPlayer player = AudioPlayer();
  player.play(
    UrlSource('https://cdn.pixabay.com/audio/2025/06/02/audio_f91dce208a.mp3')
  );


}
 
void sendMessage(String? id, String to, dynamic content, MessageType type) async {
  
  
  if (currentUserId == null) return;
  
  String finalContent;

  if (type == MessageType.text) {
    // ✅ Text message, just use as-is
    finalContent = content.toString();
  } else {
    // ✅ Media message: Upload to Supabase
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}';
      final filePath = '$currentUserId/$type/$fileName';

      if (content is PlatformFile) {
        if (content.bytes != null) {
          await Supabase.instance.client.storage
              .from('user-media')
              .uploadBinary(filePath, content.bytes!);
        } else if (content.path != null) {
          final file = File(content.path!);
          await Supabase.instance.client.storage
              .from('user-media')
              .upload(filePath, file, );
        } else {
          throw Exception("Invalid file: no path or bytes found");
        }

        // ✅ Use URL for message content
        finalContent = Supabase.instance.client.storage
            .from('user-media')
            .getPublicUrl(filePath);
      } else {
        throw Exception("Expected PlatformFile for media message");
      }
    } catch (e) {
      print("Upload error: $e");
      return;
    }
  }
 String? uuid =id;

  // ✅ Generate message
  if(id==null){
   uuid=  Uuid().v4();
   
  }
  
  final message = ChatMessage(
    chatId: uuid,
    from: currentUserId!,
    to: to,
    message: finalContent, // ✅ Now this is always a String
    time: DateTime.now(),
    type: type,
  );

  // ✅ Send over WebSocket
  String encoded=jsonEncode({
    'type':'chat',
    'payload':{

    ...message.toJson(),}
  });
    
  ref.read(signalingProvider.notifier).sendMessage(encoded);

  // ✅ Add to local state
  addMessage(uuid!, message,false);
}



  void sendTyping(String to) {
    if (currentUserId == null) return;

    String encoded =jsonEncode({
      'type': 'typing',
      'from': currentUserId,
      'to': to,
    });
    ref.read(signalingProvider.notifier).sendMessage(encoded);
  }

  void addMessage(String chatId, ChatMessage message, bool fromDatabase) {
    final updated = {...state};
    fromDatabase?updated[chatId] = [message,...(updated[chatId] ?? [])]:updated[chatId] = [...(updated[chatId] ?? []), message];
    
    state = updated;
  }
  List<ChatMessage> getMessagesFor(String chatId) {
    return state[chatId] ?? [];
  }

void setSeen(Map<String, dynamic> payload, bool isIncoming) {
  final chatId = payload['chatId'] as String;
  final time = DateTime.parse(payload['time'] as String);

  final messages = state[chatId];
  if (messages == null) return;

  final updated = messages.map((e) {
    if (e.time == time) {
      return e.copyWith(marked: true);
    } else {
      return e;
    }
  }).toList();




  if (!isIncoming) {
     ref.read(signalingProvider.notifier).sendMessage(jsonEncode({
      'type': 'seen',
      'payload': {
        'chatId': chatId,
        'time': time.toIso8601String(),
        'to': payload['from'],
      },
    }));
  }

    state = {
  ...state, // copy all other chats
  chatId: updated,};
}
String? fetchUserChatId(String id){
  
  for( var i in state.keys){
    var msgs = state[i];
    if (msgs!=null && (msgs[0].from==id ||msgs[0].to==id)){
      return msgs[0].chatId;
      
    } 
  }
  return null;
}
  
}
