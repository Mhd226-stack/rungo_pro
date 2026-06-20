import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_token_service/agora_token_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_driver/functions/functions.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../common/responsive.dart';
import '../../styles/styles.dart';
import '../../translation/translation.dart';
import '../../widgets/widgets.dart';
import '../onTripPage/map_page.dart';

const _appId = '06b417f44ed0470e9249534d3a603920';
const _appCertificate = '67b6ab170b4b4d7cb78e48f94991f81d';

class CallScreen extends StatefulWidget {
  const CallScreen();
  @override
  State<CallScreen> createState() => _CallScreen();
}

bool isCallActivated = false;
late RtcEngine rtcEngin;

class _CallScreen extends State<CallScreen> {
  int? _remoteUid;
  bool isChannelCreated = false;

  bool _isMuted = false;
  bool _isSpeakerOn = false;
  @override
  void initState() {
    super.initState();
    FirebaseDatabase.instance
        .ref('requests/${driverReq['id']}')
        .onValue
        .listen((event) async {
      if (!mounted) return; // ← correction 1

      Map rideRequest = event.snapshot.value as Map;
      String currentCallingStatus = rideRequest[callingStatus];
      if (currentCallingStatus == callingStatusDeclined) {
        await rtcEngin.leaveChannel();
        await rtcEngin.release();
        isCallActivated = false;

        if (!mounted) return; // ← correction 2 (après les await)
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) => Maps()), (route) => false);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initializeAgora();
  }

  initializeAgora() async {
    await [
      Permission.microphone,
      Permission.audio,
    ].request();

    rtcEngin = createAgoraRtcEngine();
    await rtcEngin.initialize(const RtcEngineContext(
        appId: _appId,
        channelProfile: ChannelProfileType.channelProfileCommunication));

    rtcEngin.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) async {
          await FirebaseDatabase.instance
              .ref('requests/${driverReq['id']}')
              .update({
            callingStatus: callingStatusIncomming,
            shouldShowIncommingCall: true,
            'driver': true
          });
          setState(() {
            isChannelCreated = true;
          });
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          setState(() {
            _remoteUid = remoteUid;
            isCallActivated = true;
          });
        },
      ),
    );

    if (!isCallActivated) {
      await rtcEngin.joinChannel(
        token: getToken,
        channelId: driverReq['id'],
        uid: 0,
        options: const ChannelMediaOptions(
            channelProfile: ChannelProfileType.channelProfileCommunication,
            clientRoleType: ClientRoleType.clientRoleBroadcaster),
      );
    }

    await rtcEngin.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await rtcEngin.enableAudio();
    await rtcEngin.enableLocalAudio(true);
  }

  String get getToken {
    const expirationTimeInSeconds = 3600;
    final currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final privilegeExpiredTs =
        currentTimestamp + expirationTimeInSeconds + 3600;
    String token = RtcTokenBuilder.build(
      appId: _appId,
      appCertificate: _appCertificate,
      channelName: driverReq['id'],
      uid: 0.toString(),
      role: RtcRole.publisher,
      expireTimestamp: privilegeExpiredTs,
    );
    return token;
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;
    return Scaffold(
        backgroundColor: page,
        appBar: AppBar(
          backgroundColor: page,
          title: Text(
            languages[choosenLanguage]['text_call_screen'],
            style: GoogleFonts.inter(
              color: textColor,
            ),
          ),
          leading: GestureDetector(
              onTap: () async {
                // Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back,
                color: Colors.transparent,
              )),
        ),
        body: WillPopScope(
          onWillPop: () {
            return Future(
              () => false,
            );
          },
          child: SizedBox(
            width: screenWidth,
            height: screenHeight,
            child: Stack(alignment: Alignment.topCenter, children: [
              Positioned(
                top: 70,
                child: Text(
                  _remoteUid == null
                      ? languages[choosenLanguage]['text_calling']
                      : languages[choosenLanguage]['text_calling'],
                  style: TextStyle(
                      fontSize: 16,
                      color: textColor,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                right: Responsive.width(15, context),
                bottom: Responsive.height(8, context),
                child: GestureDetector(
                  onTap: () async {
                    if (_isMuted) {
                      await rtcEngin.enableLocalAudio(true);
                    } else {
                      await rtcEngin.enableLocalAudio(false);
                    }
                    _isMuted = !_isMuted;
                    setState(() {});
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                        color: _isMuted ? darkModeSecContainer : buttonColor,
                        shape: BoxShape.circle),
                    child: Icon(
                      _isMuted ? Icons.mic_off : Icons.mic,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: Responsive.width(15, context),
                bottom: Responsive.height(8, context),
                child: GestureDetector(
                  onTap: () async {
                    if (_isSpeakerOn) {
                      await rtcEngin.setEnableSpeakerphone(false);
                    } else {
                      await rtcEngin.setEnableSpeakerphone(true);
                    }
                    _isSpeakerOn = !_isSpeakerOn;
                    setState(() {});
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                        color:
                            _isSpeakerOn ? buttonColor : darkModeSecContainer,
                        shape: BoxShape.circle),
                    child: Icon(
                      _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
              Positioned(
                  top: Responsive.height(25, context),
                  child: Column(
                    children: [
                      Container(
                        width: Responsive.width(25, context),
                        height: Responsive.width(25, context),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                fit: BoxFit.fill,
                                image: NetworkImage(driverReq['userDetail']
                                    ['data']['profile_picture']))),
                      ),
                      SizedBox(
                        height: Responsive.height(3, context),
                      ),
                      MyText(
                          text: driverReq['userDetail']['data']['name'],
                          fontweight: FontWeight.w800,
                          size: screenWidth * twentythree)
                    ],
                  )),
              Positioned(
                bottom: Responsive.height(8, context),
                child: GestureDetector(
                  onTap: () async {
                    await rtcEngin.leaveChannel();
                    await rtcEngin.release();
                    isCallActivated = false;
                    await FirebaseDatabase.instance
                        .ref('requests/${driverReq['id']}')
                        .update({callingStatus: callingStatusDeclined});
                    // Navigator.pop(context);
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                    child: const Icon(
                      Icons.call_end,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              )
            ]),
          ),
        ));
  }
}
