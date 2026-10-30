import '../models/review.dart';

abstract class ReviewRepository {
  Future<void> add(Review review);
  Future<List<Review>> forProject(String projectId);
}

class MockReviewRepository implements ReviewRepository {
  final List<Review> _reviews = [];

  @override
  Future<void> add(Review review) async => _reviews.add(review);

  @override
  Future<List<Review>> forProject(String projectId) async =>
      _reviews.where((r) => r.projectId == projectId).toList();
}
