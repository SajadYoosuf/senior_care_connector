import '../entities/volunteer_entity.dart';

abstract class VolunteerRepository {
  Future<List<VolunteerEntity>> getVolunteers();
}
