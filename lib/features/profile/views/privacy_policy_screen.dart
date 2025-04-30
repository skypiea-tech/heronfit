import 'package:flutter/material.dart';
// Import GoRouter
import '../../../core/theme.dart';

class PrivacyPolicyWidget extends StatelessWidget {
  const PrivacyPolicyWidget({super.key});

  static String routeName = 'PrivacyPolicy';
  static String routePath = '/privacyPolicy';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: HeronFitTheme.primary,
              size: 30,
            ),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(
            'Privacy Policy',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: HeronFitTheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HeronFit is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and protect your personal information when you use our app.\n\n'
                  'Information We Collect\n\n'
                  'When you use HeronFit, we may collect the following information:\n'
                  '• Personal Information: Your name, email address, and other information you provide when you create an account or use our services.\n'
                  '• Usage Data: Information about how you use our app, such as your IP address, browser type, and the pages you visit.\n'
                  '• Fitness Data: Information about your workouts, including your goals, progress, and exercise history.\n\n'
                  'How We Use Your Information\n\n'
                  'We use your information to:\n'
                  '• Provide and improve our services\n'
                  '• Personalize your experience\n'
                  '• Communicate with you about our app and services\n'
                  '• Analyze and understand how you use our app\n\n'
                  'Sharing Your Information\n\n'
                  'We may share your information with third-party service providers who help us operate our app. We will not sell or rent your personal information to third parties.\n\n'
                  'Data Security\n\n'
                  'We take reasonable measures to protect your personal information from unauthorized access, disclosure, alteration, or destruction. However, no method of transmission over the internet or electronic storage is completely secure.\n\n'
                  'Your Choices\n\n'
                  'You have the right to:\n'
                  '• Access and correct your personal information\n'
                  '• Delete your account and your data\n'
                  '• Opt out of targeted advertising\n\n'
                  'Contact Us\n\n'
                  'If you have any questions about our privacy practices, please contact us at heronfit@gmail.com.\n\n'
                  'By using HeronFit, you agree to this Privacy Policy.',
                  style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                    letterSpacing: 0.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
