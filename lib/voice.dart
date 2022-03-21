// import 'package:flutter/material.dart';
// import 'dart:async';
//
// import 'package:agora_rtc_engine/rtc_engine.dart';
// import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
// import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
// import 'package:permission_handler/permission_handler.dart';
//
//
//
// // import './src/index.dart';
//
// void main() => runApp(MyApp());
//
// // class MyApp extends StatelessWidget {
// //   // This widget is the root of your application.
// //   @override
// //   model build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'Flutter Demo',
// //       theme: ThemeData(
// //         primarySwatch: Colors.blue,
// //       ),
// //       home: IndexPage(),
// //     );
// //   }
// // }
//
// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }
//
// // App state class
// class _MyAppState extends State<MyApp> {
//   bool _joined = false;
//   int _remoteUid = 0;
//   bool _switch = false;
//
//
//   void dispose() {
//     // clear users
//     _users.clear();
//     // destroy sdk
//     _engine.leaveChannel();
//     _engine.destroy();
//     super.dispose();
//   }
//
//
//   @override
//   void initState() {
//     super.initState();
//     initPlatformState();
//   }
//
//   Future<void> initialize() async {
//     if (APP_ID.isEmpty) {
//       setState(() {
//         _infoStrings.add(
//           'APP_ID missing, please provide your APP_ID in settings.dart',
//         );
//         _infoStrings.add('Agora Engine is not starting');
//       });
//       return;
//     }
//
//     await _initAgoraRtcEngine();
//     _addAgoraEventHandlers();
//     // await _engine.enableWebSdkInteroperability(true);
//     // VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
//     // configuration.dimensions = VideoDimensions(width: 1920, height: 1080);
//     // await _engine.setVideoEncoderConfiguration(configuration);
//     // await getToken();
//     await _engine.joinChannel(Token, widget.channelName!, null, 0);
//   }
//
//   // Init the app
//   Future<void> initPlatformState() async {
//     // Get microphone permission
//     await [Permission.microphone].request();
//
//     // Create RTC client instance
//     RtcEngineContext context = RtcEngineContext(APP_ID);
//     var engine = await RtcEngine.createWithContext(context);
//     // Define event handling logic
//     engine.setEventHandler(RtcEngineEventHandler(
//         joinChannelSuccess: (String channel, int uid, int elapsed) {
//           print('joinChannelSuccess ${channel} ${uid}');
//           setState(() {
//             _joined = true;
//           });
//         },userJoined: (int uid, int elapsed) {
//       print('userJoined ${uid}');
//       setState(() {
//         _remoteUid = uid;
//       });
//     }, userOffline: (int uid, UserOfflineReason reason) {
//       print('userOffline ${uid}');
//       setState(() {
//         _remoteUid = 0;
//       });
//     }));
//     // Join channel with channel name as
//     await engine.joinChannel(Token, channelName, null, 0);
//   }
//
//   // Build chat UI
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Agora Audio quickstart',
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Agora Audio quickstart'),
//         ),
//         body: Center(
//           child: Text('Please chat!'),
//         ),
//       ),
//     );
//   }
//
//   void _onToggleMute() {
//     setState(() {
//       muted = !muted;
//     });
//     _engine.muteLocalAudioStream(muted);
//   }
//
//   Widget _panel() {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 48),
//       alignment: Alignment.bottomCenter,
//       child: FractionallySizedBox(
//         heightFactor: 0.5,
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 48),
//           child: ListView.builder(
//             reverse: true,
//             itemCount: _infoStrings.length,
//             itemBuilder: (BuildContext context, int index) {
//               if (_infoStrings.isEmpty) {
//                 return Text(
//                     "null"); // return type can't be null, a widget was required
//               }
//               return Padding(
//                 padding: const EdgeInsets.symmetric(
//                   vertical: 3,
//                   horizontal: 10,
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Flexible(
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           vertical: 2,
//                           horizontal: 5,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.yellowAccent,
//                           borderRadius: BorderRadius.circular(5),
//                         ),
//                         child: Text(
//                           _infoStrings[index],
//                           style: TextStyle(color: Colors.blueGrey),
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
//
// }