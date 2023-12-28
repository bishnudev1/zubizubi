class User{
  String ?id;
  String? name;
  String? email;
  String? photoUrl;
  String? password;
  int? likes;
  int? shares;
  String? createdAt;
  // String? phone;
  // String? address;
  // String? role;
  // String? token;

  User({
    this.id,
    this.name,
    this.email,
    this.password,
    this.likes,
    this.shares,
    this.createdAt,
    this.photoUrl
    // this.phone,
    // this.address,
    // this.role,
    // this.token
  });

  factory User.fromMap(Map<String, dynamic> json){
    return User(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      likes: json['likes'],
      shares: json['shares'],
      createdAt: json['createdAt'],
      photoUrl: json['photo'],
      // phone: json['phone'],
      // address: json['address'],
      // role: json['role'],
      // token: json['token']
    );
  }

  Map<String, dynamic> toMap(){
    return {
      '_id': id,
      'name': name,
      'email': email,
      'password': password,
      'likes': likes,
      'shares': shares,
      'createdAt': createdAt,
      'photo': photoUrl,
      // 'phone': phone,
      // 'address': address,
      // 'role': role,
      // 'token': token
    };
  }
}