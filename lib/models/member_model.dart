class MemberModel {
  final int? id;
  final int groupId;
  final String name;
  final bool isMe;

  const MemberModel({
    this.id,
    required this.groupId,
    required this.name,
    this.isMe = false,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'group_id': groupId,
      'name': name,
      'is_me': isMe ? 1 : 0,
    };
  }

  factory MemberModel.fromMap(Map<String, Object?> map) {
    return MemberModel(
      id: map['id'] as int,
      groupId: map['group_id'] as int,
      name: map['name'] as String,
      isMe: (map['is_me'] as int) == 1,
    );
  }
}