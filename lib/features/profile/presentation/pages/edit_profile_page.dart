import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ibnzaidon/core/bloc/submission_status.dart';
import 'package:ibnzaidon/core/di/injector.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/core/utils/formatters.dart';
import 'package:ibnzaidon/core/utils/validators.dart';
import 'package:ibnzaidon/design_system/components/app_button.dart';
import 'package:ibnzaidon/design_system/components/app_network_image.dart';
import 'package:ibnzaidon/design_system/components/app_text_field.dart';
import 'package:ibnzaidon/design_system/components/layout_helpers.dart';
import 'package:ibnzaidon/design_system/components/overlays.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:ibnzaidon/features/auth/domain/entities/student.dart';
import 'package:ibnzaidon/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ibnzaidon/features/profile/domain/entities/profile.dart';
import 'package:ibnzaidon/features/profile/presentation/bloc/profile_blocs.dart';
import 'package:ibnzaidon/shared/presentation/auth_gate.dart';
import 'package:ibnzaidon/shared/presentation/failure_view.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.profileEditTitle)),
      body: AuthGate(
        builder: (_) => BlocProvider(
          create: (_) => getIt<ProfileEditBloc>(),
          child: const _EditForm(),
        ),
      ),
    );
  }
}

class _EditForm extends StatefulWidget {
  const _EditForm();

  @override
  State<_EditForm> createState() => _EditFormState();
}

class _EditFormState extends State<_EditForm> {
  static const int _maxAvatarBytes = 2 * 1024 * 1024;
  static const _avatarMaxDimension = 1024.0;
  static const _avatarQuality = 75;

  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: _student?.name);
  late final _email = TextEditingController(text: _student?.email);
  late final _phone = TextEditingController(text: _student?.phone);
  final _nationalId = TextEditingController();
  final _nationality = TextEditingController();
  String? _gender;
  DateTime? _birthDate;
  String? _avatarPath;

  Student? get _student => context.read<AuthBloc>().state.student;

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _nationalId, _nationality]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickAvatar(ImageSource source) async {
    final l10n = context.l10n;
    final file = await ImagePicker().pickImage(
      source: source,
      maxWidth: _avatarMaxDimension,
      maxHeight: _avatarMaxDimension,
      imageQuality: _avatarQuality,
    );
    if (file == null || !mounted) return;
    if (await File(file.path).length() > _maxAvatarBytes) {
      if (mounted) {
        AppSnackbar.show(
          context,
          l10n.profileAvatarTooLarge,
          type: AppSnackbarType.error,
        );
      }
      return;
    }
    setState(() => _avatarPath = file.path);
  }

  Future<void> _chooseSource() async {
    final l10n = context.l10n;
    final source = await showAppBottomSheet<ImageSource>(
      context,
      title: l10n.profileAvatarChange,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(l10n.profileAvatarFromGallery),
            onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(l10n.profileAvatarFromCamera),
            onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
    if (source != null) await _pickAvatar(source);
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 12),
      firstDate: DateTime(1950),
      lastDate: now,
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<ProfileEditBloc>().add(
      ProfileSaveRequested(
        ProfileUpdate(
          name: _name.text.trim(),
          email: _email.text.trim().isEmpty ? null : _email.text.trim(),
          phone: Validators.normalizePhone(_phone.text),
          nationalId: _nationalId.text.trim().isEmpty
              ? null
              : _nationalId.text.trim(),
          nationality: _nationality.text.trim().isEmpty
              ? null
              : _nationality.text.trim(),
          gender: _gender,
          dateOfBirth: _birthDate,
          avatarPath: _avatarPath,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocConsumer<ProfileEditBloc, ProfileSaveState>(
      listenWhen: (a, b) => a.status != b.status,
      listener: (context, state) {
        if (state.status == SubmissionStatus.success) {
          context.read<AuthBloc>().add(
            AuthStudentUpdated(state.profile!.student),
          );
          AppSnackbar.show(
            context,
            l10n.profileEditSaved,
            type: AppSnackbarType.success,
          );
          context.pop();
        } else if (state.status == SubmissionStatus.failure &&
            state.failure is! ValidationFailure) {
          context.showFailure(state.failure!);
        }
      },
      builder: (context, state) {
        final validation = state.failure is ValidationFailure
            ? state.failure! as ValidationFailure
            : null;
        return ContentConstraint(
          maxWidth: 560,
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsetsDirectional.all(AppSpacing.gutter),
              children: [
                Center(
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _chooseSource,
                    child: Stack(
                      children: [
                        if (_avatarPath != null)
                          ClipOval(
                            child: Image.file(
                              File(_avatarPath!),
                              width: AppSizes.avatarXl,
                              height: AppSizes.avatarXl,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          AppNetworkImage(
                            url: _student?.avatar,
                            width: AppSizes.avatarXl,
                            height: AppSizes.avatarXl,
                            circle: true,
                            placeholderIcon: Icons.person_rounded,
                          ),
                        PositionedDirectional(
                          end: 0,
                          bottom: 0,
                          child: CircleAvatar(
                            radius: AppSpacing.lg,
                            backgroundColor: context.colors.primary,
                            child: Icon(
                              Icons.photo_camera_rounded,
                              size: AppSizes.iconMd,
                              color: context.colors.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppTextField(
                  controller: _name,
                  label: l10n.authFieldName,
                  prefixIcon: Icons.person_outline_rounded,
                  errorText: validation?.firstErrorFor('name'),
                  validator: Validators.required(l10n),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: _phone,
                  label: l10n.authFieldPhone,
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  forceLtr: true,
                  errorText: validation?.firstErrorFor('phone'),
                  validator: Validators.phone(l10n),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: _email,
                  label: l10n.authFieldEmail,
                  prefixIcon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  forceLtr: true,
                  errorText: validation?.firstErrorFor('email'),
                  validator: Validators.optionalEmail(l10n),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: _nationalId,
                  label: l10n.profileFieldNationalId,
                  prefixIcon: Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                  forceLtr: true,
                  errorText: validation?.firstErrorFor('national_id'),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: _nationality,
                  label: l10n.profileFieldNationality,
                  prefixIcon: Icons.flag_outlined,
                  errorText: validation?.firstErrorFor('nationality'),
                ),
                const SizedBox(height: AppSpacing.lg),
                DropdownButtonFormField<String>(
                  initialValue: _gender,
                  decoration: InputDecoration(
                    labelText: l10n.profileFieldGender,
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'male',
                      child: Text(l10n.profileGenderMale),
                    ),
                    DropdownMenuItem(
                      value: 'female',
                      child: Text(l10n.profileGenderFemale),
                    ),
                  ],
                  onChanged: (value) => setState(() => _gender = value),
                ),
                const SizedBox(height: AppSpacing.lg),
                InkWell(
                  onTap: _pickBirthDate,
                  borderRadius: AppRadii.fieldRadius,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: l10n.profileFieldBirthDate,
                      prefixIcon: const Icon(Icons.cake_outlined),
                      errorText: validation?.firstErrorFor('date_of_birth'),
                    ),
                    child: Text(
                      _birthDate == null
                          ? ''
                          : AppFormatters.date(
                              _birthDate!,
                              context.languageCode,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppButton(
                  label: l10n.commonSave,
                  isLoading: state.status == SubmissionStatus.submitting,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
