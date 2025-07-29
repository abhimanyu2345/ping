import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:chatapp/widgets/incoming_call_panel_widget.dart';
import 'package:chatapp/data/models/user_data_provider.dart';
import 'package:chatapp/data/models/user_data.dart';
import 'package:chatapp/state_management/riverpods.dart';
import 'package:chatapp/main.dart';

final webRTCNotifierProvider = NotifierProvider<WebRTCNotifier, WebRTCState>(() => WebRTCNotifier());

class WebRTCState {
  final RTCPeerConnection? peerConnection;
  final MediaStream? localStream;
  final String? callerId;
  final bool isMuted;
  final MediaStream? remoteStream;

  WebRTCState({
    this.peerConnection,
    this.localStream,
    this.callerId,
    this.isMuted = false,
    this.remoteStream,
  });

  WebRTCState copyWith({
    RTCPeerConnection? peerConnection,
    MediaStream? localStream,
    MediaStream? remoteStream,
    String? callerId,
    
    bool? isMuted,
  }) {
    return WebRTCState(
      peerConnection: peerConnection ?? this.peerConnection,
      localStream: localStream ?? this.localStream,
      callerId: callerId ?? this.callerId,
      isMuted: isMuted ?? this.isMuted,
    );
  }
}

class WebRTCNotifier extends Notifier<WebRTCState> {
  bool _isDisposed = false;

  @override
  WebRTCState build() => WebRTCState();

  Future<MediaStream> getLocalStream() async {
    if (state.localStream != null) return state.localStream!;
    final stream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': {'facingMode': 'user'},
    });

    if (_isDisposed) {
      stream.getTracks().forEach((t) => t.stop());
      throw Exception('Disposed during getLocalStream');
    }

    state = state.copyWith(localStream: stream);
    return stream;
  }

  Future<void> _createPeerConnection() async {
    final config = {
      'iceServers': [
        {'url': 'stun:stun.l.google.com:19302'}
      ]
    };
    final pc = await createPeerConnection(config);
    final stream = await getLocalStream();

    for (final track in stream.getTracks()) {
      await pc.addTrack(track, stream);
    }

    pc.onIceCandidate = (candidate) {
      ref.read(signalingProvider.notifier).sendMessage(jsonEncode({
        'type': 'call',
        'payload': {
          'type': 'candidate',
          'to': state.callerId,
          'candidate': {
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
          },
        },
      }));
    };

    state = state.copyWith(peerConnection: pc);
  }

  Future<void> startCall(String id) async {
    state = state.copyWith(callerId: id);
    await _createPeerConnection();
    final offer = await state.peerConnection!.createOffer();
    await state.peerConnection!.setLocalDescription(offer);

    ref.read(signalingProvider.notifier).sendMessage(jsonEncode({
      'type': 'call',
      'payload': {
        'type': 'offer',
        'to': id,
        'sdp': offer.sdp,
      }
    }));
  }

  Future<void> handleRemoteOffer(String sdp, String from) async {
    await _createPeerConnection();
    await state.peerConnection!.setRemoteDescription(RTCSessionDescription(sdp, 'offer'));
    final answer = await state.peerConnection!.createAnswer();
    await state.peerConnection!.setLocalDescription(answer);

    ref.read(signalingProvider.notifier).sendMessage(jsonEncode({
      'type': 'call',
      'payload': {
        'type': 'answer',
        'to': from,
        'sdp': answer.sdp,
      }
    }));
  }

  Future<void> handleRemoteAnswer(String sdp) async {
    
    await state.peerConnection?.setRemoteDescription(RTCSessionDescription(sdp, 'answer'));
    state.peerConnection?.onTrack =(RTCTrackEvent event) {
  if (event.streams.isNotEmpty) {
    final remoteStream = event.streams[0];
    // Update state with remote stream or pass it to a video renderer
    state = state.copyWith(remoteStream: remoteStream);
  }

  };
  }

  Future<void> handleRemoteCandidate(Map<String, dynamic> c) async {
    final candidate = RTCIceCandidate(c['candidate'], c['sdpMid'], c['sdpMLineIndex']);
    await state.peerConnection?.addCandidate(candidate);
  }

  Future<void> switchCamera() async {
    final videoTrack = state.localStream?.getVideoTracks().first;
    if (videoTrack != null) {
      await Helper.switchCamera(videoTrack);
    }
  }

  void toggleMute(bool enable) {
    state.localStream?.getAudioTracks().forEach((track) => track.enabled = enable);
    state = state.copyWith(isMuted: !enable);
  }

  void disposeResources() {
    state.localStream?.getTracks().forEach((t) => t.stop());
    state.peerConnection?.close();
    state = WebRTCState();
    _isDisposed = true;
  }

  Future<void> handleCall(Map<String, dynamic> payload) async {
    switch (payload['type']) {
    case 'offer':
      UserProfileData? profile = ref.read(userDataProvider)[payload['to']];
      if (profile == null) {
        await ref.read(userDataProvider.notifier).fetchUserProfileData(payload['to']);
        profile = ref.read(userDataProvider)[payload['to']];
      }
      final context = navigatorKey.currentState?.overlay?.context;

      if (context != null && profile != null) {
        showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel: 'Dismiss',
          barrierColor: Colors.black.withOpacity(0.3),
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, _, __) => Align(
            alignment: Alignment.topCenter,
            child: IncomingCallPanelWidget(profile: profile!),
          ),
          transitionBuilder: (context, animation, _, child) => SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
                .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
            child: child,
          ),
        );
      }
      break;
      

    }
  }
}