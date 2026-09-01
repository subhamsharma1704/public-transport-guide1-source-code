class TravelNote {
  final String id;
  final String title;
  final String content;
  final String routeName;
  final String createdAt;
  final String reminderTime;
  final bool isPinned;

  TravelNote({
    required this.id,
    required this.title,
    required this.content,
    required this.routeName,
    required this.createdAt,
    this.reminderTime = '',
    this.isPinned = false,
  });

  factory TravelNote.fromJson(Map<String, dynamic> json) => TravelNote(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        content: json['content'] ?? '',
        routeName: json['routeName'] ?? '',
        createdAt: json['createdAt'] ?? '',
        reminderTime: json['reminderTime'] ?? '',
        isPinned: json['isPinned'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'routeName': routeName,
        'createdAt': createdAt,
        'reminderTime': reminderTime,
        'isPinned': isPinned,
      };

  TravelNote copyWith({
    String? id,
    String? title,
    String? content,
    String? routeName,
    String? createdAt,
    String? reminderTime,
    bool? isPinned,
  }) {
    return TravelNote(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      routeName: routeName ?? this.routeName,
      createdAt: createdAt ?? this.createdAt,
      reminderTime: reminderTime ?? this.reminderTime,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}
