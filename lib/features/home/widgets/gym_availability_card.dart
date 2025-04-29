import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'home_info_row.dart'; // Import the reusable row widget
import '../../../core/theme.dart'; // Import HeronFitTheme
import 'package:heronfit/features/booking/views/booking_screen.dart'; // Import SessionsRow and allSessions

class GymAvailabilityCard extends StatelessWidget {
  const GymAvailabilityCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final currentDate = DateFormat('EEEE, MMMM d').format(DateTime.now()); // Get current day

    final currentTime = DateTime.now();
    final sessionStartHour = currentTime.hour;
    final sessionStart = DateTime(currentTime.year, currentTime.month, currentTime.day, sessionStartHour);
    final sessionEnd = sessionStart.add(const Duration(hours: 1));
    final sessionTime = '${DateFormat('h:mm a').format(sessionStart)} - ${DateFormat('h:mm a').format(sessionEnd)}';

    final sessionCount = filterSessionsByTime(
      allSessions, // Use the imported allSessions variable
      sessionTime,
      DateTime.now(),
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12), // Slightly larger radius
        boxShadow: HeronFitTheme.cardShadow, // Use theme shadow
      ),
      child: Padding(
        padding: const EdgeInsets.all(20), // Adjusted padding
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                // TODO: Navigate to Book A Session screen
                print('Gym Availability Tapped');
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Gym Availability',
                    style: textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold, // Make title bold
                    ),
                  ),
                  Icon(
                    SolarIconsOutline.calendarSearch,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            HomeInfoRow(
              icon: SolarIconsOutline.calendar,
              text: currentDate, // Use current day
            ),
            const SizedBox(height: 8),
            HomeInfoRow(
              icon: SolarIconsOutline.clockCircle,
              text: sessionTime, // Use current session time
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(
                    SolarIconsOutline.usersGroupRounded,
                    color: colorScheme.onSurface,
                    size: 24,
                  ),
                ),
                RichText(
                  text: TextSpan(
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    children: [
                      TextSpan(
                        text: '$sessionCount', // Display the count of booked sessions
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ), // Highlight number
                      ),
                      const TextSpan(
                        text: '/15 capacity', // TODO: Replace with actual capacity if dynamic
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int? filterSessionsByTime(
    List<SessionsRow>? sessions,
    String? sessionTime,
    DateTime? selectedDate,
  ) {
    if (sessions == null || sessionTime == null || selectedDate == null) {
      return 0; // Return 0 if any parameter is null
    }

    final normalizedSessionTime = sessionTime.trim().toLowerCase();

    final filteredSessions = sessions.where((session) {
      final normalizedTime = session.time?.trim().toLowerCase() ?? '';
      final matchesTime = normalizedTime == normalizedSessionTime;
      final matchesDate = session.date?.toIso8601String().split('T').first ==
          selectedDate.toIso8601String().split('T').first;
      debugPrint('Session: ${session.time}, Date: ${session.date}');
      debugPrint('Matches Time: $matchesTime, Matches Date: $matchesDate');
      return matchesTime && matchesDate;
    }).toList();

    return filteredSessions.length;
  }
}
