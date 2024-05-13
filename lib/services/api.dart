import 'dart:convert';
import 'dart:io';

import 'package:chattingapp/models/message_model.dart';
import 'package:chattingapp/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';

class API{
  //for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;
  //for accepting cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  //for accepting firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;
  //to return current user
  static User get user => auth.currentUser!;
  // for accessing firebase messaging (Push Notification)
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  // for getting firebase messaging token
  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();

    await fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
      }
    });
  }
  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        "message": {
          "token": chatUser.pushToken,
          "notification": {
            "title": me.name, //our name should be send
            "body": msg,
          },
        }
      };

      // Firebase Project > Project Settings > General Tab > Project ID
     // const projectID = 'we-chat-75f13';

      // get firebase admin token
     // final bearerToken = await NotificationAccessToken.getToken;

      //print('bearerToken: $bearerToken');

      // handle null token
      //if (bearerToken == null) return;
//AAAAbeQKalg:APA91bGq9deOFGrANuyCSAgvIcTKX0pjoXfD4o6uPQ67QhsY3tZ54pzNzgzYuNmKq_VV5OhM4v7mTG8g2VzZTQZt9P7lrnIxXJKQARYFCMqU7-WljPA30txGttJVQYcyU_MMbDlGEy-E
      var res = await post(
        Uri.parse(
            'https://fcm.googleapis.com/send'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'key=AAAAbeQKalg:APA91bGq9deOFGrANuyCSAgvIcTKX0pjoXfD4o6uPQ67QhsY3tZ54pzNzgzYuNmKq_VV5OhM4v7mTG8g2VzZTQZt9P7lrnIxXJKQARYFCMqU7-WljPA30txGttJVQYcyU_MMbDlGEy-E'
        },
        body: jsonEncode(body),
      );

      print('Response status: ${res.statusCode}');
      print('Response body: ${res.body}');
    } catch (e) {
      print('\nsendPushNotificationE: $e');
    }
  }

  //for checking if user exists or not
  static Future<bool> userExists()async{
    return (await firestore.collection('users')
        .doc(auth.currentUser?.uid)
        .get())
        .exists;
  }
  //store self
  static late ChatUser me;
  //getting current user info
  static Future<void> getSelfInfo() async{
    await (firestore.collection('users').doc(user.uid).get()).then((value) async {
       if(value.exists){
         me = ChatUser.fromJson(value.data()!);
         await getFirebaseMessagingToken();
       }
       else{
         await createUser().then((value) {getSelfInfo();});
       }
    });
  }
  // for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }
  // update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }
  //for creating a new user
  static Future<void> createUser()async{
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatUser(id: user.uid,
        name: user.displayName.toString(),
        email: user.email!,
      image: user.photoURL.toString(),
      about: 'Demo',
      createdAt: time,
      isOnline: false,
      lastActive: '',
      pushToken: '',
    );

    return await firestore.collection('users').doc(user.uid).set(chatUser.toJson());
  }

  ///getting all users from firestore database
  static Stream<QuerySnapshot<Map<String,dynamic>>> getAllUsers(){
    return firestore.collection('users').where('id',isNotEqualTo: user.uid).snapshots();
  }

  ///getting conversation id
  static String getConversationId(String id) => user.uid.hashCode <=id.hashCode
      ?'${user.uid}_$id'
      :'${id}_${user.uid}';

  ///get all message of specific conversation from firestore database
  static Stream<QuerySnapshot<Map<String,dynamic>>> getAllMessages(ChatUser user){
    return firestore.collection('chats/${getConversationId(user.id)}/messages')
        .orderBy('sent',descending: true)
        .snapshots();
  }
  // for adding an user to my user when first message is send
  static Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }
  ///for sending message
  static Future<void> sendMessage(ChatUser chatUser,String msg,Type type) async{
   ///message time plus user id
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    ///message to send
    Message message = Message(toId: chatUser.id, msg: msg, read: '', type: type,
        fromId: user.uid, sent: time);
    final ref = firestore.collection('chats/${getConversationId(chatUser.id)}/messages');
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(chatUser, type == Type.text ? msg : 'image'));
  }
  //update read status of message [in sent we are storing time as id]
  static Future<void> updateMessageReadStatus(Message msg)async{
    await firestore.collection('chats/${getConversationId(msg.fromId)}/messages')
    .doc(msg.sent)
        .update({'read' : DateTime.now().millisecondsSinceEpoch.toString()});
  }
  //get last msg
  static Stream<QuerySnapshot<Map<String,dynamic>>> getLastMessages(ChatUser user){
    return firestore.collection('chats/${getConversationId(user.id)}/messages')
        .orderBy('sent',descending: true)
        .limit(1)
        .snapshots();
  }
  //send chat image
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = storage.ref().child(
        'images/${getConversationId(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
    });

    //updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  //delete message
  static Future<void> deleteMessage(Message message) async {
    await firestore
        .collection('chats/${getConversationId(message.toId)}/messages/')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  //update message
  static Future<void> updateMessage(Message message, String updatedMsg) async {
    await firestore
        .collection('chats/${getConversationId(message.toId)}/messages/')
        .doc(message.sent)
        .update({'msg': updatedMsg});
  }
}