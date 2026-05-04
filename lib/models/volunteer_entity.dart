class VolunteerEntity {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final int reviewCount;
  final double distance;
  final String imageUrl;

  const VolunteerEntity({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    required this.imageUrl,
  });
}
