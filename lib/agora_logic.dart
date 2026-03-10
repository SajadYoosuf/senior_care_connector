import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class VideoCallScreen extends StatefulWidget {
  final String channelName;
  final String? token;
  final bool isAudioOnly;

  const VideoCallScreen({
    super.key,
    required this.channelName,
    this.token,
    this.isAudioOnly = false,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    // retrieve permissions
    if (widget.isAudioOnly) {
      await [Permission.microphone].request();
    } else {
      await [Permission.microphone, Permission.camera].request();
    }

    // create the engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(
      RtcEngineContext(
        appId: dotenv.env['AGORA_APP_ID'] ?? '',
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("local user ${connection.localUid} joined");
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("remote user $remoteUid joined");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline:
            (
              RtcConnection connection,
              int remoteUid,
              UserOfflineReasonType reason,
            ) {
              debugPrint("remote user $remoteUid left channel");
              setState(() {
                _remoteUid = null;
              });
            },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint(
            '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token',
          );
        },
      ),
    );

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    if (widget.isAudioOnly) {
      await _engine.disableVideo();
    } else {
      await _engine.enableVideo();
      await _engine.startPreview();
    }

    await _engine.joinChannel(
      token: widget.token ?? '',
      channelId: widget.channelName,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _dispose();
  }

  Future<void> _dispose() async {
    await _engine.leaveChannel();
    await _engine.release();
  }

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isAudioOnly ? 'Voice Call' : 'Video Call'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.call_end, color: Colors.red),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: widget.isAudioOnly ? _audioOnlyRemote() : _remoteVideo(),
          ),
          if (!widget.isAudioOnly)
            Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 100,
                height: 150,
                child: Center(
                  child: _localUserJoined
                      ? AgoraVideoView(
                          controller: VideoViewController(
                            rtcEngine: _engine,
                            canvas: const VideoCanvas(uid: 0),
                          ),
                        )
                      : const CircularProgressIndicator(),
                ),
              ),
            ),
          if (widget.isAudioOnly)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FloatingActionButton(
                      onPressed: () => Navigator.pop(context),
                      backgroundColor: Colors.red,
                      child: const Icon(Icons.call_end, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _audioOnlyRemote() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircleAvatar(
          radius: 60,
          backgroundColor: Colors.blueGrey,
          child: Icon(Icons.person, size: 60, color: Colors.white),
        ),
        const SizedBox(height: 24),
        Text(
          _remoteUid != null ? 'Connected' : 'Calling...',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ],
    );
  }

  // Display remote user's video
  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: widget.channelName),
        ),
      );
    } else {
      return const Text(
        'Please wait for remote user to join',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white),
      );
    }
  }
}
