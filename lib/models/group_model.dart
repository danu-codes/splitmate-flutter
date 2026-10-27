class GroupModel {
  final int? id;
  final String name;
  final int createdAt;

  const GroupModel({
    this.id,
    required this.name,
    required this.createdAt,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt,
    };
  }

  factory GroupModel.fromMap(Map<String, Object?> map) {
    return GroupModel(
      id: map['id'] as int,
      name: map['name'] as String,
      createdAt: map['created_at'] as int,
    );
  }
}