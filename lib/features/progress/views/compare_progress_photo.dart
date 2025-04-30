import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heronfit/features/progress/controllers/progress_controller.dart';
import 'package:heronfit/features/progress/models/progress_record.dart';
import 'package:intl/intl.dart';
import 'package:solar_icons/solar_icons.dart'; // Import SolarIcons
import 'package:heronfit/core/theme.dart';

class CompareProgressPhotosWidget extends ConsumerStatefulWidget {
  const CompareProgressPhotosWidget({super.key});

  @override
  ConsumerState<CompareProgressPhotosWidget> createState() =>
      _CompareProgressPhotosWidgetState();
}

class _CompareProgressPhotosWidgetState
    extends ConsumerState<CompareProgressPhotosWidget> {
  ProgressRecord? _selectedPhoto1;
  ProgressRecord? _selectedPhoto2;

  String _formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final progressRecordsAsyncValue = ref.watch(progressRecordsProvider);
    final theme = Theme.of(context);

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
            'Compare Photos',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: HeronFitTheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        body: progressRecordsAsyncValue.when(
          data: (allRecords) {
            final photoRecords =
                allRecords
                    .where((r) => r.photoUrl != null && r.photoUrl!.isNotEmpty)
                    .toList();

            if (photoRecords.length < 2) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'You need at least two progress photos to compare. Add more photos via the Update Weight screen.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildComparisonImage(context, _selectedPhoto1, 1),
                        const SizedBox(width: 8),
                        _buildComparisonImage(context, _selectedPhoto2, 2),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1, thickness: 1),
                _buildPhotoSelector(context, photoRecords),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Error loading photos: $error',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
        ),
      ),
    );
  }

  Widget _buildComparisonImage(
    BuildContext context,
    ProgressRecord? record,
    int position,
  ) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 6,
                    color: theme.shadowColor.withAlpha((255 * 0.1).round()),
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child:
                  record?.photoUrl != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          record!.photoUrl!,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder:
                              (context, error, stackTrace) => Center(
                                child: Icon(
                                  SolarIconsOutline.galleryRemove,
                                  color: theme.hintColor,
                                  size: 40,
                                ),
                              ),
                        ),
                      )
                      : Center(
                        child: Text(
                          'Select Photo $position',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Column(
              children: [
                Text(
                  record != null
                      ? '${record.weight.toStringAsFixed(1)} kg'
                      : '-',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  record != null ? _formatDate(record.date) : '-',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSelector(
    BuildContext context,
    List<ProgressRecord> photoRecords,
  ) {
    final theme = Theme.of(context);
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      color: theme.scaffoldBackgroundColor,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: photoRecords.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final record = photoRecords[index];
          final isSelected1 = _selectedPhoto1?.id == record.id;
          final isSelected2 = _selectedPhoto2?.id == record.id;
          final isSelected = isSelected1 || isSelected2;

          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected1) {
                  _selectedPhoto1 = null;
                } else if (isSelected2) {
                  _selectedPhoto2 = null;
                } else {
                  if (_selectedPhoto1 == null) {
                    _selectedPhoto1 = record;
                  } else if (_selectedPhoto2 == null) {
                    if (_selectedPhoto1?.id != record.id) {
                      _selectedPhoto2 = record;
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cannot select the same photo twice.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  } else {
                    _selectedPhoto1 = record;
                    _selectedPhoto2 = null;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Selected new Photo 1. Tap another photo to select Photo 2.',
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              });
            },
            child: Container(
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? theme.primaryColor : theme.dividerColor,
                  width: isSelected ? 3 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(isSelected ? 5 : 7),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      record.photoUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            color: Colors.grey[300],
                            child: Icon(
                              SolarIconsOutline.galleryRemove,
                              color: Colors.grey[600],
                              size: 30,
                            ),
                          ),
                    ),
                    if (!isSelected)
                      Container(
                        color: Colors.black.withAlpha((255 * 0.3).round()),
                      ),
                    if (isSelected)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          color: theme.primaryColor.withAlpha(
                            (255 * 0.85).round(),
                          ),
                          child: Text(
                            isSelected1 ? 'Photo 1' : 'Photo 2',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
