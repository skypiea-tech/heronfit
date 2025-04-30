import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:heronfit/core/router/app_routes.dart'; // Import routes
import '../../../core/theme.dart'; // Updated import path
import 'login_screen.dart'; // Import the LoginWidget
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/registration_controller.dart';
import 'package:solar_icons/solar_icons.dart'; // Import SolarIcons

class RegisterWidget extends ConsumerStatefulWidget {
  const RegisterWidget({super.key});

  static String routePath = '/register';

  @override
  ConsumerState<RegisterWidget> createState() => _RegisterWidgetState();
}

class _RegisterWidgetState extends ConsumerState<RegisterWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>(); // Added Form Key

  bool passwordVisibility = false;
  bool passwordConfirmVisibility = false;
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController =
      TextEditingController();
  bool _termsAccepted = false; // State for checkbox

  @override
  void dispose() {
    passwordController.dispose();
    passwordConfirmController.dispose();
    super.dispose();
  }

  // Validator for password confirmation
  String? _validatePasswordConfirm(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final registration = ref.watch(registrationProvider);
    final registrationNotifier = ref.read(registrationProvider.notifier);
    // Pre-fill controllers if needed (consider doing this in initState if state restoration is complex)
    passwordController.text = registration.password;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: HeronFitTheme.bgLight,
        body: SafeArea(
          top: true,
          child: Padding(
            padding: const EdgeInsets.all(24), // Consistent padding
            child: Form(
              // Wrap content in a Form
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // Space between elements
                crossAxisAlignment:
                    CrossAxisAlignment.stretch, // Stretch children
                children: [
                  // Title Section - Adjusted text styles and spacing
                  Column(
                    mainAxisSize: MainAxisSize.min, // Take minimum space
                    children: [
                      const SizedBox(height: 16), // Add top spacing
                      Text(
                        'Welcome to HeronFit',
                        textAlign: TextAlign.center, // Center align
                        style: HeronFitTheme.textTheme.titleMedium?.copyWith(
                          color: HeronFitTheme.textSecondary, // Adjusted color
                        ),
                      ),
                      const SizedBox(height: 4), // Spacing
                      Text(
                        'Ready to Begin?',
                        textAlign: TextAlign.center, // Center align
                        style: HeronFitTheme.textTheme.headlineSmall?.copyWith(
                          // Adjusted style
                          color: HeronFitTheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32), // Spacing before form
                    ],
                  ),

                  // Form Fields Section - Use Expanded to fill available space
                  Expanded(
                    child: SingleChildScrollView(
                      // Allow scrolling for smaller screens
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // First Name Field - Updated styling
                          TextFormField(
                            initialValue: registration.firstName,
                            onChanged: registrationNotifier.updateFirstName,
                            autovalidateMode:
                                AutovalidateMode
                                    .onUserInteraction, // Validate on interaction
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'Please enter your first name'
                                        : null,
                            // autofocus: true, // Consider removing autofocus for better initial screen view
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'First Name',
                              prefixIcon: const Icon(
                                SolarIconsOutline
                                    .user, // Replaced with SolarIcons
                                color: HeronFitTheme.primary, // Use theme color
                                size: 20, // Adjusted size
                              ),
                              // Apply theme styles consistently
                              filled: true,
                              fillColor: HeronFitTheme.bgSecondary,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  12.0,
                                ), // Rounded corners
                                borderSide: BorderSide.none, // No border
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 16,
                              ), // Adjust padding
                            ),
                            style:
                                HeronFitTheme
                                    .textTheme
                                    .bodyLarge, // Use theme text style
                          ),
                          const SizedBox(height: 16), // Spacing
                          // Last Name Field - Updated styling
                          TextFormField(
                            initialValue: registration.lastName,
                            onChanged: registrationNotifier.updateLastName,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'Please enter your last name'
                                        : null,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Last Name',
                              prefixIcon: const Icon(
                                SolarIconsOutline
                                    .user, // Replaced with SolarIcons
                                color: HeronFitTheme.primary,
                                size: 20,
                              ),
                              filled: true,
                              fillColor: HeronFitTheme.bgSecondary,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 16,
                              ),
                            ),
                            style: HeronFitTheme.textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 16),

                          // Email Field - Updated styling
                          TextFormField(
                            initialValue: registration.email,
                            onChanged: registrationNotifier.updateEmail,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(
                                r'^.+@.+\.[a-zA-Z]+$',
                              ).hasMatch(value)) {
                                return 'Please enter a valid email'; // Basic email validation
                              }
                              return null;
                            },
                            autofillHints: [AutofillHints.email],
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: const Icon(
                                SolarIconsOutline
                                    .letter, // Replaced with SolarIcons
                                color: HeronFitTheme.primary,
                                size: 20,
                              ),
                              filled: true,
                              fillColor: HeronFitTheme.bgSecondary,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 16,
                              ),
                            ),
                            style: HeronFitTheme.textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 16),

                          // Password Field - Updated styling and visibility toggle
                          TextFormField(
                            controller: passwordController, // Use controller
                            onChanged: registrationNotifier.updatePassword,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters'; // Basic length check
                              }
                              return null;
                            },
                            autofillHints: [AutofillHints.newPassword],
                            textInputAction: TextInputAction.next,
                            obscureText: !passwordVisibility,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(
                                SolarIconsOutline
                                    .lockPassword, // Replaced with SolarIcons
                                color: HeronFitTheme.primary,
                                size: 20,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  passwordVisibility
                                      ? SolarIconsOutline
                                          .eye // Replaced with SolarIcons
                                      : SolarIconsOutline
                                          .eyeClosed, // Replaced with SolarIcons
                                  color: HeronFitTheme.textMuted,
                                  size: 20,
                                ),
                                onPressed:
                                    () => setState(
                                      () =>
                                          passwordVisibility =
                                              !passwordVisibility,
                                    ),
                              ),
                              filled: true,
                              fillColor: HeronFitTheme.bgSecondary,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 16,
                              ),
                            ),
                            style: HeronFitTheme.textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 16),

                          // Confirm Password Field - Updated styling
                          TextFormField(
                            controller: passwordConfirmController,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator:
                                _validatePasswordConfirm, // Use custom validator
                            autofillHints: [AutofillHints.newPassword],
                            textInputAction:
                                TextInputAction.done, // Changed to done
                            obscureText: !passwordConfirmVisibility,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              prefixIcon: const Icon(
                                SolarIconsOutline
                                    .lockPassword, // Replaced with SolarIcons
                                color: HeronFitTheme.primary,
                                size: 20,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  passwordConfirmVisibility
                                      ? SolarIconsOutline
                                          .eye // Replaced with SolarIcons
                                      : SolarIconsOutline
                                          .eyeClosed, // Replaced with SolarIcons
                                  color: HeronFitTheme.textMuted,
                                  size: 20,
                                ),
                                onPressed:
                                    () => setState(
                                      () =>
                                          passwordConfirmVisibility =
                                              !passwordConfirmVisibility,
                                    ),
                              ),
                              filled: true,
                              fillColor: HeronFitTheme.bgSecondary,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 16,
                              ),
                            ),
                            style: HeronFitTheme.textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 16),

                          // Terms and Conditions Checkbox - Added CheckboxListTile
                          CheckboxListTile(
                            title: RichText(
                              text: TextSpan(
                                style: HeronFitTheme.textTheme.bodySmall
                                    ?.copyWith(
                                      color: HeronFitTheme.textMuted,
                                    ), // Smaller muted text
                                children: [
                                  const TextSpan(
                                    text: 'By continuing you accept our ',
                                  ),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: const TextStyle(
                                      fontWeight:
                                          FontWeight.bold, // Make links bold
                                      // decoration: TextDecoration.underline, // Underline optional
                                    ),
                                    recognizer:
                                        TapGestureRecognizer()
                                          ..onTap = () {
                                            // TODO: Navigate to Privacy Policy screen
                                            print('Navigate to Privacy Policy');
                                          },
                                  ),
                                  const TextSpan(text: ' and '),
                                  TextSpan(
                                    text: 'Terms of Use',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      // decoration: TextDecoration.underline,
                                    ),
                                    recognizer:
                                        TapGestureRecognizer()
                                          ..onTap = () {
                                            // TODO: Navigate to Terms of Use screen
                                            context.push(
                                              AppRoutes.profileTerms,
                                            ); // Example navigation
                                            print('Navigate to Terms of Use');
                                          },
                                  ),
                                ],
                              ),
                            ),
                            value: _termsAccepted,
                            onChanged: (bool? value) {
                              setState(() {
                                _termsAccepted = value ?? false;
                              });
                            },
                            controlAffinity:
                                ListTileControlAffinity
                                    .leading, // Checkbox on the left
                            contentPadding:
                                EdgeInsets.zero, // Remove default padding
                            activeColor:
                                HeronFitTheme
                                    .primary, // Theme color for checkbox
                          ),
                          const SizedBox(height: 24), // Spacing before button
                        ],
                      ),
                    ),
                  ),

                  // Bottom Section (Button and Login Link)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Validate Form and Terms
                          if (_formKey.currentState?.validate() ?? false) {
                            if (_termsAccepted) {
                              // Clear password controllers after storing value in provider
                              registrationNotifier.updatePassword(
                                passwordController.text,
                              );
                              // Navigate
                              context.pushNamed(
                                AppRoutes.registerGettingToKnow,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please accept the terms and conditions.',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              HeronFitTheme.primary, // Primary color
                          foregroundColor: HeronFitTheme.bgLight,
                          minimumSize: const Size(
                            double.infinity,
                            52,
                          ), // Button size
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              12,
                            ), // Rounded corners
                          ),
                          textStyle: HeronFitTheme.textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold, // Bold text
                              ),
                        ),
                        child: const Text('Register'),
                      ),
                      const SizedBox(height: 16), // Spacing
                      // Login Link - Updated styling
                      InkWell(
                        splashColor: Colors.transparent, // No splash
                        onTap: () {
                          context.go(
                            AppRoutes.login,
                          ); // Use go to replace stack
                        },
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                              color: HeronFitTheme.textMuted,
                            ),
                            children: [
                              const TextSpan(text: 'Already have an account? '),
                              TextSpan(
                                text: 'Log in', // Corrected text
                                style: TextStyle(
                                  color: HeronFitTheme.primary, // Primary color
                                  fontWeight: FontWeight.bold, // Bold
                                ),
                                recognizer:
                                    TapGestureRecognizer()
                                      ..onTap = () {
                                        context.go(AppRoutes.login);
                                      },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16), // Bottom spacing
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
