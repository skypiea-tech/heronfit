import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:heronfit/features/workout/models/workout_model.dart';
import '../../../core/theme.dart';
import '../controllers/workout_providers.dart'; // Import providers

// Convert to ConsumerWidget
class WorkoutHistoryScreen extends ConsumerWidget {
  const WorkoutHistoryScreen({super.key});

  static String routePath = '/workoutHistory';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the providers
    final workoutHistoryAsync = ref.watch(workoutHistoryProvider);
    final workoutStatsAsync = ref.watch(workoutStatsProvider);
    final formatDuration = ref.watch(formatDurationProvider);

    return SafeArea(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          backgroundColor: HeronFitTheme.bgLight,
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
              'Workout History',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: HeronFitTheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Use AsyncValue.when to handle loading/error/data states
          body: workoutHistoryAsync.when(
            loading:
                () => Center(
                  child: CircularProgressIndicator(
                    color: HeronFitTheme.primary,
                  ),
                ),
            error:
                (error, stackTrace) =>
                    Center(child: Text('Error loading history: $error')),
            data:
                (workouts) => _buildBody(
                  context,
                  ref,
                  workouts,
                  workoutStatsAsync,
                  formatDuration,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    List<Workout> workouts,
    AsyncValue<Map<String, dynamic>> workoutStatsAsync,
    String Function(Duration) formatDuration,
  ) {
    if (workouts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.fitness_center,
              size: 64,
              color: HeronFitTheme.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'No workout history yet',
              style: HeronFitTheme.textTheme.titleMedium?.copyWith(
                color: HeronFitTheme.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete a workout to see it here',
              style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                color: HeronFitTheme.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            workoutStatsAsync.when(
              loading: () => const Center(child: Text('Loading stats...')),
              error: (err, st) => Text('Error loading stats: $err'),
              data: (stats) => _buildStatsSection(stats, formatDuration),
            ),
            const SizedBox(height: 24),
            Text(
              'Recent Workouts',
              style: HeronFitTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: HeronFitTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildWorkoutList(ref, workouts, formatDuration),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(
    Map<String, dynamic> stats,
    String Function(Duration) formatDuration,
  ) {
    int totalWorkouts = stats['total_workouts'] ?? 0;
    int totalDurationSeconds = stats['total_duration'] ?? 0;
    int totalExercises = stats['total_exercises_performed'] ?? 0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: HeronFitTheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Progress',
            style: HeronFitTheme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Workouts', totalWorkouts.toString()),
              _buildStatItem(
                'Time',
                formatDuration(Duration(seconds: totalDurationSeconds)),
              ),
              _buildStatItem('Exercises', totalExercises.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: HeronFitTheme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: HeronFitTheme.textTheme.bodySmall?.copyWith(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutList(
    WidgetRef ref,
    List<Workout> workouts,
    String Function(Duration) formatDuration,
  ) {
    final formatDate = ref.watch(formatDateProvider);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: workouts.length,
      itemBuilder: (context, index) {
        final workout = workouts[index];
        final dateStr = formatDate(workout.timestamp);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          workout.name,
                          style: HeronFitTheme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: HeronFitTheme.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateStr,
                        style: HeronFitTheme.textTheme.bodySmall?.copyWith(
                          color: HeronFitTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${workout.exercises.length} exercises • ${formatDuration(workout.duration)}',
                    style: HeronFitTheme.textTheme.bodyMedium,
                  ),
                  if (workout.exercises.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children:
                          workout.exercises
                              .map(
                                (exercise) => Chip(
                                  label: Text(exercise.name),
                                  backgroundColor: HeronFitTheme.bgLight,
                                  side: BorderSide(
                                    color: HeronFitTheme.primary.withOpacity(
                                      0.2,
                                    ),
                                  ),
                                  labelStyle: const TextStyle(fontSize: 12),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
