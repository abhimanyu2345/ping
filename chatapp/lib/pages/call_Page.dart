import 'package:chatapp/data/models/webrtc_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class WebRTCCallPage extends ConsumerStatefulWidget {
  const WebRTCCallPage({super.key,  required this.callerId});
  final  String callerId;

  @override
  ConsumerState<WebRTCCallPage> createState() => _WebRTCCallPageState();
}

class _WebRTCCallPageState extends ConsumerState<WebRTCCallPage> {
  late RTCVideoRenderer _localRenderer;
  late RTCVideoRenderer _remoteRenderer;
  
  bool _isAudioEnabled = false;

  @override
  void initState() {
    super.initState();
    _localRenderer = RTCVideoRenderer();
    _remoteRenderer = RTCVideoRenderer();
    _initRenderers();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    _remoteRenderer.srcObject= ref.watch(webRTCNotifierProvider).remoteStream;
    await _startCamera();
    ref.listen<WebRTCState>(webRTCNotifierProvider, (prev, next) {
    if (next.remoteStream != null && next.remoteStream != prev?.remoteStream) {
      _remoteRenderer.srcObject = next.remoteStream;
    }
  });
  }

  Future<void> _startCamera() async {
    try {
      final webRTC = ref.read(webRTCNotifierProvider.notifier);
      final stream = await webRTC.getLocalStream();
      if (mounted) {
        _localRenderer.srcObject = stream;
        setState(() {});
      }
    } catch (e) {
      debugPrint('getUserMedia error: $e');
    }
  }

  void _handlePop() {
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    // ✅ STOP THE TRACKS FIRST
  _localRenderer.srcObject?.getTracks().forEach((t) => t.stop());

  // ✅ THEN clear the source
  _localRenderer.srcObject = null;

  // ✅ Dispose the renderer
  _localRenderer.dispose();

  _remoteRenderer.dispose();

  // ✅ Invalidate the Notifier so it can close PeerConnection too
  ref.invalidate(webRTCNotifierProvider);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    final webRTC = ref.watch(webRTCNotifierProvider.notifier);

    

    return PopScope(
      
      onPopInvoked: (didPop) {
        if(didPop){
          dispose();
          
        }

        if (!didPop) {
          _handlePop();
        }
      },
      child: Scaffold(
        body: 

        
        
        Stack(
          children:[ 
            (_remoteRenderer.srcObject!=null)?
            RTCVideoView(_remoteRenderer):
            Center(child: Text('no video yey'),),
            
            
            
            
            
            
            
            Positioned(
              bottom: 16,
      right: 16,
      width: 120,
      height: 160,
               
            child: _localRenderer.textureId != null
                ? RTCVideoView(_localRenderer,)
                : const CircularProgressIndicator(),
          ),]
        ),











        floatingActionButton: IconButton(
          onPressed: () {
            showModalBottomSheet(
              backgroundColor: Colors.transparent,
              context: context,
              builder: (context) {
                return StatefulBuilder(builder: (context, modalSetState) {
                  return Container(
                    height: 100,
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          onPressed: () {
                            _handlePop();
                          },
                          icon: const Icon(Icons.call_end),
                          iconSize: 35,
                          color: Colors.redAccent,
                        ),
                        IconButton(
                          onPressed: () {
                            webRTC.toggleMute(!_isAudioEnabled);
                            setState(() {
                              _isAudioEnabled = !_isAudioEnabled;
                            });
                            modalSetState(() {});
                          },
                          icon: _isAudioEnabled
                              ? const Icon(Icons.volume_up)
                              : const Icon(Icons.volume_off_outlined),
                          iconSize: 35,
                          color: _isAudioEnabled
                              ? Colors.blueAccent
                              : Colors.redAccent,
                        ),
                        IconButton(
                          onPressed: () {
                            webRTC.switchCamera();
                          },
                          icon: const Icon(Icons.cameraswitch),
                          iconSize: 35,
                          color: Colors.blueAccent,
                        ),
                      ],
                    ),
                  );
                });
              },
            );
          },
          icon: const Icon(Icons.more_horiz_outlined, size: 32),
        ),
      ),
    );
  }
}
