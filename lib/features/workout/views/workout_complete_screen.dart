import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:heronfit/core/theme.dart';
import 'package:heronfit/features/workout/models/workout_model.dart';
import 'package:heronfit/features/workout/models/exercise_model.dart'; // Import Exercise
import 'package:heronfit/features/workout/models/set_data_model.dart'; // Import SetData
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:heronfit/features/workout/controllers/workout_providers.dart'; // Import providers

// Convert to ConsumerWidget
class WorkoutCompleteScreen extends ConsumerWidget {
  final Workout workout;
  final List<Exercise> detailedExercises; // Receive detailed exercises

  const WorkoutCompleteScreen({
    super.key,
    required this.workout,
    required this.detailedExercises,
  });

  // Helper function to format sets and reps, considering only completed sets
  String _formatSetsAndReps(List<SetData> sets) {
    final completedSets =
        sets.where((s) => s.completed).toList(); // Filter completed sets

    if (completedSets.isEmpty) {
      return 'No sets completed'; // Updated message
    }

    // Try to group similar completed sets
    final firstSet = completedSets.first;
    int count = 0;
    bool allSame = true;
    for (final set in completedSets) {
      if (set.kg == firstSet.kg && set.reps == firstSet.reps) {
        count++;
      } else {
        allSame = false;
        break; // Exit loop if sets vary
      }
    }

    if (allSame) {
      // Format like "3 x 8 @ 50kg" or "3 x 8"
      return '$count x ${firstSet.reps} reps${firstSet.kg > 0 ? ' @ ${firstSet.kg}kg' : ''}';
    } else {
      // If completed sets vary, provide a summary like "3 sets completed"
      return '${completedSets.length} sets completed'; // Updated fallback
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateFormat dateFormat = DateFormat('MMMM d, yyyy'); // Date formatter
    final String formattedDate = dateFormat.format(workout.timestamp);
    final String durationString =
        '${workout.duration.inMinutes} min ${workout.duration.inSeconds.remainder(60)} sec';

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
            'Workout Complete',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: HeronFitTheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: HeronFitTheme.bgLight,
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  // Make content scrollable
                  child: Column(
                    children: [
                      // --- Image and Congrats Message ---
                      Container(
                        width: double.infinity,
                        height: 180.0, // Adjusted height
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(
                            'assets/images/workout_complete.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        'You\'re One Step Closer to Your Goals!', // Corrected string literal
                        style: HeronFitTheme.textTheme.titleMedium?.copyWith(
                          // Slightly larger
                          color: HeronFitTheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'You crushed it today! Keep up the momentum.',
                        textAlign: TextAlign.center,
                        style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                          // Slightly larger
                          color: HeronFitTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 24.0),

                      // --- Workout Summary Card ---
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: HeronFitTheme.bgSecondary,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 10.0, // Reduced blur
                              color: HeronFitTheme.dropShadow.withAlpha(
                                (255 * 0.5).round(),
                              ), // Use withAlpha
                              offset: const Offset(0.0, 4.0), // Reduced offset
                            ),
                          ],
                          borderRadius: BorderRadius.circular(
                            12.0,
                          ), // More rounded
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(
                            16.0,
                          ), // Adjusted padding
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                workout.name,
                                style: HeronFitTheme.textTheme.titleMedium
                                    ?.copyWith(
                                      color: HeronFitTheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 12.0),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Duration: $durationString',
                                    style: HeronFitTheme.textTheme.bodyMedium
                                        ?.copyWith(
                                          color: HeronFitTheme.textPrimary,
                                        ),
                                  ),
                                  Text(
                                    'Date: $formattedDate',
                                    style: HeronFitTheme.textTheme.bodyMedium
                                        ?.copyWith(
                                          color: HeronFitTheme.textPrimary,
                                        ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16.0),
                              Text(
                                'Exercises Performed:',
                                style: HeronFitTheme.textTheme.labelLarge
                                    ?.copyWith(
                                      color: HeronFitTheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8.0),
                              // Display detailed exercises with sets/reps
                              // Filter exercises to show only those with completed sets on the summary
                              () {
                                // Corrected filtering syntax
                                final performedExercises =
                                    detailedExercises
                                        .where(
                                          (ex) =>
                                              ex.sets.any((s) => s.completed),
                                        )
                                        .toList();

                                if (performedExercises.isEmpty) {
                                  return Text(
                                    'No exercises completed.', // Updated message
                                    style: HeronFitTheme.textTheme.bodyMedium
                                        ?.copyWith(
                                          color: HeronFitTheme.textMuted,
                                        ),
                                  );
                                } else {
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(), // Disable inner scroll
                                    itemCount:
                                        performedExercises
                                            .length, // Use filtered list
                                    itemBuilder: (context, index) {
                                      final exercise =
                                          performedExercises[index]; // Use filtered list
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4.0,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              // Allow text wrapping
                                              child: Text(
                                                exercise.name,
                                                style: HeronFitTheme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color:
                                                          HeronFitTheme
                                                              .textPrimary,
                                                    ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Text(
                                              // Pass only completed sets to the formatter
                                              // Note: _formatSetsAndReps IS used here, analyzer error might be stale
                                              _formatSetsAndReps(
                                                exercise.sets
                                                    .where((s) => s.completed)
                                                    .toList(),
                                              ),
                                              style: HeronFitTheme
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color:
                                                        HeronFitTheme.textMuted,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                }
                              }(), // Immediately invoke the builder function
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- Action Buttons ---
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () async {
                  // 1. Save the workout as a template (using completed exercise data)
                  final storageService = ref.read(
                    workoutStorageServiceProvider,
                  ); // Use ref.read
                  bool savedSuccessfully = false;

                  // Filter exercises again for the template, ensuring we only save names of performed exercises
                  final performedExercises =
                      detailedExercises
                          .where((ex) => ex.sets.any((s) => s.completed))
                          .toList();

                  // Only attempt to save if at least one exercise was performed
                  if (performedExercises.isNotEmpty) {
                    try {
                      // Create a new Workout object specifically for saving as a template
                      // Use the actual Exercise objects that were performed
                      final templateToSave = Workout(
                        id:
                            UniqueKey()
                                .toString(), // Generate new ID for template
                        name:
                            workout
                                .name, // Use the name from the completed session
                        exercises:
                            performedExercises, // Pass the List<Exercise> of performed exercises
                        createdAt:
                            DateTime.now(), // Set the creation timestamp for sorting templates
                        timestamp:
                            DateTime.now(), // Added timestamp for template creation
                        duration:
                            Duration
                                .zero, // Add required duration, 0 for templates
                      );
                      await storageService.saveWorkout(
                        templateToSave,
                      ); // Assuming this saves as a template
                      savedSuccessfully = true;
                    } catch (e) {
                      // Show error message immediately if save fails
                      if (!context.mounted) return; // Add mounted check
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error saving template: $e')),
                      );
                    }
                  } else {
                    // Optionally inform the user nothing was saved as no exercises were completed
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Template not saved (no exercises completed).',
                        ),
                      ),
                    );
                  }

                  // Show success message only if saved successfully
                  if (savedSuccessfully) {
                    if (!context.mounted) return; // Add mounted check
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Workout saved as template!'),
                      ),
                    );
                    // Invalidate the provider to refresh the list on the workout screen
                    ref.invalidate(savedWorkoutsProvider);
                  }

                  // 2. Navigate home regardless of save success/failure
                  if (!context.mounted) return; // Add mounted check
                  context.go(AppRoutes.home);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48.0),
                  backgroundColor: HeronFitTheme.primary,
                  foregroundColor: Colors.white, // Text color
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      12.0,
                    ), // Match card rounding
                  ),
                  textStyle: HeronFitTheme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Save as Template & Go Home'), // Updated text
              ),
              const SizedBox(height: 12.0), // Space between buttons
              OutlinedButton(
                // Use OutlinedButton for secondary action
                onPressed: () {
                  // Simply navigate home without saving
                  context.go(AppRoutes.home);
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48.0),
                  foregroundColor: HeronFitTheme.primary, // Text color
                  side: BorderSide(
                    color: HeronFitTheme.primary,
                  ), // Border color
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      12.0,
                    ), // Match card rounding
                  ),
                  textStyle: HeronFitTheme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Go Home'), // New button
              ),
            ],
          ),
        ),
      ),
    );
  }
}
