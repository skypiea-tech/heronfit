import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../core/router/app_routes.dart';
import 'package:solar_icons/solar_icons.dart';

class OnboardingWidget extends StatefulWidget {
  const OnboardingWidget({super.key});

  static String routePath = AppRoutes.onboarding;

  @override
  State<OnboardingWidget> createState() => _OnboardingWidgetState();
}

class _OnboardingWidgetState extends State<OnboardingWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: HeronFitTheme.bgLight,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 40.0,
                  child: Image.asset(
                    'assets/images/logotype_heronfit.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const Spacer(flex: 1),

                SizedBox(
                  width: double.infinity,
                  child: Image.asset(
                    'assets/images/onboarding_hero.png',
                    fit: BoxFit.cover,
                  ),
                ),
                const Spacer(flex: 1),

                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Welcome to HeronFit',
                      textAlign: TextAlign.center,
                      style: HeronFitTheme.textTheme.headlineSmall?.copyWith(
                        color: HeronFitTheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your Fitness Journey Starts Here',
                      textAlign: TextAlign.center,
                      style: HeronFitTheme.textTheme.bodyLarge?.copyWith(
                        color: HeronFitTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        context.push(AppRoutes.register);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52.0),
                        backgroundColor: HeronFitTheme.primary,
                        foregroundColor: HeronFitTheme.bgLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        textStyle: HeronFitTheme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text('Get Started'),
                    ),
                    const SizedBox(height: 16.0),
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        context.push(AppRoutes.login);
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
                              text: 'Log in',
                              style: HeronFitTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                    color: HeronFitTheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                              recognizer:
                                  TapGestureRecognizer()
                                    ..onTap = () {
                                      context.push(AppRoutes.login);
                                    },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
