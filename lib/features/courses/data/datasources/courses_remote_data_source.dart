import 'package:ibnzaidon/core/network/api_client.dart';
import 'package:ibnzaidon/core/network/api_envelope.dart';
import 'package:ibnzaidon/features/courses/domain/entities/course_content.dart';

class CoursesRemoteDataSource {
  const CoursesRemoteDataSource(this._client);

  final ApiClient _client;

  Future<ApiEnvelope> fetchCourses(int page, CourseQuery query) => _client.get(
    'courses',
    query: {
      'page': page,
      'search': query.search.trim(),
      'category_id': query.categoryId,
      'subject_id': query.subjectId,
      'teacher_id': query.teacherId,
      if (query.featured) 'featured': 1,
      if (query.trending) 'trending': 1,
    },
  );

  Future<ApiEnvelope> fetchCourseDetail(int id) =>
      _client.get('courses/$id', optionalAuth: true);

  Future<ApiEnvelope> fetchCourseUnits(int id) =>
      _client.get('courses/$id/units');

  Future<ApiEnvelope> fetchCourseProgress(int id) =>
      _client.get('courses/$id/my-progress');

  Future<ApiEnvelope> fetchMyCourses(int page) =>
      _client.get('my-courses', query: {'page': page});

  Future<ApiEnvelope> activate(int courseId, String cardCode) =>
      _client.post('courses/$courseId/activate', body: {'card_code': cardCode});

  Future<ApiEnvelope> verifyApplePurchase(ApplePurchaseProof proof) =>
      _client.post(
        'purchases/apple/verify',
        body: {
          'course_id': proof.courseId,
          'product_id': proof.productId,
          'transaction_id': proof.transactionId,
          'signed_transaction': proof.signedTransaction,
          'purchase_token': proof.purchaseToken,
          if (proof.transactionDate != null)
            'transaction_date': proof.transactionDate,
          'source': 'app_store',
        },
      );
}
