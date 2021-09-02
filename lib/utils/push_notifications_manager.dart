// import 'dart:convert';
// import 'dart:io';
//
// import 'package:firebase_database/firebase_database.dart';
// import 'package:http/http.dart' as http;
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class PushNotificationsManager {
//
//   PushNotificationsManager._();
//
//   factory PushNotificationsManager() => _instance;
//
//   static final PushNotificationsManager _instance = PushNotificationsManager._();
//
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
//   bool _initialized = false;
//   static const String POST_ACTION=" post a new content";
//   static const String POST_REASON=" for you";
//   static const String POST_TYPE="post";
//   static const String LIKE_ACTION=" liked";
//   static const String LIKE_REASON=" your post";
//   static const String LIKE_TYPE="like";
//   static const String COMMENT_ACTION=" commented";
//   static const String COMMENT_REASON=" your post";
//   static const String COMMENT_TYPE="comment";
//   static const String GIVE_ACTION=" give you";
//   static const String GIVE_REASON=" for your post";
//   static const String GIVE_TYPE="tip";
//   static const String FOLLOW_ACTION=" started follow";
//   static const String FOLLOW_REASON=" your profile";
//   static const String FOLLOW_TYPE="follow";
//   static const String MESSAGE_ACTION="message";
//   static const String PRIVATE_TOPIC_SUFFIX="_accountInstances";
//   static const String CHANNEL_TOPIC_SUFFIX="_channel";
//
//   Future<void> init() async {
//     if (!_initialized) {
//       // For iOS request permission first.
//       if(Platform.isIOS)
//         _firebaseMessaging.requestNotificationPermissions(
//             const IosNotificationSettings(
//                 sound: true, badge: true, alert: true, provisional: true));
//       _firebaseMessaging.configure();
//
//       SharedPreferences sharedPreferences=await SharedPreferences.getInstance();
//       String _username=sharedPreferences.getString(USER_USERNAME_KEY);
//       _firebaseMessaging.subscribeToTopic(_username+PRIVATE_TOPIC_SUFFIX);
//
//       _initialized = true;
//     }
//   }
//
//   Future<void> unsubscribe() async{
//     if (!_initialized) {
//       SharedPreferences sharedPreferences=await SharedPreferences.getInstance();
//       String _username=sharedPreferences.getString(USER_USERNAME_KEY);
//       _firebaseMessaging.unsubscribeFromTopic(_username+PRIVATE_TOPIC_SUFFIX);
//       _initialized=false;
//     }
//   }
//
//   static Future<void> push(dynamic notification,String action,{ String pushTo=""}) async{
//     SharedPreferences sharedPreferences=await SharedPreferences.getInstance();
//     String _username=sharedPreferences.getString(USER_USERNAME_KEY);
//     String _name=sharedPreferences.getString(USER_NAME_KEY);
//     String _photo=sharedPreferences.getString(USER_IMAGE_KEY);
//
//     String topic='';
//     String reason='';
//     String type='';
//     switch(action){
//       case MESSAGE_ACTION:
//         topic=pushTo+PRIVATE_TOPIC_SUFFIX;
//         break;
//       case LIKE_ACTION:
//         topic=pushTo+PRIVATE_TOPIC_SUFFIX;
//         reason=LIKE_REASON;
//         type=LIKE_TYPE;
//         break;
//       case POST_ACTION:
//         topic=_username+CHANNEL_TOPIC_SUFFIX;
//         reason=POST_ACTION;
//         type=POST_TYPE;
//         break;
//       case COMMENT_ACTION:
//         topic=pushTo+PRIVATE_TOPIC_SUFFIX;
//         reason=COMMENT_REASON;
//         type=COMMENT_TYPE;
//         break;
//       case GIVE_ACTION:
//         topic=pushTo+PRIVATE_TOPIC_SUFFIX;
//         reason=GIVE_REASON;
//         type=GIVE_TYPE;
//         break;
//       case FOLLOW_ACTION:
//         topic=pushTo+PRIVATE_TOPIC_SUFFIX;
//         FirebaseMessaging().subscribeToTopic(topic);
//         reason=FOLLOW_ACTION;
//         type=FOLLOW_TYPE;
//         break;
//     }
//
//     await http.post(
//       'https://fcm.googleapis.com/fcm/send',
//       headers: <String, String>{
//         'Content-Type': 'application/json',
//         'Authorization': 'key=${Keys.android_key}',
//       },
//       body: jsonEncode(
//         <String, dynamic>{
//           'notification': notification,
//           'priority': 'high',
//           'data': <String, dynamic>{
//             'click_action': 'FLUTTER_NOTIFICATION_CLICK',
//             'id': '1',
//             'status': 'done'
//           },
//           'to': '/topics/$topic',
//         },
//       ),
//     );
//
//     await http.post(
//       'https://fcm.googleapis.com/fcm/send',
//       headers: <String, String>{
//         'Content-Type': 'application/json',
//         'Authorization': 'key=${Keys.web_key}',
//       },
//       body: jsonEncode(
//         <String, dynamic>{
//           'notification': notification,
//           'priority': 'high',
//           'data': <String, dynamic>{
//             'click_action': 'FLUTTER_NOTIFICATION_CLICK',
//             'id': '1',
//             'status': 'done'
//           },
//           'to': '/topics/$topic',
//         },
//       ),
//     );
//
//     if(action!=MESSAGE_ACTION)
//       FirebaseDatabase.instance
//           .reference()
//           .child("users/" +pushTo+"/notifications/")
//           .push()
//           .set({
//             "image":_photo,
//             "reason":reason,
//             "name":_name,
//             "type":type,
//             "action":action,
//             "timestamp":new DateTime.now().millisecondsSinceEpoch
//           });
//   }
// }
