import '../../domain/entities/volunteer_entity.dart';
import '../../domain/repositories/volunteer_repository.dart';

class MockVolunteerRepository implements VolunteerRepository {
  @override
  Future<List<VolunteerEntity>> getVolunteers() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate delay
    return [
      const VolunteerEntity(
        id: '1',
        name: 'Alfredo Lubin',
        specialty: 'Groceries & deliveries',
        rating: 4.9,
        reviewCount: 124,
        distance: 0.8,
        imageUrl: 'https://i.pravatar.cc/150?img=11',
      ),
      const VolunteerEntity(
        id: '2',
        name: 'Hanna Dorwart',
        specialty: 'Groceries & deliveries',
        rating: 4.9,
        reviewCount: 124,
        distance: 0.8,
        imageUrl: 'https://i.pravatar.cc/150?img=9',
      ),
      const VolunteerEntity(
        id: '3',
        name: 'Giana Westervelt',
        specialty: 'Groceries & deliveries',
        rating: 4.9,
        reviewCount: 124,
        distance: 0.8,
        imageUrl: 'https://i.pravatar.cc/150?img=13',
      ),
      const VolunteerEntity(
        id: '4',
        name: 'James Carder',
        specialty: 'Medical Transport',
        rating: 4.8,
        reviewCount: 89,
        distance: 1.2,
        imageUrl: 'https://i.pravatar.cc/150?img=33',
      ),
    ];
  }
}
