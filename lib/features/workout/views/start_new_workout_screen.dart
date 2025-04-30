import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heronfit/features/workout/controllers/workout_providers.dart';
import 'package:heronfit/features/workout/models/exercise_model.dart';
import 'package:heronfit/features/workout/models/workout_model.dart';
import 'package:heronfit/core/theme.dart';
import 'package:heronfit/widgets/exercise_card_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/router/app_routes.dart';

class StartNewWorkoutScreen extends ConsumerWidget {
  final Workout? initialWorkout;
  const StartNewWorkoutScreen({super.key, this.initialWorkout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutState = ref.watch(activeWorkoutProvider(initialWorkout));
    final workoutNotifier = ref.read(
      activeWorkoutProvider(initialWorkout).notifier,
    );

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
            'Start Workout',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: HeronFitTheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: HeronFitTheme.bgLight,
        body: SingleChildScrollView(
          primary: false,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      key: ValueKey('workout_name_${workoutState.id}'),
                      initialValue: workoutState.name,
                      textCapitalization: TextCapitalization.sentences,
                      obscureText: false,
                      style: HeronFitTheme.textTheme.titleMedium?.copyWith(
                        color: HeronFitTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter workout name (e.g., Leg Day)',
                        hintStyle: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                          color: HeronFitTheme.textMuted.withAlpha(179),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: HeronFitTheme.textMuted.withAlpha(128),
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: HeronFitTheme.primary,
                            width: 2.0,
                          ),
                        ),
                        errorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: HeronFitTheme.error,
                            width: 1.5,
                          ),
                        ),
                        focusedErrorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: HeronFitTheme.error,
                            width: 2.0,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 0.0,
                        ),
                      ),
                      onChanged:
                          (value) => workoutNotifier.setWorkoutName(value),
                      onFieldSubmitted:
                          (_) => FocusScope.of(context).nextFocus(),
                    ),
                    const SizedBox(height: 8.0),
                    Align(
                      alignment: const AlignmentDirectional(-1.0, 0.0),
                      child: Text(
                        _formatDuration(workoutState.duration),
                        style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                          color: HeronFitTheme.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
                ListView.separated(
                  padding: EdgeInsets.zero,
                  primary: false,
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: workoutState.exercises.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12.0),
                  itemBuilder: (context, index) {
                    final exercise = workoutState.exercises[index];
                    return ExerciseCard(
                      key: ValueKey(exercise.id),
                      exercise: exercise,
                      workoutId: workoutState.id,
                      onAddSet: () {
                        workoutNotifier.addSet(exercise);
                      },
                      onUpdateSetData: (setIndex, {kg, reps, completed}) {
                        workoutNotifier.updateSetData(
                          exercise,
                          setIndex,
                          kg: kg,
                          reps: reps,
                          completed: completed,
                        );
                      },
                      onRemoveSet: (setIndex) {
                        workoutNotifier.removeSet(exercise, setIndex);
                      },
                      onShowDetails: () {
                        context.push(
                          AppRoutes.exerciseDetails,
                          extra: exercise,
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 24.0),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton.icon(
                      label: const Text('Add Exercise'),
                      onPressed: () async {
                        final selectedExercise = await context.push<Exercise>(
                          AppRoutes.workoutAddExercise,
                        );
                        if (selectedExercise != null) {
                          workoutNotifier.addExercise(selectedExercise);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40.0),
                        foregroundColor: HeronFitTheme.primary,
                        side: BorderSide(
                          color: HeronFitTheme.primary.withAlpha(180),
                        ),
                        textStyle: HeronFitTheme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () async {
                        final completedWorkout =
                            await workoutNotifier.finishWorkout();

                        final finalWorkoutState = ref.read(
                          activeWorkoutProvider(initialWorkout),
                        );
                        final detailedExercises = finalWorkoutState.exercises;

                        if (!context.mounted) return;

                        if (completedWorkout != null) {
                          context.pushReplacement(
                            AppRoutes.workoutComplete,
                            extra: {
                              'workout': completedWorkout,
                              'detailedExercises': detailedExercises,
                            },
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Error finishing workout. Please try again.',
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 44.0),
                        backgroundColor: HeronFitTheme.primary,
                        foregroundColor: Colors.white,
                        textStyle: HeronFitTheme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Finish Workout'),
                    ),
                    const SizedBox(height: 4.0),
                    ElevatedButton(
                      onPressed: () {
                        workoutNotifier.cancelWorkout();
                        context.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 44.0),
                        backgroundColor: HeronFitTheme.error,
                        foregroundColor: Colors.white,
                        textStyle: HeronFitTheme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Cancel Workout'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
