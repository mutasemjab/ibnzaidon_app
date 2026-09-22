import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/bloc/resource_bloc.dart';
import 'package:ibnzaidon/core/bloc/submission_status.dart';
import 'package:ibnzaidon/core/config/app_config.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/features/courses/domain/entities/course_content.dart';
import 'package:ibnzaidon/features/courses/domain/services/store_purchase_gateway.dart';
import 'package:ibnzaidon/features/courses/domain/usecases/courses_usecases.dart';
import 'package:ibnzaidon/features/courses/presentation/bloc/activation_bloc.dart';
import 'package:ibnzaidon/features/courses/presentation/bloc/course_detail_bloc.dart';
import 'package:ibnzaidon/features/courses/presentation/bloc/purchase_bloc.dart';
import 'package:ibnzaidon/shared/domain/entities/course.dart';
import 'package:mocktail/mocktail.dart';

class _MockDetail extends Mock implements GetCourseDetailUseCase {}

class _MockUnits extends Mock implements GetCourseUnitsUseCase {}

class _MockProgress extends Mock implements GetCourseProgressUseCase {}

class _MockActivate extends Mock implements ActivateCourseUseCase {}

class _MockVerify extends Mock implements VerifyApplePurchaseUseCase {}

class _FakeGateway implements StorePurchaseGateway {
  final controller = StreamController<StorePurchaseUpdate>.broadcast();
  final completed = <StorePurchaseUpdate>[];

  @override
  bool get isSupported => true;

  @override
  Stream<StorePurchaseUpdate> get updates => controller.stream;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<Either<Failure, Unit>> buy({
    required String productId,
    String? appAccountToken,
  }) async => right(unit);

  @override
  Future<void> restore() async {}

  @override
  Future<void> complete(StorePurchaseUpdate update) async =>
      completed.add(update);
}

const _course = Course(
  id: 7,
  title: 'Algebra',
  price: 10,
  canPurchaseViaStore: true,
);

CourseDetail _detail({bool enrolled = false}) => CourseDetail(
  course: _course,
  isEnrolled: enrolled,
  units: const [
    UnitOutline(
      id: 1,
      title: 'u',
      orderIndex: 1,
      lessons: [LessonOutline(id: 1, title: 'l', type: LessonType.video)],
    ),
  ],
);

