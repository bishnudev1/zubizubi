import 'package:hive/hive.dart';
import 'package:stacked/stacked.dart';
import 'package:zubizubi/data/models/chat.dart';
import 'package:zubizubi/data/models/message.dart';
import 'package:zubizubi/data/models/user.dart';

class ChatsViewModel extends ReactiveViewModel {
  User? _user;

  User? get user => _user;
  List<Chat> _chatRooms = [
    Chat(
        userName: "John Doe",
        userImage:
            "https://evolve2023.in/wp-content/uploads/2014/10/speaker-3.jpg",
        lastMessage: "Hello",
        lastMessageTime: "10:00 AM")
  ];

  List get chatRooms => _chatRooms;

  parseCurrentReceiver(Map<String, dynamic> receiver) {}

  List<Message> _roomMessages = [];

  List get roomMessages => _roomMessages;

  getUser() async {
    var userBox = Hive.box<User>('userBox');

    if (userBox.isEmpty) {
      _user = User(
        id: "12345",
        name: "Guest",
        email: "guest@email.com",
        followers: [],
        shares: [],
        guest: true,
        createdAt: "12345678",
        photoUrl:
            "https://img.freepik.com/premium-vector/user-profile-icon-flat-style-member-avatar-vector-illustration-isolated-background-human-permission-sign-business-concept_157943-15752.jpg",
        bio: "I am a guest user",
      );
      notifyListeners();
    } else {
      _user = userBox.getAt(0);

      notifyListeners();
    }
  }
}
