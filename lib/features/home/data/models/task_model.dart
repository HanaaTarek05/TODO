class TaskModel {
  final int? id;
  final String title;
  final String description;
  final String? image;
  final String? group;
  final String? endTime;
  final bool isDone;

  TaskModel({
    this.id,
    required this.title,
    required this.description,
    this.image,
    this.group,
    this.endTime,
    this.isDone = false,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'],
      group: json['group'],
      endTime: json['end_time'] ?? json['endTime'],
      isDone: json['is_done'] ?? json['isDone'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      if (image != null) 'image': image,
      if (group != null) 'group': group,
      if (endTime != null) 'end_time': endTime,
      'is_done': isDone,
    };
  }
}
