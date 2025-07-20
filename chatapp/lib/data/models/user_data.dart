import 'dart:convert';
import 'dart:typed_data';

class UserData {
  final String id;
  final String tagName;
  final Uint8List? imageBytes;
  final String username;

  const UserData({
    required this.id,
    this.imageBytes,
    required this.tagName,
    required this.username,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'],
      tagName: json['tagName'],
      username: json['username'],
      imageBytes: json['imageBytes'] != null
          ? base64Decode(json['imageBytes'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tagName': tagName,
      'username': username,
      'imageBytes': imageBytes != null ? base64Encode(imageBytes!) : null,
    };
  }
}

class UserProfileData extends UserData {
  final DateTime created;
  final String? bio;
  final String? email;
  final String? phoneNumber;
  final DateTime? lastSeen;
  final String? statusMessage;
  final bool isOnline;
  final List<String>? contacts; // just store user IDs
  final List<String>? blockedUsers; // just store user IDs

  const UserProfileData({
    required super.id,
    required super.username,
    required super.tagName,
    super.imageBytes,
    required this.created,
    this.bio,
    this.email,
    this.phoneNumber,
    this.lastSeen,
    this.statusMessage,
    this.isOnline = false,
    this.contacts,
    this.blockedUsers,
  });

 factory UserProfileData.fromJson(Map<String, dynamic> json) {
  return UserProfileData(
    id: json['id'] ?? '',
    username: json['username'] ?? '',
    tagName: json['tag_name'] ?? '',
    imageBytes: json['image_bytes'] != null
        ? base64Decode(json['image_bytes'] as String)
        : null,
    created: json['created'] != null
        ? DateTime.tryParse(json['created']) ?? DateTime.now()
        : DateTime.now(),
    bio: json['bio'],
    email: json['email'],
    phoneNumber: json['phone_number'],
    lastSeen: json['last_seen'] != null
        ? DateTime.tryParse(json['last_seen'])
        : null,
    statusMessage: json['status_message'],
    isOnline: json['is_online'] == true,
    contacts: json['contacts'] is List
    ? (json['contacts'] as List).map((e) => e.toString()).toList()
    : [],
blockedUsers: json['blocked_users'] is List
    ? (json['blocked_users'] as List).map((e) => e.toString()).toList()
    : [],);



}




  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'created': created.toIso8601String(),
      'bio': bio,
      'email': email,
      'phoneNumber': phoneNumber,
      'lastSeen': lastSeen?.toIso8601String(),
      'statusMessage': statusMessage,
      'isOnline': isOnline,
      'contacts': contacts,
      'blockedUsers': blockedUsers,
    };
  }
}

extension UserProfileDataCopyWith on UserProfileData {
  UserProfileData copyWith({
    String? id,
    String? tagName,
    Uint8List? imageBytes,
    String? username,
    DateTime? created,
    String? bio,
    String? email,
    String? phoneNumber,
    DateTime? lastSeen,
    String? statusMessage,
    bool? isOnline,
    List<String>? contacts,
    List<String>? blockedUsers,
  }) {
    return UserProfileData(
      id: id ?? this.id,
      tagName: tagName ?? this.tagName,
      imageBytes: imageBytes ?? this.imageBytes,
      username: username ?? this.username,
      created: created ?? this.created,
      bio: bio ?? this.bio,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      lastSeen: lastSeen ?? this.lastSeen,
      statusMessage: statusMessage ?? this.statusMessage,
      isOnline: isOnline ?? this.isOnline,
      contacts: contacts ?? this.contacts,
      blockedUsers: blockedUsers ?? this.blockedUsers,
    );
  }
}


