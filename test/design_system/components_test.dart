import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ibnzaidon/design_system/components/app_button.dart';
import 'package:ibnzaidon/design_system/components/app_text_field.dart';
import 'package:ibnzaidon/design_system/components/chips.dart';
import 'package:ibnzaidon/design_system/components/course_card.dart';
import 'package:ibnzaidon/design_system/components/exam_timer.dart';
import 'package:ibnzaidon/design_system/components/price_view.dart';
import 'package:ibnzaidon/design_system/components/progress_ring.dart';
import 'package:ibnzaidon/design_system/components/score_gauge.dart';
import 'package:ibnzaidon/design_system/components/state_views.dart';
import 'package:ibnzaidon/design_system/components/teacher_avatar_card.dart';

import '../helpers/pump_app.dart';

/// Every component, light/dark x ar/en. Golden files live in
/// test/design_system/goldens (regenerate with `--update-goldens`).
Widget _showcase() => const SingleChildScrollView(
  padding: EdgeInsets.all(16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AppButton(label: 'Continue', onPressed: null),
      SizedBox(height: 8),
      AppButton(
        label: 'Continue',
        onPressed: _noop,
        variant: AppButtonVariant.secondary,
      ),
      SizedBox(height: 8),
      AppButton(
        label: 'Delete',
        onPressed: _noop,
        variant: AppButtonVariant.destructive,
      ),
      SizedBox(height: 8),
      AppTextField(label: 'Phone', forceLtr: true),
      SizedBox(height: 8),
      Wrap(
        spacing: 8,
        children: [
          RatingChip(rating: 4.6),
          StatChip(icon: Icons.people, label: '1.2K'),
          PriceView(price: 12.5, oldPrice: 20),
          DiscountBadge(percent: 38),
        ],
      ),
      SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ProgressRing(progress: 0.6),
          ExamTimer(
            remaining: Duration(minutes: 3),
            total: Duration(minutes: 30),
          ),
        ],
      ),
      SizedBox(height: 8),
      Center(child: ScoreGauge(fraction: 0.82, isPassed: true, size: 140)),
      SizedBox(height: 8),
      CourseCard(
        title: 'Algebra essentials',
        teacherName: 'Sami Haddad',
        rating: 4.8,
        priceSlot: PriceView(price: 12.5, oldPrice: 20),
        discountSlot: DiscountBadge(percent: 38),
        variant: CourseCardVariant.horizontal,
      ),
      SizedBox(height: 8),
      TeacherAvatarCard(name: 'Sami Haddad', rating: 4.9, isVerified: true),
    ],
  ),
);

void _noop() {}

void main() {
  group('PriceView follows show_price', () {
    testWidgets('renders price and discount when prices are visible', (
      tester,
    ) async {
      await tester.pumpApp(
        const Column(
          children: [
            PriceView(price: 12.5, oldPrice: 20),
            DiscountBadge(percent: 38),
          ],
        ),
        locale: const Locale('en'),
      );
      expect(find.text('JOD 12.50'), findsOneWidget);
      expect(find.text('JOD 20.00'), findsOneWidget);
      expect(find.text('-38%'), findsOneWidget);
    });

    testWidgets('hides every price surface when show_price is off', (
      tester,
    ) async {
      await tester.pumpApp(
        const Column(
          children: [
            PriceView(price: 12.5, oldPrice: 20),
            PriceView(price: 0, isFree: true),
            DiscountBadge(percent: 38),
          ],
        ),
        locale: const Locale('en'),
        showPrice: false,
      );
      expect(find.textContaining('JOD'), findsNothing);
      expect(find.text('Free'), findsNothing);
      expect(find.text('-38%'), findsNothing);
    });

    testWidgets(
      'formats Arabic prices with the dinar symbol and Western digits',
      (tester) async {
        await tester.pumpApp(const PriceView(price: 12.5));
        expect(find.text('12.50 د.أ'), findsOneWidget);
      },
    );
  });

  group('AppButton', () {
    testWidgets('does not fire while loading (double-submit guard)', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpApp(
        AppButton(label: 'Go', isLoading: true, onPressed: () => taps++),
        locale: const Locale('en'),
      );
      await tester.tap(find.byType(AppButton));
      expect(taps, 0);
    });

    testWidgets('fires when enabled', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        AppButton(label: 'Go', onPressed: () => taps++),
        locale: const Locale('en'),
      );
      await tester.tap(find.text('Go'));
      expect(taps, 1);
    });
  });

  group('states', () {
    testWidgets('ErrorState offers a retry action', (tester) async {
      var retried = false;
      await tester.pumpApp(
        ErrorState(message: 'boom', onRetry: () => retried = true),
        locale: const Locale('en'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Retry'));
      expect(retried, isTrue);
    });

    testWidgets('SignInGate shows sign-in and create-account actions', (
      tester,
    ) async {
      await tester.pumpApp(
        SignInGate(onSignIn: () {}, onCreateAccount: () {}),
        locale: const Locale('en'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Sign in'), findsOneWidget);
      expect(find.text('Create account'), findsOneWidget);
    });
  });

  group('RTL correctness', () {
    testWidgets('text direction follows the locale', (tester) async {
      await tester.pumpApp(
        Builder(builder: (context) => Text('${Directionality.of(context)}')),
      );
      expect(find.text('TextDirection.rtl'), findsOneWidget);
      await tester.pumpApp(
        Builder(builder: (context) => Text('${Directionality.of(context)}')),
        locale: const Locale('en'),
      );
      expect(find.text('TextDirection.ltr'), findsOneWidget);
    });
  });

  group('golden', () {
    for (final locale in const [Locale('ar'), Locale('en')]) {
      for (final brightness in Brightness.values) {
        final name = '${locale.languageCode}_${brightness.name}';
        testWidgets('components $name', (tester) async {
          tester.view
            ..physicalSize = const Size(420, 1500)
            ..devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          await tester.pumpApp(
            _showcase(),
            locale: locale,
            brightness: brightness,
          );
          await tester.pump(const Duration(seconds: 1));
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('goldens/components_$name.png'),
          );
        });
      }
    }
  });
}
