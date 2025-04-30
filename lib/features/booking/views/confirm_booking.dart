import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'confirm_details.dart';

class ConfirmBookingScreen extends StatefulWidget {
  const ConfirmBookingScreen({
    super.key,
    required this.date,
    required this.time,
    required this.email, // Add the email parameter
  });

  final DateTime? date;
  final String? time;
  final String? email; // Add the email field

  @override
  State<ConfirmBookingScreen> createState() => _ConfirmBookingScreenState();
}

class _ConfirmBookingScreenState extends State<ConfirmBookingScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController ticketIdController = TextEditingController();
  final FocusNode ticketIdFocusNode = FocusNode();
  bool noTicket = false; // Add a state variable for the checkbox

  @override
  void dispose() {
    ticketIdController.dispose();
    ticketIdFocusNode.dispose();
    super.dispose();
  }

  Future<int> fetchSlotCapacity(String sessionTime) async {
    try {
      final response = await Supabase.instance.client
          .from('sessions') // Replace 'sessions' with your actual table name
          .select('slot_capacity')
          .eq('time', sessionTime)
          .single();

      if (response != null && response['slot_capacity'] != null) {
        return response['slot_capacity'] as int;
      } else {
        throw Exception('Slot capacity not found for the selected session.');
      }
    } catch (e) {
      debugPrint('Error fetching slot capacity: $e');
      return 0; // Default to 0 if there's an error
    }
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
            'Confirm Booking',
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
              // Session Details
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Session Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255),
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
                          value: widget.email ?? 'N/A', // Display the email
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
              // Ticket ID Input
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Enter Ticket ID',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: ticketIdController,
                    focusNode: ticketIdFocusNode,
                    enabled: !noTicket, // Disable the textbox when the checkbox is checked
                    decoration: InputDecoration(
                      hintText: 'Enter Ticket ID',
                      filled: true,
                      fillColor: noTicket ? Colors.grey[300] : const Color(0xFFF3F4F6), // Greyed out when disabled
                      prefixIcon: const Icon(
                        Icons.confirmation_number,
                        color: Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF443DFF)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Checkbox for users without a ticket
                  Row(
                    children: [
                      Checkbox(
                        value: noTicket,
                        onChanged: (value) {
                          setState(() {
                            noTicket = value ?? false;
                          });
                        },
                      ),
                      const Text(
                        'I don\'t have a ticket yet',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Buttons
              Column(
                children: [
                  // Flexible "Next" button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (ticketIdController.text.isNotEmpty || noTicket) {
                          final slotCapacity =
                              await fetchSlotCapacity(widget.time ?? '');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReviewBookingDetailsScreen(
                                ticketId: noTicket ? '' : ticketIdController.text!,
                                date: widget.date,
                                time: widget.time,
                                email: widget.email,
                              ),
                            ),
                          );
                        } else {
                          _showErrorDialog(context, 'Please provide a ticket ID or check the box.');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF443DFF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Flexible "Cancel" button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
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
}