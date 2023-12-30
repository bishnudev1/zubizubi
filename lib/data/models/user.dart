class User{
  String ?id;
  String? name;
  String? email;
  String? photoUrl;
  int? followers;
  int? shares;
  String? createdAt;

  User({
    this.id,
    this.name,
    this.email,
    this.followers,
    this.shares,
    this.createdAt,
    this.photoUrl
  });

  factory User.fromMap(Map<String, dynamic> json){
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

  Map<String, dynamic> toMap(){
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