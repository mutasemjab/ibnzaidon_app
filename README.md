# Ibn Zaidon Academy — Student App (Flutter)

Recorded courses, PDF worksheets, exams with instant analysis, previous-year
exams, question banks, teachers and notifications for **أكاديمية ابن زيدون
التعليمية**. Arabic (RTL) is the primary language, English (LTR) is fully
supported, light and dark themes are first-class.

## Architecture

Clean Architecture, feature-first, BLoC for state.

```
lib/
├─ main.dart / main_dev.dart / main_prod.dart   # flavor entry points
├─ app/            # App widget, router (go_router), shell, bootstrap, DI wiring
├─ core/           # config, error (Failure), network, storage, bloc bases, utils, l10n
├─ design_system/  # tokens, theme, components, hidden Design Gallery
├─ shared/         # cross-feature entities (Course, Teacher), paged list, shared widgets
└─ features/<feature>/{data,domain,presentation}
```

Dependency rule: `presentation → domain ← data`. `domain` imports nothing from
Flutter, Dio or `data`. Blocs call **use cases** only; repositories return
`Either<Failure, T>` and never leak `DioException`.

Reusable bases (write a feature in ~30 lines):

* `PagedBloc<T, Q>` — infinite-scroll lists (pagination, debounced search,
  refresh, stale-response protection). Subclasses only implement `fetchPage`.
* `ResourceBloc<T>` — single-resource screens (detail pages, home sections).
* `PagedBlocView` / `PagedListView` — binds a `PagedBloc` to UI with skeleton,
  empty, error, footer loader/retry and pull-to-refresh.

### Deliberate deviations from the master prompt

| Prompt | Done | Why |
|---|---|---|
| `freezed` / `json_serializable` / `injectable` codegen | Hand-written `Equatable` states + tolerant DTO parsers, manual `get_it` modules | The API needs tolerant parsing (numbers-as-strings, `1/0` booleans, mixed shapes) that generated `fromJson` cannot express, and it removes `build_runner` from the workflow. **No code generation is needed** (only `flutter gen-l10n`, which runs on `flutter pub get`/`run`). |
| `hive_ce` | `shared_preferences` JSON cache | Small payloads (home, categories, banners, page 1 of my-courses). |
| Native flavor bundle-id suffixes | `--dart-define` flavors only | Flavor-specific Firebase configs (`google-services.json` / `GoogleService-Info.plist`) are needed first. |
| Lottie illustrations | Built-in animated `IllustrationBadge` | No illustration assets were supplied. |
| Avatar crop | Resize + compress (`image_picker`, ≤ 2 MB check) | Keeps the dependency list small. |
| `GET classes` picker on register | Not built | No endpoint exists to list classes (`class_id` stays optional). |

## Running

```bash
flutter pub get                       # also generates l10n (flutter: generate: true)

# dev flavor (logging on, design gallery reachable)
flutter run -t lib/main_dev.dart  --dart-define=API_BASE_URL=https://dev.example.com

# prod flavor
flutter run -t lib/main_prod.dart --dart-define=API_BASE_URL=https://example.com
```

`--dart-define` switches: `API_BASE_URL`, `SECURE_SCREENS` (screenshot block on
exam / paid-video screens, default `true` in prod), and feature flags
`FF_ANNOUNCEMENTS`, `FF_CONDUCT`, `FF_PLANNERS`, `FF_SCHEDULES`, `FF_SIBLINGS`.

> The default `API_BASE_URL` values are placeholders — set the real host.

### Localization

Strings live in `tool/l10n/*.json` as `"key": ["ar", "en", "placeholders?"]`.
After editing them run:

```bash
node tool/merge_arb.js && flutter gen-l10n
```

(This writes `lib/core/l10n/arb/app_{ar,en}.arb`; Arabic is the template.)

### Tests

```bash
flutter test                          # unit, bloc, widget, golden
flutter test --update-goldens         # after intentional UI changes
flutter analyze
```

`legacy_tests/` holds tests from the previous (removed) `ibnzaidon` code base;
they are excluded from analysis and are not run.

## Adding a feature

1. `features/<name>/domain`: entity (plain class, `Equatable`), abstract
   repository, one use case per action.
2. `features/<name>/data`: model `extends` the entity with a tolerant
   `fromJson`, remote data source (via `ApiClient`), repository wrapping calls
   in `ApiGuard.run(...)`.
3. `features/<name>/presentation`: a `PagedBloc` / `ResourceBloc` subclass (or a
   custom bloc), pages, widgets — strings from `context.l10n`, sizes/colors from
   the design system.
4. Register in `app/di/features_module.dart` (factory for screen blocs,
   singleton for global ones) and add the route in `app/router/app_router.dart`
   + `app_routes.dart`.
5. Add localization keys in `tool/l10n`, then tests.

## Behaviors worth knowing

