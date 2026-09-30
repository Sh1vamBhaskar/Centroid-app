class Conversation {
  final int id;
  final int userOneId;
  final int userTwoId;
  final DateTime createdAt;

  Conversation({
    required this.id,
    required this.userOneId,
    required this.userTwoId,
    required this.createdAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as int,
      userOneId: json['userOneId'] as int,
      userTwoId: json['userTwoId'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  int otherUserId(int currentUserId) {
    return currentUserId == userOneId
        ? userTwoId
        : userOneId;
  }
}