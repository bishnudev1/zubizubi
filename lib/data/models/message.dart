import 'package:hive_flutter/adapters.dart';

@HiveType(typeId: 1)
class Message extends HiveObject {
  @HiveField(0)
  String sender;

  @HiveField(1)
  String body;

  @HiveField(2)
  String sentAt;

  Message({
    required this.sender,
    required this.body,
    required this.sentAt,
  });

  factory Message.fromMap(Map<String, dynamic> json) {
    return Message(
      sender: json['sender'],
      body: json['body'],
      sentAt: json['sentAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sender': sender,
      'body': body,
      'sentAt': sentAt,
    };
  }
}
