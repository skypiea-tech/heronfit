import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heronfit/core/theme.dart';
import 'package:heronfit/features/workout/controllers/workout_providers.dart';
import 'package:heronfit/features/workout/models/workout_model.dart';
import 'package:heronfit/features/workout/widgets/workout_card.dart';
import 'package:heronfit/widgets/loading_indicator.dart';
import 'package:solar_icons/solar_icons.dart';

// Provider to manage the selected category filter
final selectedCategoryProvider = StateProvider<String>((ref) => 'For You');

// Provider to fetch workouts based on the selected category
final recommendedWorkoutsByCategoryProvider =
    FutureProvider.autoDispose<List<Workout>>((ref) async {
      final selectedCategory = ref.watch(selectedCategoryProvider);
      final recommendationService = ref.watch(
        workoutRecommendationServiceProvider,
      );

      if (selectedCategory == 'For You') {
        return recommendationService.getAllRecommendedWorkouts();
      } else {
        return recommendationService.getPremadeWorkouts(selectedCategory);
      }
    });

class RecommendedWorkoutsScreen extends ConsumerWidget {
  const RecommendedWorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final workoutsAsync = ref.watch(recommendedWorkoutsByCategoryProvider);
    final categories = [
      'For You',
      'Gain Muscle',
      'Lose Weight',
      'Overall Fitness',
    ];

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
            'Recommended Workouts',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: HeronFitTheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: HeronFitTheme.bgLight,
        body: Column(
          children: [
            // Category Filter Chips/Buttons
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              child: SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder:
                      (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = category == selectedCategory;
                    return ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          ref.read(selectedCategoryProvider.notifier).state =
                              category;
                        }
                      },
                      selectedColor: HeronFitTheme.primary.withOpacity(0.1),
                      backgroundColor: HeronFitTheme.bgSecondary,
                      labelStyle: TextStyle(
                        color:
                            isSelected
                                ? HeronFitTheme.primary
                                : HeronFitTheme.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color:
                              isSelected
                                  ? HeronFitTheme.primary
                                  : Colors.transparent,
                        ),
                      ),
                      showCheckmark: false,
                    );
                  },
                ),
              ),
            ),
            // Workout List
            Expanded(
              child: workoutsAsync.when(
                loading: () => const Center(child: LoadingIndicator()),
                error:
                    (error, stack) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Error loading workouts: $error',
                          style: TextStyle(color: HeronFitTheme.error),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                data: (workouts) {
                  if (workouts.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              SolarIconsOutline.notebookMinimalistic,
                              size: 64,
                              color: HeronFitTheme.textMuted,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Workouts Found',
                              style: HeronFitTheme.textTheme.titleMedium
                                  ?.copyWith(
                                    color: HeronFitTheme.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No workouts available for the "$selectedCategory" category right now.',
                              style: HeronFitTheme.textTheme.bodyMedium
                                  ?.copyWith(color: HeronFitTheme.textMuted),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    itemCount: workouts.length,
                    itemBuilder: (context, index) {
                      final workout = workouts[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        // Wrap with GestureDetector if needed for navigation
                        child: WorkoutCard(workout: workout),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
