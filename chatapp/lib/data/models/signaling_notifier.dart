

import 'dart:convert';

import 'package:chatapp/data/constants.dart';
import 'package:chatapp/data/models/webrtc_notifier.dart';

import 'package:chatapp/state_management/riverpods.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';



class SignalingNotifier extends Notifier<void> {
  WebSocketChannel? _channel;
  String? currentUserId;
  bool _isListening = false;

  @override
  void build() {
    _init();
    ref.onDispose(() {
      _channel?.sink.close();
    });
  }

  Future<void> _init() async {
    currentUserId = ref.watch(userIdProvider);
    if (currentUserId == null) return;

    if (_channel == null) {
      _channel = WebSocketChannel.connect(Uri.parse('ws$backendUrl'));
      _channel!.sink.add(jsonEncode({
        'type': 'register',
        'userId': currentUserId,
      }));
    }

    if (_isListening) return;
    _isListening = true;

    _channel!.stream.listen(
      _onEvent,
      onError: (err) => print('WS error: $err'),
      onDone: () => print('WS closed'),
    );
  }

  void _onEvent(event) {
  
    if (!event.trim().startsWith('{')) {
      print('Non-JSON message: $event');
      return;
    }
    final decoded = jsonDecode(event);
    print(decoded);
    if (decoded['type'] == 'message') {
      ref.read(chatProvider.notifier).receiveMessage(decoded['payload']);
    } else if(decoded['type']=='seen'){
      
      ref.read(chatProvider.notifier).setSeen(decoded['payload'], true);

    } else if (decoded['type'] == 'typing') {
      // handle typing
    } else if (decoded['type'] == 'call') {
      ref.read(webRTCNotifierProvider.notifier).handleCall(decoded['payload']);
      
    }
    
  }

  void sendMessage(String encoded) {
    print(encoded);
    _channel?.sink.add(encoded);
  }
 
}
