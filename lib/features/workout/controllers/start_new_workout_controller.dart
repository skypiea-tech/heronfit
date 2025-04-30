import 'dart:async';
import 'package:heronfit/features/workout/models/exercise_model.dart';
import 'package:heronfit/features/workout/models/workout_model.dart';
import 'package:heronfit/features/workout/models/set_data_model.dart';

class StartNewWorkoutController {
  Workout? workout;
  String workoutName = '';
  String workoutNotes = '';
  List<Exercise> exercises = [];
  int duration = 0;
  late Timer _timer;

  // Add StreamController for real-time duration updates
  final StreamController<int> _durationController =
      StreamController<int>.broadcast();
  Stream<int> get durationStream => _durationController.stream;

  StartNewWorkoutController({required this.workout}) {
    workoutName = workout?.name ?? 'New Workout';
  }

  void setWorkoutName(String name) {
    workoutName = name;
  }

  int get workoutDurationInMinutes =>
      duration ~/ 60; // Convert seconds to minutes

  void setWorkoutNotes(String notes) {
    workoutNotes = notes;
  }

  void addExercise(Exercise exercise) {
    exercises.add(exercise);
  }

  void addSet(Exercise exercise) {
    exercise.sets.add(SetData(kg: 0, reps: 0, completed: false));
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      duration++;
      // Add the updated duration to the stream
      _durationController.add(duration);
    });
  }

  void stopTimer() {
    _timer.cancel();
  }

  @override
  void dispose() {
    _timer.cancel();
    _durationController.close(); // Close the stream controller when disposing
  }
}
