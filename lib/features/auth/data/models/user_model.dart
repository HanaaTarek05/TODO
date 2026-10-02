class UserModel {
  final int? id;
  final String username;
  final String? image;

  UserModel({
    this.id,
    required this.username,
    this.image,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'] ?? json['name'] ?? '',
      image: json['image'] ?? json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'username': username,
      if (image != null) 'image': image,
    };
  }
}