* **Session**: token + device id in secure storage; a 401 anywhere except
  login/register (and optional-auth reads) clears the session and routes to
  login with a "session expired" notice. Guests can browse public content;
  everything else shows a "Sign in to continue" gate.
* **`show_price == 0`** hides every price, old price, discount badge and buy
  button through `PriceView` / `DiscountBadge` / `PriceGate`. Until the flag is
  known the last stored value is used (default hidden).
* **iOS purchases**: StoreKit 2 via `in_app_purchase`. A transaction is only
  completed **after** `POST purchases/apple/verify` succeeds; failures keep it
  open with a retry.
* **Exams**: countdown derived from a local start time (autosaved), so it
  survives app kills; a server `started_at` more than 2 minutes away from the
  device clock is ignored (clock/time-zone skew). Auto-submit at zero.
* **Offline**: `home`, `categories`, `banners` and page 1 of `my-courses` fall
  back to the last good response on network failure; PDFs are cached on disk.

## Backend assumptions to verify

Fields the contract does not define (all parsed defensively; missing values
degrade to empty UI):

**Exam card / detail** (`GET exams`, `GET exams/{id}`, `POST exams/{id}/start`):
`id, title, description, instructions, exam_type, duration_minutes,
total_questions | questions_count, total_marks, passing_marks | pass_marks,
difficulty_level, show_result_immediately, course{id,name}, subject{id,name}`.
Start returns `exam` with `questions`, otherwise the app falls back to
`GET exams/{id}`. `percentage` is assumed to be `0..100`.

**Profile** (`GET/PUT profile`): student under `data.student | data.profile |
data`; `stats` is an object of numeric values (labels are matched by key
substring: `complet`, `exam`, `lesson`, `hour`, `pass`, `course|enroll`);
extra fields `national_id`, `date_of_birth`, `nationality`. The avatar update
is `POST profile` with `_method=PUT` (multipart). Password change is
`PUT profile` with `current_password, password, password_confirmation`.

**Notifications**: `data` is a free-form object; deep links use
`course_id`, `lesson_id`, `exam_id`, `teacher_id`. FCM messages are assumed to
carry the same keys plus an optional `type`.

**Activation**: the card code is sent exactly as typed (upper-cased, grouped in
blocks of four with `-`). Free courses show "Start learning" and rely on the
backend granting access to `is_free` lessons.

**Home**: `GET home` requires auth, so guests see banners + categories only.

**Course detail**: `what_you_learn` / `requirements` may be a list or a
newline/`|` separated string.

### Feature-flagged endpoints (`FeatureFlags`, default off)

`GET announcements`, `GET announcements/{id}`, `GET conduct`,
`GET conduct/status`, `POST conduct/sign`, `GET educational-notes`,
`GET weekly-planner`, `GET class-schedule`, `GET exam-schedule` — domain layer,
repository and tolerant DTOs are implemented; UI is reachable only when the
matching `FF_*` flag is set. Field names assumed (see
`school_life_repository_impl.dart`):

* title: `title | name | subject | subject_name | day | course`
* body: `body | content | description | notes | text | message`
* date: `date | published_at | exam_date | starts_at | created_at`
* list payload: the response `data` itself, or the first list found inside it
* conduct: document = `data` of `GET conduct`; status via
  `is_signed | signed | has_signed` and `signed_at | signed_date`
* every other scalar field is shown as a `key: value` chip so nothing is lost

Sibling switch: `SwitchSiblingUseCase` + repository method exist and are
injectable; no UI is exposed until the backend lists siblings in `profile`.

## Release checklist

* [ ] Set real `API_BASE_URL` per flavor; add flavor-specific Firebase configs
      if dev/prod use different projects.
* [ ] `android/app/proguard-rules.pro` must exist (release build has R8 on);
      add keep rules for WebView / Firebase if needed.
* [ ] Android: `key.properties` + keystore; `POST_NOTIFICATIONS` and `INTERNET`
      permissions are already declared.
* [ ] iOS: enable *Push Notifications*, *In-App Purchase* and (optionally)
      *Associated Domains*; `NSCameraUsageDescription` and
      `NSPhotoLibraryUsageDescription` are set; create the non-consumable
      products `com.IbnZaidon.school.course.v2.<courseId>` in App Store Connect.
* [ ] The native application ids are still `com.ibnzaidon.school` (existing
      project, Firebase and signing are tied to them). The StoreKit product
      prefix is configurable in `AppConfig.applePurchaseProductPrefix`.
* [ ] Icons: `dart run flutter_launcher_icons`; native splash if desired.
* [ ] Build with obfuscation:
      `flutter build appbundle --obfuscate --split-debug-info=build/symbols -t lib/main_prod.dart`
      (upload the symbols to Crashlytics).
* [ ] Run `flutter test` and `flutter analyze`.
