import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:heronfit/features/booking/views/confirm_booking.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  static String routeName = 'BookingScreen';
  static String routePath = '/bookingScreen';

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

String? getCurrentUserEmail() {
  final user = Supabase.instance.client.auth.currentUser;
  return user?.email;
}

class SessionsRow {
  final String time;
  final DateTime date;

  SessionsRow({required this.time, required this.date});

  factory SessionsRow.fromJson(Map<String, dynamic> json) {
    return SessionsRow(
      time: json['time'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }
}

List<SessionsRow> allSessions = []; // Store all sessions for the selected date

Future<List<SessionsRow>> fetchSessionsByEmail() async {
  try {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      throw Exception('User not authenticated');
    }

    final email = user.email;
    if (email == null) {
      throw Exception('User email is null');
    }

    final response = await Supabase.instance.client
        .from('sessions')
        .select()
        .eq('email', email);

    return response.map((e) => SessionsRow.fromJson(e)).toList();
  } catch (e) {
    return [];
  }
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
    final normalizedTime = session.time.trim().toLowerCase();
    final matchesTime = normalizedTime == normalizedSessionTime;
    final matchesDate = session.date.toIso8601String().split('T').first ==
        selectedDate.toIso8601String().split('T').first;
    debugPrint('Session: ${session.time}, Date: ${session.date}');
    debugPrint('Matches Time: $matchesTime, Matches Date: $matchesDate');
    return matchesTime && matchesDate;
  }).toList();

  return filteredSessions.length;
}

class _BookingScreenState extends State<BookingScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final Map<int, TextEditingController> textControllers = {};
  final Map<int, FocusNode> focusNodes = {};
  DateTime? selectedDate;
  DateTime focusedDate = DateTime.now();
  final Map<String, int> sessionBookings =
      {}; // To store the number of bookings per session

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now(); // Set the default selected date to today
    for (int i = 1; i <= 9; i++) {
      textControllers[i] = TextEditingController();
      focusNodes[i] = FocusNode();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        textControllers[1]?.text = '8:00 AM - 9:00 AM';
        textControllers[2]?.text = '9:00 AM - 10:00 AM';
        textControllers[3]?.text = '10:00 AM - 11:00 AM';
        textControllers[4]?.text = '11:00 AM - 12:00 PM';
        textControllers[5]?.text = '12:00 PM - 1:00 PM';
        textControllers[6]?.text = '1:00 PM - 2:00 PM';
        textControllers[7]?.text = '2:00 PM - 3:00 PM';
        textControllers[8]?.text = '3:00 PM - 4:00 PM';
        textControllers[9]?.text = '4:00 PM - 5:00 PM';
      });
    });
    _fetchSessionBookings(); // Fetch the number of bookings for each session
  }

  @override
  void dispose() {
    for (int i = 1; i <= 9; i++) {
      textControllers[i]?.dispose();
      focusNodes[i]?.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchSessionBookings() async {
  try {
    final response = await Supabase.instance.client
        .from('sessions')
        .select()
        .eq('date', selectedDate!.toIso8601String());

    setState(() {
      allSessions = response.map((e) => SessionsRow.fromJson(e)).toList();
    });
    } catch (e) {
    // Handle error if needed
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(title: const Text('Book a Session'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Calendar with white background
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        color: Colors.grey.withOpacity(0.2),
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _buildCalendar(),
                ),
                const SizedBox(height: 16),
                // "Sessions for {day}" text
                Text(
                  'Sessions for ${DateFormat('EEEE, MMMM d').format(selectedDate ?? DateTime.now())}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (selectedDate != null) ...[
                  if (DateFormat('EEEE').format(selectedDate!) != 'Saturday' &&
                      DateFormat('EEEE').format(selectedDate!) != 'Sunday')
                    ..._buildSessionWidgets(),
                  if (DateFormat('EEEE').format(selectedDate!) == 'Saturday' ||
                      DateFormat('EEEE').format(selectedDate!) == 'Sunday')
                    const Center(
                      child: Text(
                        'No Available Sessions For This Day!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.now(),
      lastDay: DateTime.now().add(const Duration(days: 365)),
      focusedDay: focusedDate,
      selectedDayPredicate: (day) => isSameDay(selectedDate, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          selectedDate = selectedDay;
          focusedDate = focusedDay;
        });
        _fetchSessionBookings(); // Fetch bookings for the newly selected date
      },
      calendarFormat: CalendarFormat.week, // Display only one week
      availableCalendarFormats: const {
        CalendarFormat.week: 'Week', // Restrict to week view only
      },
      calendarStyle: const CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Color.fromARGB(99, 9, 25, 248),
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Color.fromRGBO(67, 59, 255, 1),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  List<Widget> _buildSessionWidgets() {
    final now = DateTime.now();

    // Separate past and upcoming sessions
    final pastSessions = <Widget>[];
    final upcomingSessions = <Widget>[];

    for (int index = 0; index < 9; index++) {
      int sessionIndex = index + 1;
      final sessionTime = textControllers[sessionIndex]?.text ?? '';
      final sessionCount = filterSessionsByTime(
        allSessions,
        sessionTime,
        selectedDate,
      );

      // Parse session start time
      final sessionStartTime = _parseSessionStartTime(sessionTime);
      final isPastSession = sessionStartTime != null && sessionStartTime.isBefore(now);

      final sessionWidget = Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isPastSession ? Colors.grey[300] : Colors.white, // Grey out past sessions
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                color: Colors.grey.withOpacity(0.2),
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Session details (time and slots)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 20,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        sessionTime,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isPastSession ? Colors.grey : Colors.black, // Grey text for past sessions
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.people, size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '$sessionCount',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isPastSession ? Colors.grey : Colors.black, // Grey text for past sessions
                              ),
                            ),
                            TextSpan(
                              text: '/15 slots',
                              style: TextStyle(
                                fontSize: 14,
                                color: isPastSession ? Colors.grey : Colors.grey, // Grey text for slots
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Book button
              ElevatedButton(
                onPressed: isPastSession
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ConfirmBookingScreen(
                              date: selectedDate,
                              time: sessionTime,
                              email: getCurrentUserEmail(),
                            ),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPastSession ? Colors.grey : const Color.fromRGBO(67, 59, 255, 1), // Blue for active, grey for disabled
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Book',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // White text for the button
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      if (isPastSession) {
        pastSessions.add(sessionWidget);
      } else {
        upcomingSessions.add(sessionWidget);
      }
    }

    // Combine upcoming and past sessions
    return [...upcomingSessions, ...pastSessions];
  }

  DateTime? _parseSessionStartTime(String sessionText) {
    try {
      final parts = sessionText.split(' - ');
      if (parts.isNotEmpty) {
        final startTime = parts[0];
        final parsedTime = DateFormat('h:mm a').parse(startTime);
        return DateTime(
          selectedDate!.year,
          selectedDate!.month,
          selectedDate!.day,
          parsedTime.hour,
          parsedTime.minute,
        );
      }
    } catch (_) {
      // Ignore parsing errors
    }
    return null;
  }
}

Future<void> bookSession(String sessionId, String userId) async {
  try {
    // Update the session booking in the sessions table
    await Supabase.instance.client
        .from('sessions')
        .update({'ticket_status': 'booked'})
        .eq('session_id', sessionId);

    // Update the user's has_session status to true
    await Supabase.instance.client
        .from('users')
        .update({'has_session': true})
        .eq('id', userId);

    debugPrint('Session booked successfully and user status updated.');
  } catch (e) {
    debugPrint('Error booking session: $e');
    throw Exception('Failed to book session. Please try again.');
  }
}
