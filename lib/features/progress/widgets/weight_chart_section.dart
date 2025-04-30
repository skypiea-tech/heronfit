import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/router/app_routes.dart'; // Import AppRoutes
import 'package:heronfit/core/theme.dart'; // Import theme for shadow
import 'package:heronfit/features/progress/models/progress_record.dart';
import 'package:heronfit/widgets/loading_indicator.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:solar_icons/solar_icons.dart'; // Import SolarIcons

class WeightChartSection extends ConsumerWidget {
  final AsyncValue<List<ProgressRecord>> progressAsyncValue;

  const WeightChartSection({required this.progressAsyncValue, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      // Wrap Card with Container to apply custom shadow
      decoration: BoxDecoration(
        color: theme.cardColor, // Use card color for background
        borderRadius: BorderRadius.circular(12),
        boxShadow: HeronFitTheme.cardShadow, // Apply custom shadow from theme
      ),
      child: Card(
        elevation: 0, // Set elevation to 0 as shadow is handled by Container
        color: Colors.transparent, // Make card transparent
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weight',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Last 90 Days',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.hintColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed:
                        () => context.push(AppRoutes.progressUpdateWeight),
                    icon: Icon(
                      SolarIconsOutline.addSquare, // Use addSquare icon only
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                    tooltip: 'Add Weight Entry',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Chart container with subtle background and rounded corners
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Center(
                  child: progressAsyncValue.when(
                    data: (records) {
                      if (records.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.0),
                            child: Text(
                              'Log your weight to see progress here.',
                            ),
                          ),
                        );
                      }
                      final sortedRecords = List<ProgressRecord>.from(records)
                        ..sort((a, b) => a.date.compareTo(b.date));
                      final recentRecords = sortedRecords;

                      if (recentRecords.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.0),
                            child: Text('No weight logged recently.'),
                          ),
                        );
                      }

                      final spots =
                          recentRecords.asMap().entries.map((entry) {
                            return FlSpot(
                              entry.key.toDouble(),
                              entry.value.weight,
                            );
                          }).toList();

                      double minY =
                          recentRecords
                              .map((r) => r.weight)
                              .reduce((a, b) => a < b ? a : b) -
                          5;
                      double maxY =
                          recentRecords
                              .map((r) => r.weight)
                              .reduce((a, b) => a > b ? a : b) +
                          5;
                      minY = minY < 0 ? 0 : minY;

                      return SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: LineChart(
                          LineChartData(
                            minY: minY,
                            maxY: maxY,
                            gridData: FlGridData(
                              show: true,
                              drawHorizontalLine:
                                  true, // Only show horizontal lines
                              drawVerticalLine: false,
                              horizontalInterval: (maxY - minY) / 4,
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: theme.dividerColor.withAlpha(
                                    100,
                                  ), // Slightly fainter
                                  strokeWidth: 1,
                                );
                              },
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  interval: (maxY - minY) / 4,
                                  getTitlesWidget: (value, meta) {
                                    if (value == meta.min ||
                                        value == meta.max ||
                                        (value > meta.min &&
                                            value < meta.max &&
                                            (value - meta.min) %
                                                    ((meta.max - meta.min) /
                                                        2) ==
                                                0)) {
                                      return SideTitleWidget(
                                        axisSide: meta.axisSide,
                                        space: 8.0,
                                        child: Text(
                                          value.toStringAsFixed(0),
                                          style: theme.textTheme.labelSmall,
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  interval:
                                      spots.length > 1
                                          ? (spots.last.x - spots.first.x) / 3
                                          : 1,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();
                                    if (index == 0 ||
                                        index ==
                                            (recentRecords.length / 2)
                                                .floor() ||
                                        index == recentRecords.length - 1) {
                                      if (index >= 0 &&
                                          index < recentRecords.length) {
                                        return SideTitleWidget(
                                          axisSide: meta.axisSide,
                                          space: 8.0,
                                          child: Text(
                                            DateFormat(
                                              'MM/dd',
                                            ).format(recentRecords[index].date),
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(fontSize: 10),
                                          ),
                                        );
                                      }
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: false,
                            ), // Hide border to match Figma
                            lineBarsData: [
                              LineChartBarData(
                                spots: spots,
                                isCurved: true,
                                color: theme.colorScheme.primary,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: FlDotData(show: true), // Keep dots
                                belowBarData: BarAreaData(
                                  show: false,
                                ), // Hide area below bar
                              ),
                            ],
                            lineTouchData: LineTouchData(
                              touchTooltipData: LineTouchTooltipData(
                                getTooltipColor:
                                    (spot) => theme.colorScheme.primary,
                                getTooltipItems: (touchedSpots) {
                                  return touchedSpots
                                      .map((LineBarSpot touchedSpot) {
                                        final index = touchedSpot.spotIndex;
                                        if (index >= 0 &&
                                            index < recentRecords.length) {
                                          final record = recentRecords[index];
                                          return LineTooltipItem(
                                            '${record.weight.toStringAsFixed(1)} kg',
                                            TextStyle(
                                              color:
                                                  theme.colorScheme.onPrimary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: DateFormat(
                                                  'MMM d, yyyy',
                                                ).format(record.date),
                                                style: TextStyle(
                                                  color: theme
                                                      .colorScheme
                                                      .onPrimary
                                                      .withAlpha(204),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                            textAlign: TextAlign.center,
                                          );
                                        }
                                        return null;
                                      })
                                      .whereType<LineTooltipItem>()
                                      .toList();
                                },
                              ),
                              handleBuiltInTouches: true,
                            ),
                          ),
                        ),
                      );
                    },
                    loading: () => const Center(child: LoadingIndicator()),
                    error:
                        (error, stack) => Center(
                          child: Text('Error loading progress: $error'),
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
