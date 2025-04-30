import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'booking_success_summary.dart';

class ReviewBookingDetailsScreen extends StatefulWidget {
  const ReviewBookingDetailsScreen({
    super.key,
    required this.ticketId,
    required this.date,
    required this.time,
    required this.email,
  });

  final String ticketId;
  final DateTime? date;
  final String? time;
  final String? email;

  @override
  State<ReviewBookingDetailsScreen> createState() =>
      _ReviewBookingDetailsScreenState();
}

class _ReviewBookingDetailsScreenState
    extends State<ReviewBookingDetailsScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _insertBookingDetails() async {
  try {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      throw Exception('User not authenticated');
    }

    final response = await Supabase.instance.client.from('sessions').insert({
      'time': widget.time,
      'date': widget.date?.toIso8601String(),
      'user_id': user.id,
      'email': widget.email,
      'ticket_id': widget.ticketId,
      'ticket_status': 'unconfirmed', // Default status
    }).select();

    if (response == null || response.isEmpty) {
      throw Exception('Failed to insert booking: No response from server.');
    }

    // Navigate to the success screen after successful insertion
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingSuccessSummaryWidget(
          ticketId: widget.ticketId,
          date: widget.date,
          time: widget.time,
          email: widget.email,
        ),
      ),
    );
  } catch (e) {
    _showErrorDialog('Error', e.toString());
  }
}

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: Color(0xFF443DFF),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(
            'Review Booking Details',
            style: TextStyle(
              color: Color(0xFF443DFF),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Booking Summary Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Please review your booking details before confirming. Make sure all the information is correct.',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Booking Summary',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 40,
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(
                          icon: Icons.email,
                          label: 'Email:',
                          value: widget.email ?? 'N/A',
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          icon: Icons.confirmation_number,
                          label: 'Ticket ID:',
                          value: widget.ticketId,
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          icon: Icons.calendar_today,
                          label: 'Date:',
                          value: DateFormat('MMMMEEEEd').format(widget.date!),
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          icon: Icons.access_time,
                          label: 'Time:',
                          value: widget.time ?? 'N/A',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Buttons Section
              Column(
                children: [
                  // Confirm Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _insertBookingDetails, // Call the insert function
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF443DFF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Edit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Edit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 24),
        const SizedBox(width: 8),
        Text(
          '$label $value',
          style: const TextStyle(fontSize: 14, color: Colors.black),
        ),
      ],
    );
  }
}