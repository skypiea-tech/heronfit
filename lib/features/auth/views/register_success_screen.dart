import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:heronfit/core/theme.dart';
import '../controllers/registration_controller.dart';
// Import SolarIcons

class RegisterSuccessScreen extends ConsumerWidget {
  const RegisterSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the user's first name for the welcome message
    final firstName = ref.watch(registrationProvider).firstName;
    final welcomeMessage =
        firstName.isNotEmpty ? 'Welcome, $firstName!' : 'Welcome!';

    return Scaffold(
      // Removed AppBar as it's usually not present on success screens
      backgroundColor: HeronFitTheme.bgLight,
      body: SafeArea(
        child: Padding(
          // Consistent padding, more vertical padding to center content
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 64.0),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // Push button to bottom
            crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch content
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center content vertically
                  children: [
                    // Illustration - Replaced placeholder with actual image
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 24.0,
                      ), // Add padding
                      child: Image.asset(
                        'assets/images/register_success.png', // Use provided image
                        fit: BoxFit.contain,
                        height: 400, // Set height similar to Figma
                      ),
                    ),
                    const SizedBox(height: 32), // Adjusted spacing
                    // Text Content - Updated Styles
                    Text(
                      welcomeMessage,
                      style: HeronFitTheme.textTheme.headlineSmall?.copyWith(
                        color: HeronFitTheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                      ), // Add padding for longer text
                      child: Text(
                        'You\'re now part of the HeronFit community. Let\'s achieve your fitness goals together.',
                        style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                          color: HeronFitTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              // Bottom Button - Updated Styling
              ElevatedButton(
                onPressed: () {
                  // Reset the registration state before navigating home
                  ref.read(registrationProvider.notifier).reset();
                  // Use context.go to replace the entire navigation stack with home
                  context.go(AppRoutes.home);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: HeronFitTheme.primary, // Primary color
                  foregroundColor: HeronFitTheme.bgLight,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: HeronFitTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold, // Bold text
                  ),
                ),
                child: const Text("Let's Go!"), // Use const
              ),
              const SizedBox(height: 16), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}
