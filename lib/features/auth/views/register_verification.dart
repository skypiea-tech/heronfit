import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:heronfit/core/theme.dart';
import '../controllers/registration_controller.dart';
import '../controllers/verify_email_controller.dart'; // Import verification logic
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import '../../../widgets/loading_indicator.dart'; // Import LoadingIndicator
import 'package:pinput/pinput.dart';
// Import SolarIcons

class RegisterVerificationScreen extends ConsumerStatefulWidget {
  const RegisterVerificationScreen({super.key});

  @override
  ConsumerState<RegisterVerificationScreen> createState() =>
      _RegisterVerificationScreenState();
}

class _RegisterVerificationScreenState
    extends ConsumerState<RegisterVerificationScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController pinCodeController = TextEditingController();
  final FocusNode pinCodeFocusNode = FocusNode();
  bool _isLoading = false;

  @override
  void dispose() {
    pinCodeController.dispose();
    pinCodeFocusNode.dispose();
    super.dispose();
  }

  Future<void> _verifyAndRegister() async {
    if (pinCodeController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the full 6-digit code.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final registrationNotifier = ref.read(registrationProvider.notifier);
    final registrationState = ref.read(registrationProvider);

    try {
      final AuthResponse verificationResponse = await verifyEmailWithToken(
        registrationState.email,
        pinCodeController.text,
      );

      final userId = verificationResponse.user?.id;
      if (userId == null) {
        throw Exception('Verification succeeded but user ID is missing.');
      }

      await registrationNotifier.insertUserProfile(userId);

      if (mounted) {
        context.goNamed(AppRoutes.registerSuccess);
      }
    } on AuthException catch (e) {
      if (mounted) {
        pinCodeController.clear();
        pinCodeFocusNode.requestFocus();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification Error: ${e.message}'),
            backgroundColor: HeronFitTheme.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        pinCodeController.clear();
        pinCodeFocusNode.requestFocus();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resendCode() async {
    final email = ref.read(registrationProvider).email;
    if (email.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: email,
      );
      if (mounted) {
        pinCodeController.clear();
        pinCodeFocusNode.requestFocus();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification code resent to your email.'),
            backgroundColor: HeronFitTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error resending code: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = ref.watch(registrationProvider).email;

    final defaultPinTheme = PinTheme(
      width: 52,
      height: 52,
      textStyle: HeronFitTheme.textTheme.headlineSmall?.copyWith(
        color: HeronFitTheme.textPrimary,
      ),
      decoration: BoxDecoration(
        color: HeronFitTheme.bgSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: HeronFitTheme.primary, width: 2),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      textStyle: HeronFitTheme.textTheme.headlineSmall?.copyWith(
        color: HeronFitTheme.primaryDark,
      ),
      decoration: defaultPinTheme.decoration?.copyWith(
        color: HeronFitTheme.primary.withOpacity(0.1),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: HeronFitTheme.error, width: 1),
      color: HeronFitTheme.error.withOpacity(0.1),
    );

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: HeronFitTheme.bgLight,
        elevation: 0,
        leading: BackButton(color: HeronFitTheme.primaryDark),
      ),
      backgroundColor: HeronFitTheme.bgLight,
      body: SafeArea(
        top: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Image.asset(
                          'assets/images/register_verify_email.png',
                          fit: BoxFit.contain,
                          height: 250,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            children: [
                              Text(
                                'Almost There!',
                                textAlign: TextAlign.center,
                                style: HeronFitTheme.textTheme.headlineSmall
                                    ?.copyWith(
                                      color: HeronFitTheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: HeronFitTheme.textTheme.bodyMedium
                                      ?.copyWith(
                                        color: HeronFitTheme.textSecondary,
                                      ),
                                  children: [
                                    const TextSpan(
                                      text:
                                          'Please enter the 6 digit code sent to ',
                                    ),
                                    TextSpan(
                                      text: email,
                                      style: TextStyle(
                                        color: HeronFitTheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const TextSpan(
                                      text:
                                          ' to verify your account and start your fitness journey.',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Pinput(
                        length: 6,
                        controller: pinCodeController,
                        focusNode: pinCodeFocusNode,
                        autofocus: true,
                        hapticFeedbackType: HapticFeedbackType.lightImpact,
                        onCompleted: (pin) {
                          _verifyAndRegister();
                        },
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: focusedPinTheme,
                        submittedPinTheme: submittedPinTheme,
                        errorPinTheme: errorPinTheme,
                        pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                        showCursor: true,
                        cursor: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 9),
                              width: 22,
                              height: 2,
                              color: HeronFitTheme.primary,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: _isLoading ? null : _resendCode,
                        child: Text(
                          'Resend Code',
                          style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                            color: HeronFitTheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16.0),
                      child: LoadingIndicator(),
                    )
                  else ...[
                    ElevatedButton(
                      onPressed: _verifyAndRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HeronFitTheme.primary,
                        foregroundColor: HeronFitTheme.bgLight,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: HeronFitTheme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text('Confirm'),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        ref.read(registrationProvider.notifier).reset();
                        context.goNamed(AppRoutes.register);
                      },
                      child: Text(
                        'Change Email',
                        style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                          color: HeronFitTheme.textMuted,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