void main() {
  setUpAll(() {
    registerFallbackValue(
      const ActivateCourseParams(courseId: 0, cardCode: ''),
    );
    registerFallbackValue(
      const ApplePurchaseProof(
        courseId: 0,
        productId: '',
        transactionId: '',
        signedTransaction: '',
        purchaseToken: '',
      ),
    );
  });

  group('CourseDetailBloc', () {
    late _MockDetail getDetail;
    late _MockUnits getUnits;
    late _MockProgress getProgress;

    setUp(() {
      getDetail = _MockDetail();
      getUnits = _MockUnits();
      getProgress = _MockProgress();
    });

    CourseDetailBloc build() => CourseDetailBloc(
      courseId: 7,
      getCourseDetail: getDetail,
      getCourseUnits: getUnits,
      getCourseProgress: getProgress,
    );

    test('guest: keeps the public outline when units return 401', () async {
      when(() => getDetail(7)).thenAnswer((_) async => right(_detail()));
      when(
        () => getUnits(7),
      ).thenAnswer((_) async => left(const UnauthorizedFailure()));
      final bloc = build()..add(const CourseDetailRequested());
      final state = await bloc.stream.firstWhere(
        (s) => s.units == null && s.detail != null && !s.isLoading,
      );
      expect(state.isEnrolled, isFalse);
      expect(state.units, isNull);
      verifyNever(() => getProgress(any()));
      await bloc.close();
    });

    test(
      'enrolled: loads lock-aware units and progress, picks next lesson',
      () async {
        when(
          () => getDetail(7),
        ).thenAnswer((_) async => right(_detail(enrolled: true)));
        when(() => getUnits(7)).thenAnswer(
          (_) async => right(
            const CourseUnits(
              courseId: 7,
              courseName: 'c',
              isEnrolled: true,
              units: [
                CourseUnit(
                  id: 1,
                  title: 'u',
                  orderIndex: 1,
                  lessons: [
                    UnitLesson(id: 1, title: 'a', type: LessonType.video),
                    UnitLesson(id: 2, title: 'b', type: LessonType.video),
                    UnitLesson(
                      id: 3,
                      title: 'c',
                      type: LessonType.video,
                      isLocked: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
        when(() => getProgress(7)).thenAnswer(
          (_) async => right(
            const CourseProgress(percentage: 0.33, completedLessonIds: {1}),
          ),
        );
        final bloc = build()..add(const CourseDetailRequested());
        final state = await bloc.stream.firstWhere((s) => s.progress != null);
        expect(state.isEnrolled, isTrue);
        expect(state.nextLesson?.id, 2);
        expect(state.progressFraction, 0.33);
        await bloc.close();
      },
    );

    test('a failing detail call surfaces the failure', () async {
      when(
        () => getDetail(7),
      ).thenAnswer((_) async => left(const NotFoundFailure()));
      when(
        () => getUnits(7),
      ).thenAnswer((_) async => left(const NotFoundFailure()));
      final bloc = build()..add(const CourseDetailRequested());
      final state = await bloc.stream.firstWhere(
        (s) => s.status == ResourceStatus.failure,
      );
      expect(state.failure, const NotFoundFailure());
      await bloc.close();
    });
  });

  group('ActivationBloc', () {
    late _MockActivate activate;

    setUp(() => activate = _MockActivate());

    blocTest<ActivationBloc, ActivationState>(
      'succeeds with a valid card',
      build: () {
        when(() => activate(any())).thenAnswer(
          (_) async =>
              right(const ActivationResult(courseId: 7, courseName: 'Algebra')),
        );
        return ActivationBloc(courseId: 7, activateCourse: activate);
      },
      act: (bloc) => bloc.add(const ActivationSubmitted('ABCD-1234')),
      expect: () => [
        const ActivationState(status: SubmissionStatus.submitting),
        const ActivationState(
          status: SubmissionStatus.success,
          result: ActivationResult(courseId: 7, courseName: 'Algebra'),
        ),
      ],
    );

    blocTest<ActivationBloc, ActivationState>(
      'exposes the 422 validation failure for an invalid code',
      build: () {
        when(() => activate(any())).thenAnswer(
          (_) async => left(const ValidationFailure(message: 'invalid code')),
        );
        return ActivationBloc(courseId: 7, activateCourse: activate);
      },
      act: (bloc) => bloc.add(const ActivationSubmitted('BAD')),
      verify: (bloc) {
        expect(bloc.state.status, SubmissionStatus.failure);
        expect(bloc.state.failure, isA<ValidationFailure>());
      },
    );
  });

  group('PurchaseBloc', () {
    late _FakeGateway gateway;
    late _MockVerify verifyUseCase;
    var token = 'uuid-token';

    setUp(() {
      gateway = _FakeGateway();
      verifyUseCase = _MockVerify();
      token = 'uuid-token';
    });

    tearDown(() => gateway.controller.close());

    PurchaseBloc build() => PurchaseBloc(
      gateway: gateway,
      verifyPurchase: verifyUseCase,
      config: AppConfig.dev(),
      appAccountToken: () => token,
    );

    const update = StorePurchaseUpdate(
      status: StorePurchaseStatus.purchased,
      productId: 'com.IbnZaidon.school.course.v2.7',
      transactionId: '123456',
      signedTransaction: 'jws',
    );

    test(
      'completes the transaction ONLY after the backend confirms it',
      () async {
        when(() => verifyUseCase(any())).thenAnswer(
          (_) async => right(
            const PurchaseVerification(
              courseId: 7,
              transactionId: '123456',
              isEnrolled: true,
            ),
          ),
        );
        final bloc = build();
        gateway.controller.add(update);
        final state = await bloc.stream.firstWhere(
          (s) => s.status == PurchaseStatus.success,
        );
        expect(state.courseId, 7);
        final proof =
            verify(() => verifyUseCase(captureAny())).captured.single
                as ApplePurchaseProof;
        expect(proof.purchaseToken, 'uuid-token');
        expect(proof.courseId, 7);
        expect(gateway.completed, [update]);
        await bloc.close();
      },
    );

    test('never loses a paid transaction when verification fails', () async {
      when(
        () => verifyUseCase(any()),
      ).thenAnswer((_) async => left(const NetworkFailure()));
      final bloc = build();
      gateway.controller.add(update);
      final failed = await bloc.stream.firstWhere(
        (s) => s.status == PurchaseStatus.failure,
      );
      expect(failed.canRetryVerification, isTrue);
      expect(gateway.completed, isEmpty, reason: 'must stay open for retry');

      when(() => verifyUseCase(any())).thenAnswer(
        (_) async => right(
          const PurchaseVerification(
            courseId: 7,
            transactionId: '123456',
            isEnrolled: true,
          ),
        ),
      );
      bloc.add(const PurchaseVerificationRetried());
      await bloc.stream.firstWhere((s) => s.status == PurchaseStatus.success);
      expect(gateway.completed, [update]);
      await bloc.close();
    });

    test('a transaction that cannot be verified yet is left open', () async {
      // Signed out: no account token available.
      final signedOut = PurchaseBloc(
        gateway: gateway,
        verifyPurchase: verifyUseCase,
        config: AppConfig.dev(),
        appAccountToken: () => null,
      );
      gateway.controller.add(update);
      await Future<void>.delayed(const Duration(milliseconds: 30));
      verifyNever(() => verifyUseCase(any()));
      expect(gateway.completed, isEmpty);
      await signedOut.close();
    });

    test('cancelled and pending purchases map to their own states', () async {
      final bloc = build();
      gateway.controller.add(
        const StorePurchaseUpdate(
          status: StorePurchaseStatus.pending,
          productId: 'com.IbnZaidon.school.course.v2.7',
        ),
      );
      await bloc.stream.firstWhere((s) => s.status == PurchaseStatus.pending);
      gateway.controller.add(
        const StorePurchaseUpdate(
          status: StorePurchaseStatus.canceled,
          productId: 'com.IbnZaidon.school.course.v2.7',
        ),
      );
      await bloc.stream.firstWhere((s) => s.status == PurchaseStatus.cancelled);
      await bloc.close();
    });
  });
}
