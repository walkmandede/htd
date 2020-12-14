// import 'dart:async';
// import 'dart:io';
// import 'package:overlay_support/overlay_support.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:notifications/notifications.dart';
//
// class PushNotificationService {
//   final FirebaseMessaging _fcm;
//
//   PushNotificationService(this._fcm);
//
//   Future initialise() async {
//     String token = await _fcm.getToken();
//     print("FirebaseMessaging token: $token");
//
//     _fcm.configure(
//       onMessage: (Map<String, dynamic> message) async {
//         var notification;
//         print("onMessage: $message");
//         if (Platform.isAndroid) {
//            notification = PushNotificationMessage(
//             title: message['notification']['title'],
//             body: message['notification']['body'],
//           );
//         }
//         showSimpleNotification(
//           Container(child: Text(notification.body)),
//           position: NotificationPosition.top,
//         );
//         },
//       onLaunch: (Map<String, dynamic> message) async {
//         print("onLaunch: $message");
//       },
//       onResume: (Map<String, dynamic> message) async {
//         print("onResume: $message");
//       },
//     );
//   }
//
//
// }
//
//
// class PushNotificationMessage {
//   final String title;
//   final String body;
//   PushNotificationMessage({
//     this.title,this.body,
//   });
// }
//
// Future<void> initPlatformState() async {
//   startListening();
// }
//
// void onData(NotificationEvent event) {
//   print(event);
//   showSimpleNotification(
//     Container(child: Text(event.toString())),
//     position: NotificationPosition.top,
//   );
// }
//
// Notifications _notifications;
// StreamSubscription<NotificationEvent> _subscription;
// List<NotificationEvent> _log = [];
//
// void startListening() {
//   _notifications = new Notifications();
//   try {
//     _subscription = _notifications.notificationStream.listen(onData);
//     print('gg');
//   } on NotificationException catch (exception) {
//     print(exception);
//   }
// }
//
// void stopListening() {
//   _subscription.cancel();
// }