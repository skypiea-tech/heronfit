import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
// Import GoRouter
// Import AppRoutes
import 'package:heronfit/features/progress/controllers/progress_controller.dart'; // Import controller
// Import model
import 'package:heronfit/features/progress/widgets/progress_photo_list_item.dart'; // Import the reusable item widget
// Import SolarIcons
import 'package:heronfit/core/theme.dart'; // Import HeronFitTheme

class ProgressPhotosListWidget extends ConsumerWidget {
  const ProgressPhotosListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressRecordsAsyncValue = ref.watch(progressRecordsProvider);
    final theme = Theme.of(context); // Get theme

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
            'Progress Photos',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: HeronFitTheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Padding(
            padding: const EdgeInsets.all(16), // Consistent padding
            child: progressRecordsAsyncValue.when(
              data: (records) {
                final photoRecords =
                    records
                        .where(
                          (r) => r.photoUrl != null && r.photoUrl!.isNotEmpty,
                        )
                        .toList();

                if (photoRecords.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'No progress photos found. Add some via Update Weight screen.',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.vertical,
                  itemCount: photoRecords.length,
                  itemBuilder: (context, index) {
                    final record = photoRecords[index];
                    // Use the reusable ProgressPhotoListItem widget
                    return ProgressPhotoListItem(
                      record: record,
                      index:
                          index, // Pass the index directly as this list is not filtered
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stack) =>
                      Center(child: Text('Error loading photos: $error')),
            ),
          ),
        ),
      ),
    );
  }
}
