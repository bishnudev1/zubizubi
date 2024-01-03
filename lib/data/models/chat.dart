import 'package:hive_flutter/adapters.dart';

@HiveType(typeId: 1)
class Chat extends HiveObject {
  @HiveField(0)
  String userName;

  @HiveField(1)
  String userImage;

  @HiveField(2)
  String lastMessage;

  @HiveField(3)
  String lastMessageTime;

  Chat(
      {required this.userName,
      required this.userImage,
      required this.lastMessage,
      required this.lastMessageTime});

  factory Chat.fromMap(Map<String, dynamic> json) {
    return Chat(
      userName: json['userName'],
      userImage: json['userImage'],
      lastMessage: json['lastMessage'],
      lastMessageTime: json['lastMessageTime'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'userImage': userImage,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
    };
  }
}
