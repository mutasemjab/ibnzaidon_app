import 'package:ibnzaidon/core/network/api_client.dart';
import 'package:ibnzaidon/features/auth/data/models/student_model.dart';

/// `data: { token, student }` returned by login/register.
final class AuthPayload {
  const AuthPayload({required this.token, required this.student});

  final String token;
  final StudentModel student;
}

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._client);

  final ApiClient _client;

  Future<AuthPayload> login({
    required String phone,
    required String password,
    required String deviceId,
  }) async {
    final envelope = await _client.post(
      'auth/login',
      body: {'phone': phone, 'password': password, 'deviceId': deviceId},
      skipSessionExpiry: true,
    );
    return _parse(envelope.dataMap);
  }

  Future<AuthPayload> register({
    required String name,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String deviceId,
    String? email,
    int? classId,
  }) async {
    final envelope = await _client.post(
      'auth/register',
      body: {
        'name': name,
        'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'deviceId': deviceId,
        if (email != null && email.isNotEmpty) 'email': email,
        if (classId != null) 'class_id': classId,
      },
      skipSessionExpiry: true,
    );
    return _parse(envelope.dataMap);
  }

  Future<StudentModel> fetchCurrentStudent() async {
    final envelope = await _client.get('profile');
    final data = envelope.dataMap;
    final studentJson = data['student'] is Map ? data['student'] : data;
    return StudentModel.fromJson(Map<String, dynamic>.from(studentJson as Map));
  }

  Future<void> logout() => _client.post('auth/logout');

  Future<void> deleteAccount() => _client.delete('auth/delete-account');

  Future<AuthPayload> switchSibling(int siblingId) async {
    final envelope = await _client.post('auth/switch-sibling/$siblingId');
    return _parse(envelope.dataMap);
  }

  AuthPayload _parse(Map<String, dynamic> data) {
    final token = data['token']?.toString();
    final student = data['student'];
    if (token == null || token.isEmpty || student is! Map) {
      throw const FormatException('Malformed auth payload');
    }
    return AuthPayload(
      token: token,
      student: StudentModel.fromJson(Map<String, dynamic>.from(student)),
    );
  }
}
