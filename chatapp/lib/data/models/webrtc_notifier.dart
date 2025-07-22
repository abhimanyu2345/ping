import 'dart:convert';
import 'package:chatapp/data/models/user_data.dart';
import 'package:chatapp/data/models/user_data_provider.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/state_management/riverpods.dart';
import 'package:chatapp/widgets/incoming_call_panel_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';


final webRTCNotifierProvider =
    NotifierProvider.autoDispose<WebRTCNotifier, void>(WebRTCNotifier.new);

class WebRTCNotifier extends AutoDisposeNotifier<void> {
  RTCPeerConnection? _peerConnection;
  String? callerId ;
  MediaStream? _localStream;
  bool _isDisposed = false;

  @override
  void build() {
    // 👇 Keeps this Notifier alive even if not watched briefly.
    final link = ref.keepAlive();

    ref.onDispose(() {
      _isDisposed = true;
      _disposeResources();
      link.close();
    });
  }

  Future<MediaStream> getLocalStream() async {
    if (_localStream != null) return _localStream!;

    try {
      final constraints = {
        'audio': true,
        'video': {'facingMode': 'user'}
      };

      print('Requesting user media...');
      _localStream = await navigator.mediaDevices.getUserMedia(constraints);
      print('Got local stream: $_localStream');

      if (_isDisposed) {
        _localStream?.getTracks().forEach((t) => t.stop());
        _localStream = null;
        throw Exception('WebRTCNotifier disposed during getLocalStream');
      }

      return _localStream!;
    } catch (e, st) {
      print('Error getting local stream: $e\n$st');
      rethrow;
    }
  }

  Future<void> _createPeerConnection() async {
    try {
      final config = {
        'iceServers': [
          {'url': 'stun:stun.l.google.com:19302'}
        ]
      };

      _peerConnection = await createPeerConnection(config);
      print('PeerConnection created: $_peerConnection');

      final stream = await getLocalStream();

      if (_isDisposed) {
        stream.getTracks().forEach((t) => t.stop());
        _peerConnection?.close();
        print('Notifier disposed during peer connection setup.');
        return;
      }

      for (final track in stream.getTracks()) {
        await _peerConnection?.addTrack(track, stream);
        print('Added track: $track');
      }

      _peerConnection?.onIceCandidate = (candidate) {
        print('New ICE candidate: ${candidate.toMap()}');
        ref.read(signalingProvider.notifier).sendMessage(jsonEncode({
          'type':'call',
          'payload':{
          'type': 'candidate',
          'to': callerId,
          'candidate': {
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,}
          },
        }));
      };
    } catch (e, st) {
      print('Error in _createPeerConnection: $e\n$st');
      rethrow;
    }
  }

  Future<void> startCall(String id) async {
    callerId =id;
    print('inside call _isDisposed=$_isDisposed');

    try {
      await _createPeerConnection();
      if (_isDisposed) return;

      final offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);

      ref.read(signalingProvider.notifier).sendMessage(jsonEncode({
        'type':'call',
        'payload':{
        
        'type': 'offer',
        'to': id,
        'sdp': offer.sdp,}
      }));

      print('Offer sent');
    } catch (e, st) {
      print('Error in startCall: $e\n$st');
    }
  }

  Future<void> handleRemoteOffer(String sdp, String from) async {
    try {
      await _createPeerConnection();
      if (_isDisposed) return;

      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(sdp, 'offer'),
      );
      if (_isDisposed) return;

      final answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);

      if (_isDisposed) return;

      ref.read(signalingProvider.notifier).sendMessage(jsonEncode({
        'type':'call',
        'payload':{
        'type': 'answer',
        'to':from,        
        'sdp': answer.sdp,}
      }));
    } catch (e, st) {
      print('Error in handleRemoteOffer: $e\n$st');
    }
  }

  Future<void> handleRemoteAnswer(String sdp) async {
    try {
      if (_peerConnection == null) return;
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(sdp, 'answer'),
      );
    } catch (e, st) {
      print('Error in handleRemoteAnswer: $e\n$st');
    }
  }

  Future<void> handleRemoteCandidate(Map<String, dynamic> candidateMap) async {
    try {
      if (_peerConnection == null) return;

      final candidate = RTCIceCandidate(
        candidateMap['candidate'],
        candidateMap['sdpMid'],
        candidateMap['sdpMLineIndex'],
      );
      await _peerConnection!.addCandidate(candidate);
    } catch (e, st) {
      print('Error in handleRemoteCandidate: $e\n$st');
    }
  }

  void _disposeResources() {
    _localStream?.getTracks().forEach((track) => track.stop());
    _peerConnection?.close();
    _peerConnection = null;
    _localStream = null;
    print('Disposed all resources');
  }

  Future<void> switchCamera() async {
    try {
      final videoTrack = _localStream?.getVideoTracks().first;
      if (videoTrack != null) {
        await Helper.switchCamera(videoTrack);
      }
    } catch (e) {
      print('Error switching camera: $e');
    }
  }

  void toggleMute(bool isEnabled) {
    _localStream?.getAudioTracks().forEach((track) {
      track.enabled = isEnabled;
    });
    
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
          pageBuilder: (context, _, __) {
            return Align(
              alignment: Alignment.topCenter,
              child: IncomingCallPanelWidget(profile: profile!),
            );
          },
          transitionBuilder: (context, animation, _, child) {
            final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -1), // Start above
                end: Offset.zero,
              ).animate(curved),
              child: child,
            );
          },
        );
      }
      break;
  }
}
}