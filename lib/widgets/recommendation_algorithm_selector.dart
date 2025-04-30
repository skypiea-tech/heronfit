import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Ensure this path is correct
import 'package:heronfit/core/theme.dart';
import 'package:heronfit/features/workout/controllers/workout_providers.dart'; // Assuming service provider is here
import 'package:heronfit/widgets/loading_indicator.dart';

// Make the provider public
final selectedAlgorithmProvider = StateProvider<String?>((ref) => null);

class RecommendationAlgorithmSelector extends ConsumerWidget {
  // Use super parameters for key
  const RecommendationAlgorithmSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendationService = ref.watch(
      workoutRecommendationServiceProvider,
    );
    final availableAlgorithmsAsync = ref.watch(availableAlgorithmsProvider);
    final selectedAlgorithm = ref.watch(selectedAlgorithmProvider);

    return availableAlgorithmsAsync.when(
      data: (algorithms) {
        // Initialize the provider if null and algorithms are available
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (selectedAlgorithm == null && algorithms.isNotEmpty) {
            ref.read(selectedAlgorithmProvider.notifier).state =
                algorithms.first;
          }
        });

        if (algorithms.isEmpty) {
          return const Text('No recommendation algorithms available.');
        }

        return DropdownButtonFormField<String>(
          value: selectedAlgorithm,
          decoration: InputDecoration(
            labelText: 'Recommendation Algorithm',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            filled: true,
            fillColor: HeronFitTheme.bgSecondary,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
          ),
          items:
              algorithms.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              ref.read(selectedAlgorithmProvider.notifier).state = newValue;
              // Call the service method to potentially save the preference
              recommendationService.setAlgorithm(newValue);
            }
          },
          // Style the dropdown menu itself
          dropdownColor: HeronFitTheme.bgSecondary,
          style: HeronFitTheme.textTheme.bodyMedium,
          icon: const Icon(Icons.arrow_drop_down, color: HeronFitTheme.primary),
        );
      },
      loading: () => const LoadingIndicator(),
      error:
          (error, stack) => Text(
            'Error loading algorithms: $error',
            style: const TextStyle(color: HeronFitTheme.error),
          ),
    );
  }
}

// Provider to fetch available algorithms
final availableAlgorithmsProvider = FutureProvider<List<String>>((ref) async {
  final recommendationService = ref.watch(workoutRecommendationServiceProvider);
  return recommendationService.getAvailableAlgorithms();
});
