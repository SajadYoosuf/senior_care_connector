class TaskEntity {
  final String id;
  final String title;
  final DateTime date;
  final String status; // 'Pending', 'In Progress', 'Completed'
  final String imageUrl;
  final String category;
  final String description;
  final String location;

  const TaskEntity({
    required this.id,
    required this.title,
    required this.date,
    required this.status,
    required this.imageUrl,
    required this.category,
    this.description = '',
    this.location = '',
  });
}
