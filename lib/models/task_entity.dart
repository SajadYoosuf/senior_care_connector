class TaskEntity {
  final String id;
  final String title;
  final DateTime date;
  final String status; // 'Pending', 'Accepted', 'Completed'
  final String imageUrl;
  final String category;
  final String description;
  final String location;
  final double? latitude;
  final double? longitude;
  final String? volunteerId;
  final String requesterId;
  final String requesterName;
  final String requesterPhoto;
  final DateTime? acceptedAt;
  final DateTime? completedAt;

  const TaskEntity({
    required this.id,
    required this.title,
    required this.date,
    required this.status,
    required this.imageUrl,
    required this.category,
    this.description = '',
    this.location = '',
    this.latitude,
    this.longitude,
    this.volunteerId,
    this.requesterId = '',
    this.requesterName = 'Senior User',
    this.requesterPhoto = 'https://i.pravatar.cc/150?img=12',
    this.acceptedAt,
    this.completedAt,
  });
}
