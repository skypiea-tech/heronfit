import 'package:flutter/material.dart';
// Import GoRouter
import '../../../core/theme.dart';

class TermsOfUseWidget extends StatelessWidget {
  const TermsOfUseWidget({super.key});

  static String routeName = 'TermsOfUse';
  static String routePath = '/termsOfUse';

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
            'Terms of Use',
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
                  '1. Acceptance of Terms\n\n'
                  'By using the HeronFit app, you agree to be bound by these Terms of Use. If you disagree with any part of these terms, you may not use the app.\n\n'
                  '2. User Conduct\n\n'
                  'You agree to use the HeronFit app in a lawful and respectful manner. You will not:\n'
                  '• Violate any laws or regulations.\n'
                  '• Infringe on the intellectual property rights of others.\n'
                  '• Transmit any harmful or offensive content.\n'
                  '• Disrupt the operation of the app.\n\n'
                  '3. Intellectual Property Rights\n\n'
                  'The HeronFit app and all its content, including logos, trademarks, and copyrights, are the property of HeronFit or its licensors. You may not use any of this content without our express written permission.\n\n'
                  '4. Limitation of Liability\n\n'
                  'HeronFit is not liable for any damages arising from your use of the app, including but not limited to, indirect, incidental, consequential, or punitive damages.\n\n'
                  '5. Termination of Service\n\n'
                  'We reserve the right to terminate your access to the app at any time for any reason, without notice.\n\n'
                  '6. Governing Law\n\n'
                  'These Terms of Use shall be governed by and construed in accordance with the laws of the Republic of the Philippines.\n\n'
                  '7. Entire Agreement\n\n'
                  'These Terms of Use constitute the entire agreement between you and HeronFit regarding your use of the app.\n\n'
                  '8. Changes to the Terms of Use\n\n'
                  'We reserve the right to update these Terms of Use at any time. We will notify you of any changes by posting the revised Terms of Use on our app.',
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
