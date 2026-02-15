class ReminderEntity {
  final String id;
  final String title;
  final String subtitle;
  final String time;
  final bool isCompleted;
  final String type; // 'pill', 'visit', 'food', 'checkup'

  const ReminderEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isCompleted,
    required this.type,
  });
}
