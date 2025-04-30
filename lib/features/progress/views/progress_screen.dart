import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heronfit/features/progress/controllers/progress_controller.dart';
import 'package:heronfit/features/progress/widgets/goals_section.dart';
import 'package:heronfit/features/progress/widgets/weight_chart_section.dart';
import 'package:heronfit/features/progress/widgets/weight_log_section.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressRecordsAsyncValue = ref.watch(progressRecordsProvider);
    final goalAsyncValue = ref.watch(userGoalProvider);
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(progressRecordsProvider);
            ref.invalidate(userGoalProvider);
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GoalsSection(goalAsyncValue: goalAsyncValue),
                const SizedBox(height: 24),
                WeightChartSection(
                  progressAsyncValue: progressRecordsAsyncValue,
                ),
                const SizedBox(height: 24),
                WeightLogSection(progressAsyncValue: progressRecordsAsyncValue),
                // const SizedBox(height: 24),
                // const MonthlyStatsSection(),
                // const SizedBox(height: 24),
                // const PersonalBestsSection(),
                // const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
