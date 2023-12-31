import 'package:hive/hive.dart';
part 'user.g.dart';

@HiveType(typeId: 1)
class User extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String email;

  @HiveField(3)
  String photoUrl;

  @HiveField(4)
  List<dynamic> followers;

  @HiveField(5)
  List<dynamic> shares;

  @HiveField(6)
  String createdAt;

  User(
      {required this.id,
      required this.name,
      required this.email,
      required this.followers,
      required this.shares,
      required this.createdAt,
      required this.photoUrl});

  factory User.fromMap(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      followers: json['followers'],
      shares: json['shares'],
      createdAt: json['createdAt'],
      photoUrl: json['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'followers': followers,
      'shares': shares,
      'createdAt': createdAt,
      'photoUrl': photoUrl,
    };
  }
}
