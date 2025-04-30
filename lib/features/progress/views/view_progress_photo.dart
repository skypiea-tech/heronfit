import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/router/app_routes.dart'; // Import AppRoutes
import 'package:heronfit/core/theme.dart'; // Import HeronFitTheme
import 'package:heronfit/features/progress/controllers/progress_controller.dart';
import 'package:intl/intl.dart';
import 'package:solar_icons/solar_icons.dart'; // Import SolarIcons
import 'dart:ui'; // Import dart:ui for PointMode

class ViewProgressPhotosWidget extends ConsumerStatefulWidget {
  final int? initialIndex; // Add optional initial index parameter

  const ViewProgressPhotosWidget({
    this.initialIndex,
    super.key,
  }); // Update constructor

  @override
  ConsumerState<ViewProgressPhotosWidget> createState() =>
      _ViewProgressPhotosWidgetState();
}

class _ViewProgressPhotosWidgetState
    extends ConsumerState<ViewProgressPhotosWidget> {
  int _selectedPhotoIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize the selected index from the widget parameter if provided
    _selectedPhotoIndex = widget.initialIndex ?? 0;
  }

  String _formatDate(DateTime date) {
    // Format date as "15 October 2024"
    return DateFormat('dd MMMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
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
            'View Photo',
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

            // Ensure initial index is valid after data loads
            if (_selectedPhotoIndex >= photoRecords.length &&
                photoRecords.isNotEmpty) {
              _selectedPhotoIndex = photoRecords.length - 1;
            }
            if (photoRecords.isEmpty) {
              _selectedPhotoIndex = 0; // Reset if list becomes empty
            }

            if (photoRecords.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'No progress photos found. Add photos via the Update Weight screen.',
                    style: theme.textTheme.labelLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            // Ensure index is valid before accessing the record
            if (_selectedPhotoIndex < 0 ||
                _selectedPhotoIndex >= photoRecords.length) {
              // Handle invalid index, maybe show first photo or an error
              // For now, default to 0 if possible
              _selectedPhotoIndex = photoRecords.isNotEmpty ? 0 : -1;
              if (_selectedPhotoIndex == -1) {
                return const Center(child: Text('Error: Invalid photo index.'));
              }
            }

            final selectedRecord = photoRecords[_selectedPhotoIndex];

            return Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                16,
              ), // Adjust padding
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    flex: 5, // Give more space to the image
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          // Lighter background for the image container
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(
                            12,
                          ), // Rounded corners
                          boxShadow: [
                            // Subtle shadow
                            BoxShadow(
                              blurRadius: 6,
                              color: theme.shadowColor.withAlpha(
                                (255 * 0.1).round(),
                              ),
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            12,
                          ), // Match container
                          child: Image.network(
                            selectedRecord.photoUrl!,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                            errorBuilder:
                                (context, error, stackTrace) => const Center(
                                  child: Icon(
                                    Icons.error,
                                    color: Colors.red,
                                    size: 50,
                                  ),
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // --- Metadata and Actions Section (Reordered to match Figma) ---
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: Icon(
                                SolarIconsOutline.gallery, // Use SolarIcons
                                color: theme.primaryColor, // Use primary color
                                size: 24,
                              ),
                              tooltip: 'View All Photos',
                              onPressed: () {
                                // Use AppRoutes constant
                                context.push(AppRoutes.progressPhotoList);
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                SolarIconsOutline
                                    .squareTransferVertical, // Use SolarIcons
                                color: theme.primaryColor, // Use primary color
                                size: 24,
                              ),
                              tooltip: 'Compare Photos',
                              onPressed: () {
                                // Use AppRoutes constant
                                context.push(
                                  AppRoutes.progressPhotoCompare,
                                ); // Corrected route
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${selectedRecord.weight.toStringAsFixed(1)} kg', // Format weight
                          style: theme.textTheme.titleMedium?.copyWith(
                            // Use titleMedium
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold, // Make bold
                          ),
                        ),
                        Text(
                          _formatDate(
                            selectedRecord.date,
                          ), // Use formatted date
                          style: theme.textTheme.bodySmall?.copyWith(
                            // Use bodySmall
                            color: theme.hintColor, // Use hint color
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // --- Timeline/Thumbnail Slider ---
                  // Simple line indicator (optional, visual flair)
                  Container(
                    height: 4,
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: CustomPaint(
                      painter: TimelinePainter(
                        selectedIndex: _selectedPhotoIndex,
                        itemCount: photoRecords.length,
                        color: theme.primaryColor,
                        backgroundColor: theme.dividerColor,
                      ),
                    ),
                  ),
                  // Thumbnail List
                  SizedBox(
                    height: 70, // Adjust height for thumbnails
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      scrollDirection: Axis.horizontal,
                      itemCount: photoRecords.length,
                      separatorBuilder:
                          (_, __) =>
                              const SizedBox(width: 12), // Increase spacing
                      itemBuilder: (context, index) {
                        final record = photoRecords[index];
                        final isSelected = _selectedPhotoIndex == index;

                        return GestureDetector(
                          // Use GestureDetector instead of InkWell
                          onTap: () {
                            setState(() {
                              _selectedPhotoIndex = index;
                            });
                          },
                          child: Container(
                            width: 70, // Square thumbnails
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? theme.primaryColor
                                        : theme
                                            .dividerColor, // Use divider color for non-selected
                                width:
                                    isSelected
                                        ? 3
                                        : 1, // Thicker border if selected
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                isSelected ? 5 : 7, // Inner radius adjust
                              ),
                              child: Image.network(
                                record.photoUrl!,
                                fit: BoxFit.cover,
                                loadingBuilder: (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    // Add background for loading
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder:
                                    (context, error, stackTrace) => Container(
                                      color: Colors.grey[300],
                                      child: Icon(
                                        SolarIconsOutline
                                            .galleryRemove, // Use SolarIcon
                                        color: Colors.grey[600],
                                        size: 30,
                                      ),
                                    ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Error loading progress photos: $error',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
        ),
      ),
    );
  }
}

// Custom Painter for the simple timeline indicator
class TimelinePainter extends CustomPainter {
  final int selectedIndex;
  final int itemCount;
  final Color color;
  final Color backgroundColor;

  TimelinePainter({
    required this.selectedIndex,
    required this.itemCount,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintBg =
        Paint()
          ..color = backgroundColor
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;

    final paintFg =
        Paint()
          ..color = color
          ..strokeWidth =
              4 // Make dot slightly thicker
          ..strokeCap = StrokeCap.round;

    // Draw background line
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paintBg,
    );

    // Draw selected dot
    if (itemCount > 0) {
      final double dx =
          (size.width / (itemCount > 1 ? itemCount - 1 : 1)) * selectedIndex;
      // Clamp dx to prevent drawing outside bounds if itemCount is 1
      final double clampedDx = dx.clamp(0.0, size.width);
      canvas.drawPoints(
        PointMode.points, // Now defined
        [Offset(clampedDx, size.height / 2)],
        paintFg,
      );
    }
  }

  @override
  bool shouldRepaint(covariant TimelinePainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.itemCount != itemCount ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
