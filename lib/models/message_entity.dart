class MessageEntity {
  final String id;
  final String text;
  final bool isMe;
  final DateTime time;
  final String senderName;
  final String senderAvatar;

  const MessageEntity({
    required this.id,
    required this.text,
    required this.isMe,
    required this.time,
    required this.senderName,
    required this.senderAvatar,
  });
}
