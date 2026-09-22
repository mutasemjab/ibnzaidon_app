import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/network/api_client.dart';
import 'package:ibnzaidon/core/network/api_envelope.dart';
import 'package:ibnzaidon/core/network/api_guard.dart';
import 'package:ibnzaidon/core/utils/parsers.dart';
import 'package:ibnzaidon/features/auth/data/models/student_model.dart';
import 'package:ibnzaidon/features/profile/domain/entities/profile.dart';
import 'package:ibnzaidon/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl({
    required ApiClient client,
    required ApiGuard guard,
  }) : _client = client,
       _guard = guard;

  final ApiClient _client;
  final ApiGuard _guard;

  @override
  Future<Either<Failure, Profile>> getProfile() => _guard.run(() async {
    final envelope = await _client.get('profile');
    return _parse(envelope);
  });

  @override
  Future<Either<Failure, Profile>> updateProfile(ProfileUpdate update) =>
      _guard.run(() async {
        final fields = _fields(update);
        final path = update.avatarPath;
        final ApiEnvelope envelope;
        if (path == null) {
          envelope = await _client.put('profile', body: fields);
        } else {
          final form = FormData.fromMap({
            ...fields,
            'avatar': await MultipartFile.fromFile(path),
          });
          envelope = await _client.putMultipart('profile', form);
        }
        final profile = _parse(envelope);
        // Some responses only echo the changed fields; refetch for a full one.
        if (profile.student.id == 0) {
          return _parse(await _client.get('profile'));
        }
        return profile;
      });

  Map<String, Object?> _fields(ProfileUpdate update) => {
    if (update.name != null) 'name': update.name,
    if (update.email != null) 'email': update.email,
    if (update.phone != null) 'phone': update.phone,
    if (update.nationalId != null) 'national_id': update.nationalId,
    if (update.gender != null) 'gender': update.gender,
    if (update.dateOfBirth != null)
      'date_of_birth': update.dateOfBirth!.toIso8601String().substring(0, 10),
    if (update.nationality != null) 'nationality': update.nationality,
    if (update.classId != null) 'class_id': update.classId,
    if (update.newPassword != null) ...{
      'current_password': update.currentPassword,
      'password': update.newPassword,
      'password_confirmation': update.newPasswordConfirmation,
    },
  };

  Profile _parse(ApiEnvelope envelope) {
    final data = envelope.dataMap;
    final studentJson =
        asMap(data['student']) ?? asMap(data['profile']) ?? data;
    final statsJson = asMap(data['stats']) ?? asMap(studentJson['stats']);
    return Profile(
      student: StudentModel.fromJson(studentJson),
      nationalId: tryParseString(studentJson['national_id']),
      dateOfBirth: tryParseDate(studentJson['date_of_birth']),
      nationality: tryParseString(studentJson['nationality']),
      stats: [
        if (statsJson != null)
          for (final entry in statsJson.entries)
            if (tryParseDouble(entry.value) != null)
              ProfileStat(key: entry.key, value: tryParseDouble(entry.value)!),
      ],
    );
  }
}
