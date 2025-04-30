import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:heronfit/core/router/app_routes.dart'; // Import AppRoutes
import 'package:heronfit/features/progress/models/progress_record.dart';
import 'package:heronfit/widgets/loading_indicator.dart';
import 'package:intl/intl.dart';
import 'package:solar_icons/solar_icons.dart'; // Import SolarIcons
import 'dart:math';
import 'package:heronfit/core/theme.dart';

class WeightLogSection extends ConsumerWidget {
  final AsyncValue<List<ProgressRecord>> progressAsyncValue;

  const WeightLogSection({required this.progressAsyncValue, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Weight Log', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            boxShadow: HeronFitTheme.cardShadow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: theme.cardColor,
            child: Padding(
              padding: const EdgeInsets.all(20.0), // Slightly less padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  progressAsyncValue.when(
                    data: (records) {
                      if (records.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.0),
                            child: Text('No weight entries yet.'),
                          ),
                        );
                      }
                      final limitedRecords = records.sublist(
                        0,
                        min(records.length, 3),
                      );
                      return Column(
                        children: [
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: limitedRecords.length,
                            itemBuilder: (context, index) {
                              final record = limitedRecords[index];
                              return ListTile(
                                dense: true, // Make items smaller
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 0,
                                ),
                                leading: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: theme.colorScheme.secondary
                                      .withAlpha(50),
                                  child: Icon(
                                    SolarIconsOutline.scale,
                                    color: theme.colorScheme.secondary,
                                    size: 18,
                                  ),
                                ),
                                title: Text(
                                  '${record.weight.toStringAsFixed(1)} kg',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 15,
                                  ),
                                ),
                                subtitle: Text(
                                  DateFormat(
                                    'MMMM d, yyyy at hh:mm a',
                                  ).format(record.date.toLocal()),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                                trailing:
                                    record.photoUrl != null
                                        ? Icon(
                                          SolarIconsOutline.gallery,
                                          color: theme.hintColor,
                                          size: 18,
                                        )
                                        : null,
                              );
                            },
                            separatorBuilder:
                                (context, index) => const Divider(height: 1),
                          ),
                          if (records.length > 3)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    context.push(AppRoutes.progressDetails);
                                  },
                                  child: Text(
                                    'View More',
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                    loading: () => const Center(child: LoadingIndicator()),
                    error:
                        (error, stack) =>
                            Center(child: Text('Error loading log: $error')),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
