/// 工作空间数据模型
class Workspace {
  int? id;
  late String uuid;
  late String name;
  late int createdAt;
  int order = 0;
  int deletedAt = 0; // 删除时间戳，0表示未删除

  // 默认构造函数
  Workspace();

  // JSON序列化
  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'name': name,
      'createdAt': createdAt,
      'order': order,
      'deletedAt': deletedAt,
    };
  }

  // JSON反序列化
  factory Workspace.fromJson(Map<String, dynamic> json) {
    final workspace = Workspace()
      ..uuid = json['uuid'] as String
      ..name = json['name'] as String
      ..createdAt = json['createdAt'] as int
      ..order = json['order'] as int? ?? 0
      ..deletedAt = json['deletedAt'] as int? ?? 0;
    
    return workspace;
  }

  /// 创建副本
  Workspace copyWith({
    String? uuid,
    String? name,
    int? createdAt,
    int? order,
    int? deletedAt,
  }) {
    final workspace = Workspace()
      ..uuid = uuid ?? this.uuid
      ..name = name ?? this.name
      ..createdAt = createdAt ?? this.createdAt
      ..order = order ?? this.order
      ..deletedAt = deletedAt ?? this.deletedAt;
    return workspace;
  }
}

