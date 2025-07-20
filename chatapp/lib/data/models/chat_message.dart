enum MessageType {
  text,
  image,
  audio,
  file,
  pdf,
}

class ChatMessage {
  final String? chatId;   // Chat thread ID
  final String from;      // Sender ID
  final String? to;       // Recipient ID (null for group messages)
  final String message;   // Text content, file URL, etc.
  final MessageType type; // Message type
  final DateTime time;    // Timestamp
  final bool marked;      // Seen/pinned flag

  ChatMessage({
    this.chatId,
    required this.from,
    this.to,
    required this.message,
    required this.type,
    required this.time,
    this.marked = false,
  });

  /// ✅ Factory: Create from JSON
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      chatId: json['chatId'] ?? json['chat_id'],
      from: json['from'] ?? json['from_id'],
      to: json.containsKey('to')
          ? json['to'] as String?
          : json['to_id'] as String?,
      message: json['message'] as String,
      type: messageTypeFromString(json['type'] as String),
      time: DateTime.parse(json['time'] ?? json['time_sent']),
      marked: json['marked'] as bool? ?? false,
    );
  }

  /// ✅ Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'from': from,
      'to': to,
      'message': message,
      'type': messageTypeToString(type),
      'time': time.toIso8601String(),
      'marked': marked,
    };
  }

  /// ✅ Convert type string -> enum
  static MessageType messageTypeFromString(String type) {
    return MessageType.values.firstWhere(
      (e) => e.name.toLowerCase() == type.toLowerCase(),
      orElse: () => MessageType.text,
    );
  }

  /// ✅ Convert enum -> string
  static String messageTypeToString(MessageType type) {
    return type.name; // uses Dart 2.15+ .name feature
  }

  /// ✅ Guess type from file extension
  static MessageType fileType(String? ext) {
    if (ext == null) return MessageType.file;

    final normalized = ext.toLowerCase();

    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(normalized)) {
      return MessageType.image;
    } else if (['mp3', 'wav', 'ogg', 'm4a'].contains(normalized)) {
      return MessageType.audio;
    } else if(['pdf',].contains(normalized)){
      return MessageType.pdf;

    }

    else {
      return MessageType.file;
    }
  }

  /// ✅ Immutable copyWith
  ChatMessage copyWith({
    String? chatId,
    String? from,
    String? to,
    String? message,
    MessageType? type,
    DateTime? time,
    bool? marked,
  }) {
    return ChatMessage(
      chatId: chatId ?? this.chatId,
      from: from ?? this.from,
      to: to ?? this.to,
      message: message ?? this.message,
      type: type ?? this.type,
      time: time ?? this.time,
      marked: marked ?? this.marked,
    );
  }
}
