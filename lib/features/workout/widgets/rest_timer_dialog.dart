import 'dart:async';
import 'package:flutter/material.dart';
import 'package:heronfit/core/theme.dart';
import 'package:solar_icons/solar_icons.dart'; // Ensure SolarIcons are imported
import 'package:vibration/vibration.dart'; // Import vibration package

class RestTimerDialog extends StatefulWidget {
  final Duration initialDuration;
  final VoidCallback onSkip;
  final VoidCallback onTimerEnd;
  final Function(Duration)? onAdjustDuration; // Optional: To update default
  final String exerciseName;
  final int setNumber;

  const RestTimerDialog({
    super.key,
    required this.initialDuration,
    required this.onSkip,
    required this.onTimerEnd,
    this.onAdjustDuration,
    required this.exerciseName,
    required this.setNumber,
  });

  @override
  _RestTimerDialogState createState() => _RestTimerDialogState();
}

class _RestTimerDialogState extends State<RestTimerDialog> {
  Timer? _timer;
  late Duration _remainingTime;
  late Duration _currentSetDuration;
  bool _canVibrate = false; // To store vibration capability

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.initialDuration;
    _currentSetDuration = widget.initialDuration;
    _checkVibrationCapability(); // Check if device can vibrate
    _startTimer();
  }

  // Check if the device has vibration capabilities
  Future<void> _checkVibrationCapability() async {
    bool? hasVibrator = await Vibration.hasVibrator();
    if (mounted) {
      setState(() {
        _canVibrate = hasVibrator ?? false;
      });
    }
  }

  // Helper to vibrate if possible
  void _vibrate() {
    if (_canVibrate) {
      Vibration.vibrate(duration: 200); // Vibrate for 200ms
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingTime <= Duration.zero) {
        timer.cancel();
        _vibrate(); // Vibrate when timer ends
        widget.onTimerEnd(); // Notify parent timer ended
        if (mounted) {
          Navigator.of(context).pop(); // Auto-close dialog
        }
      } else {
        setState(() {
          _remainingTime = _remainingTime - const Duration(seconds: 1);
        });
      }
    });
  }

  void _adjustTime(Duration adjustment) {
    final newRemaining = _remainingTime + adjustment;
    final newSetDuration = _currentSetDuration + adjustment;

    // Ensure remaining time doesn't go below zero visually when adjusting
    final adjustedRemaining =
        newRemaining < Duration.zero ? Duration.zero : newRemaining;

    setState(() {
      _remainingTime = adjustedRemaining;

      // Adjust the base duration for potential future use (onAdjustDuration)
      if (newSetDuration >= const Duration(seconds: 15)) {
        _currentSetDuration = newSetDuration;
        widget.onAdjustDuration?.call(_currentSetDuration);
      } else if (adjustment < Duration.zero &&
          _currentSetDuration > const Duration(seconds: 15)) {
        // Allow decreasing down to 15s
        _currentSetDuration = const Duration(seconds: 15);
        widget.onAdjustDuration?.call(_currentSetDuration);
      }

      // If timer was finished and we add time, restart it
      if ((_timer == null || !_timer!.isActive) &&
          _remainingTime > Duration.zero) {
        _startTimer();
      }
      // If adjustment makes it zero or less, ensure timer stops and dialog closes soon
      else if (_remainingTime <= Duration.zero &&
          (_timer != null && _timer!.isActive)) {
        _timer?.cancel(); // Stop timer immediately
        _vibrate(); // Vibrate when time adjusted to zero or less
        widget.onTimerEnd(); // Trigger end callback
        if (mounted) {
          // Use a short delay to allow UI update before popping
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) Navigator.of(context).pop();
          });
        }
      }
    });
  }

  void _skipTimer() {
    _timer?.cancel();
    _vibrate(); // Vibrate when skipped
    widget.onSkip();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  String _formatDuration(Duration duration) {
    // Ensure negative durations are displayed as 0:00
    if (duration.isNegative) return '0:00';
    final minutes = duration.inMinutes.remainder(60).toString();
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    double progress = 1.0;
    // Use _currentSetDuration for progress calculation if it was adjusted
    final totalDurationSeconds = _currentSetDuration.inSeconds;
    if (totalDurationSeconds > 0) {
      progress = _remainingTime.inSeconds / totalDurationSeconds;
    }
    progress = progress.clamp(0.0, 1.0);

    // --- Size Calculation (Even Larger, Responsive) ---
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Define further increased max dimensions
    const double maxWidth = 400.0; // Further increased max width
    const double maxHeight = 600.0; // Further increased max height

    // Calculate actual width based on screen size, capped at max width
    final double dialogWidth = (screenWidth * 0.9).clamp(0.0, maxWidth);

    // Calculate height based on screen height, capped at max height
    // Increase percentage slightly
    final double dialogHeight = (screenHeight * 0.75).clamp(
      0.0,
      maxHeight,
    ); // Use 75% of screen height, capped

    // Make the timer circle size relative to the dialog width
    final timerSize = dialogWidth * 0.65; // Keep proportion relative to width

    return AlertDialog(
      backgroundColor: HeronFitTheme.bgLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
      contentPadding: EdgeInsets.zero, // Remove default padding
      insetPadding: EdgeInsets.symmetric(
        horizontal: (screenWidth - dialogWidth) / 2,
        vertical: (screenHeight - dialogHeight) / 2, // Center vertically
      ),
      content: Container(
        // Use Container for padding and constraints
        width: dialogWidth,
        height: dialogHeight,
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Space elements vertically
          children: [
            // --- Title and Subtitle ---
            Column(
              children: [
                Text(
                  'Rest Timer',
                  style: HeronFitTheme.textTheme.headlineSmall?.copyWith(
                    color: HeronFitTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.exerciseName} - Set ${widget.setNumber}',
                  textAlign: TextAlign.center,
                  style: HeronFitTheme.textTheme.titleMedium?.copyWith(
                    color: HeronFitTheme.textMuted,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),

            // --- Circular Timer ---
            SizedBox(
              width: timerSize,
              height: timerSize,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 16, // Thicker stroke
                    backgroundColor: HeronFitTheme.primary.withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      HeronFitTheme.primary,
                    ),
                    strokeCap: StrokeCap.round, // Round ends
                  ),
                  Center(
                    child: Text(
                      _formatDuration(_remainingTime),
                      style: HeronFitTheme.textTheme.displaySmall?.copyWith(
                        color: HeronFitTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize:
                            timerSize * 0.3, // Slightly larger scaled font size
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- Adjustment Buttons ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAdjustButton(
                  SolarIconsBold.minusSquare, // Use SolarIcons
                  const Duration(seconds: -15),
                ),
                const SizedBox(width: 24), // Increased spacing
                _buildAdjustButton(
                  SolarIconsBold.addSquare, // Use SolarIcons
                  const Duration(seconds: 15),
                ),
              ],
            ),

            // --- Skip Button ---
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: HeronFitTheme.error,
                foregroundColor: Colors.white,
                minimumSize: Size(dialogWidth * 0.7, 48), // Relative width
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                textStyle: HeronFitTheme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: _skipTimer,
              child: const Text('Skip Rest'),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for adjustment buttons
  Widget _buildAdjustButton(IconData icon, Duration adjustment) {
    return IconButton(
      icon: Icon(icon),
      iconSize: 52, // Larger icon size
      color: HeronFitTheme.primary,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      onPressed: () => _adjustTime(adjustment),
    );
  }
}
