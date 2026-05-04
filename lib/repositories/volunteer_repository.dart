import 'package:senior_care/models/volunteer_entity.dart';

abstract class VolunteerRepository {
  Future<List<VolunteerEntity>> getVolunteers();
}
