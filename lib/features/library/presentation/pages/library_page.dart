import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ibnzaidon/core/bloc/paged_bloc.dart';
import 'package:ibnzaidon/core/di/injector.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/design_system/components/app_tabs.dart';
import 'package:ibnzaidon/design_system/components/layout_helpers.dart';
import 'package:ibnzaidon/design_system/components/skeleton.dart';
import 'package:ibnzaidon/design_system/components/state_views.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:ibnzaidon/features/library/domain/entities/library_item.dart';
import 'package:ibnzaidon/features/library/presentation/bloc/library_bloc.dart';
import 'package:ibnzaidon/features/library/presentation/widgets/library_item_card.dart';
import 'package:ibnzaidon/shared/presentation/paged_bloc_view.dart';

/// Library tab: previous-year exams, question banks and worksheets.
class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  LibraryKind _kind = LibraryKind.previousExams;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.libraryTitle)),
      body: ContentConstraint(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.gutter,
                vertical: AppSpacing.sm,
              ),
              child: AppSegmentedControl<LibraryKind>(
                segments: {
                  LibraryKind.previousExams: l10n.libraryPreviousExams,
                  LibraryKind.questionBanks: l10n.libraryQuestionBanks,
                  LibraryKind.worksheets: l10n.libraryWorksheets,
                },
                selected: _kind,
                onChanged: (value) => setState(() => _kind = value),
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: LibraryKind.values.indexOf(_kind),
                children: [
                  for (final kind in LibraryKind.values)
                    _LibraryList(kind: kind),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryList extends StatelessWidget {
  const _LibraryList({required this.kind});

  final LibraryKind kind;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<LibraryBloc>(param1: kind)
            ..add(const PagedStarted<LibraryQuery>()),
      child: const Column(
        children: [
          _Filters(),
          Expanded(child: _Results()),
        ],
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters();

  static const _yearsBack = 8;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bloc = context.read<LibraryBloc>();
    final currentYear = DateTime.now().year;
    return BlocBuilder<LibraryBloc, PagedState<LibraryItem, LibraryQuery>>(
      buildWhen: (a, b) => a.query != b.query || a.items != b.items,
      builder: (context, state) {
        final subjects = {
          for (final item in state.items)
            if (item.subject != null) item.subject!.id: item.subject!.name,
        };
        return Column(
          children: [
            Padding(
              padding: AppSpacing.pagePadding,
              child: TextField(
                textInputAction: TextInputAction.search,
                onChanged: (value) => bloc.add(
                  PagedQueryChanged(
                    state.query.copyWith(search: value),
                    debounce: true,
                  ),
                ),
                decoration: InputDecoration(
                  hintText: l10n.librarySearchHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                ),
              ),
            ),
            SizedBox(
              height: AppSizes.touchTarget + AppSpacing.sm,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: AppSpacing.pagePadding,
                children: [
                  for (
                    var year = currentYear;
                    year > currentYear - _yearsBack;
                    year--
                  )
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        end: AppSpacing.sm,
                      ),
                      child: ChoiceChip(
                        label: Text('$year'),
                        selected: state.query.year == year,
                        onSelected: (selected) => bloc.add(
                          PagedQueryChanged(
                            selected
                                ? state.query.copyWith(year: year)
                                : state.query.copyWith(clearYear: true),
                          ),
                        ),
                      ),
                    ),
                  for (final entry in subjects.entries)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        end: AppSpacing.sm,
                      ),
                      child: ChoiceChip(
                        label: Text(entry.value),
                        selected: state.query.subjectId == entry.key,
                        onSelected: (selected) => bloc.add(
                          PagedQueryChanged(
                            selected
                                ? state.query.copyWith(subjectId: entry.key)
                                : state.query.copyWith(clearSubject: true),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Results extends StatelessWidget {
  const _Results();

  @override
  Widget build(BuildContext context) {
    return PagedBlocView<LibraryBloc, LibraryItem, LibraryQuery>(
      gridColumns: context.isTablet ? context.gridColumns - 1 : null,
      gridChildAspectRatio: 1.6,
      skeletonBuilder: (_) => const SkeletonRow(),
      emptyBuilder: (_) => EmptyState(
        icon: Icons.folder_off_rounded,
        title: context.l10n.libraryEmptyTitle,
      ),
      itemBuilder: (context, item, _) => LibraryItemCard(item: item),
    );
  }
}
