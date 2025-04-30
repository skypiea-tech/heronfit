import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:heronfit/features/progress/controllers/progress_controller.dart';
import 'package:heronfit/features/progress/widgets/weight_chart_section.dart'; // Reuse existing chart section
import 'package:heronfit/widgets/loading_indicator.dart';
// For min
import 'package:heronfit/features/progress/widgets/progress_photo_list_item.dart'; // Import the new widget
import 'package:heronfit/core/theme.dart';

// State provider for the selected time filter
enum TimeFilter { week, month, allTime }

final timeFilterProvider = StateProvider<TimeFilter>(
  (ref) => TimeFilter.allTime,
);

class ProgressDetailsScreen extends ConsumerWidget {
  const ProgressDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedFilter = ref.watch(timeFilterProvider);
    final progressRecordsAsyncValue = ref.watch(progressRecordsProvider);

    // Get the full list of photo records separately for index calculation
    final allPhotoRecords =
        progressRecordsAsyncValue.whenData((records) {
          return records
              .where((r) => r.photoUrl != null && r.photoUrl!.isNotEmpty)
              .toList();
        }).value ??
        [];

    // Filter records based on the selected time filter (for chart)
    final filteredProgressAsyncValue = progressRecordsAsyncValue.whenData((
      records,
    ) {
      DateTime now = DateTime.now();
      DateTime startDate;
      switch (selectedFilter) {
        case TimeFilter.week:
          startDate = now.subtract(const Duration(days: 7));
          break;
        case TimeFilter.month:
          startDate = DateTime(now.year, now.month - 1, now.day);
          break;
        case TimeFilter.allTime:
        default:
          return records; // No filtering needed for all time
      }
      return records.where((record) => record.date.isAfter(startDate)).toList();
    });

    // Filter photo records based on the selected time filter (for list display)
    final filteredPhotoRecords =
        allPhotoRecords.where((record) {
          DateTime now = DateTime.now();
          DateTime startDate;
          switch (selectedFilter) {
            case TimeFilter.week:
              startDate = now.subtract(const Duration(days: 7));
              break;
            case TimeFilter.month:
              startDate = DateTime(now.year, now.month - 1, now.day);
              break;
            case TimeFilter.allTime:
            default:
              return true; // No date filtering for all time
          }
          return record.date.isAfter(startDate);
        }).toList();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: HeronFitTheme.primary,
              size: 30,
            ),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(
            'Progress Details',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: HeronFitTheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Weight Chart Section with Filtering ---
              Text('Weight Trend', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              SegmentedButton<TimeFilter>(
                segments: const [
                  ButtonSegment(value: TimeFilter.week, label: Text('Week')),
                  ButtonSegment(value: TimeFilter.month, label: Text('Month')),
                  ButtonSegment(value: TimeFilter.allTime, label: Text('All')),
                ],
                selected: {selectedFilter},
                onSelectionChanged: (newSelection) {
                  ref.read(timeFilterProvider.notifier).state =
                      newSelection.first;
                },
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: theme.colorScheme.primary.withAlpha(
                    (255 * 0.2).round(),
                  ),
                  selectedForegroundColor: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              // Pass the *filtered* data to the chart section
              WeightChartSection(
                progressAsyncValue: filteredProgressAsyncValue,
              ),
              const SizedBox(height: 24),

              // --- Progress Photos Section ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Progress Photos', style: theme.textTheme.titleLarge),
                  if (allPhotoRecords
                      .isNotEmpty) // Show "See All" based on all photos
                    TextButton(
                      onPressed:
                          () => context.push(AppRoutes.progressPhotoList),
                      child: const Text('See All'),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              progressRecordsAsyncValue.when(
                // Still use original async value for loading/error states
                data: (allRecordsOriginal) {
                  // Use the time-filtered photo list for display
                  if (filteredPhotoRecords.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Text(
                          'No progress photos found for this period.',
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredPhotoRecords.length,
                    itemBuilder: (context, index) {
                      final record = filteredPhotoRecords[index];
                      // Find the original index in the unfiltered list for navigation
                      final originalIndex = allPhotoRecords.indexWhere(
                        (r) => r.id == record.id,
                      );

                      // Use the reusable ProgressPhotoListItem widget
                      return ProgressPhotoListItem(
                        record: record,
                        index: originalIndex, // Pass the original index
                      );
                    },
                  );
                },
                loading: () => const Center(child: LoadingIndicator()),
                error:
                    (error, stack) =>
                        Center(child: Text('Error loading photos: $error')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
