class UserEntity {
  final String id;
  final String email;
  final String name;
  final String role; // 'volunteer', 'senior', or 'both'
  final String gender;
  final bool isOnline;
  final double? latitude;
  final double? longitude;
  final int points;
  final int completedTasks;
  final String badge; // 'None', 'Bronze', 'Silver', 'Gold'
  final String? profileImageUrl;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.gender = '',
    this.isOnline = false,
    this.latitude,
    this.longitude,
    this.points = 0,
    this.completedTasks = 0,
    this.badge = 'None',
    this.profileImageUrl,
  });
}
