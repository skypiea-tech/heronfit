import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:heronfit/core/theme.dart';
import 'package:intl/intl.dart';
import '../controllers/registration_controller.dart';
import 'package:solar_icons/solar_icons.dart';

class RegisterGettingToKnowScreen extends ConsumerStatefulWidget {
  const RegisterGettingToKnowScreen({super.key});

  @override
  ConsumerState<RegisterGettingToKnowScreen> createState() =>
      _RegisterGettingToKnowScreenState();
}

class _RegisterGettingToKnowScreenState
    extends ConsumerState<RegisterGettingToKnowScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final registrationState = ref.read(registrationProvider);

    final birthday = registrationState.birthday;
    if (birthday.isNotEmpty) {
      try {
        final parsedDate = DateTime.parse(birthday);
        _birthdayController.text = DateFormat('yyyy-MM-dd').format(parsedDate);
      } catch (e) {
        print("Error parsing stored birthday: $e");
        _birthdayController.text = '';
      }
    }

    _weightController.text = registrationState.weight;
    _heightController.text = registrationState.height;
  }

  @override
  void dispose() {
    _birthdayController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _birthdayController.text.isNotEmpty
              ? (DateTime.tryParse(_birthdayController.text) ??
                  DateTime.now().subtract(const Duration(days: 365 * 18)))
              : DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: HeronFitTheme.primary,
              onPrimary: Colors.white,
              onSurface: HeronFitTheme.textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: HeronFitTheme.primaryDark,
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: HeronFitTheme.bgSecondary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      _birthdayController.text = formattedDate;
      ref
          .read(registrationProvider.notifier)
          .updateBirthday(picked.toIso8601String());
    }
  }

  @override
  Widget build(BuildContext context) {
    final registration = ref.watch(registrationProvider);
    final registrationNotifier = ref.read(registrationProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: HeronFitTheme.bgLight,
        elevation: 0,
        leading: BackButton(color: HeronFitTheme.primaryDark),
      ),
      backgroundColor: HeronFitTheme.bgLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 24.0),
                          child: Image.asset(
                            'assets/images/register_intro.png',
                            fit: BoxFit.cover,
                            height: 260,
                            width: 300,
                          ),
                        ),
                        // const SizedBox(height: 8),
                        Text(
                          'Tell us a little about yourself',
                          textAlign: TextAlign.center,
                          style: HeronFitTheme.textTheme.headlineSmall
                              ?.copyWith(
                                color: HeronFitTheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This will help us create a personalized experience just for you.',
                          style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                            color: HeronFitTheme.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        DropdownButtonFormField<String>(
                          value:
                              registration.gender.isEmpty
                                  ? null
                                  : registration.gender,
                          decoration: InputDecoration(
                            labelText: 'Choose Gender',
                            prefixIcon: const Icon(
                              SolarIconsOutline.usersGroupRounded,
                              color: HeronFitTheme.primary,
                              size: 20,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: HeronFitTheme.bgSecondary,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 16,
                            ),
                          ),
                          style: HeronFitTheme.textTheme.bodyLarge,
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: HeronFitTheme.textMuted,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'male',
                              child: Text('Male'),
                            ),
                            DropdownMenuItem(
                              value: 'female',
                              child: Text('Female'),
                            ),
                            DropdownMenuItem(
                              value: 'other',
                              child: Text('Other'),
                            ),
                            DropdownMenuItem(
                              value: 'prefer_not_to_say',
                              child: Text('Prefer not to say'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              registrationNotifier.updateGender(value);
                            }
                          },
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Please select a gender'
                                      : null,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _birthdayController,
                          decoration: InputDecoration(
                            labelText: 'Date of Birth',
                            prefixIcon: const Icon(
                              SolarIconsOutline.calendar,
                              color: HeronFitTheme.primary,
                              size: 20,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: HeronFitTheme.bgSecondary,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 16,
                            ),
                          ),
                          style: HeronFitTheme.textTheme.bodyLarge,
                          readOnly: true,
                          onTap: () => _selectDate(context),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Please enter your date of birth'
                                      : null,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _weightController,
                                onChanged:
                                    (value) => registrationNotifier
                                        .updateWeight(value.trim()),
                                decoration: InputDecoration(
                                  labelText: 'Your Weight',
                                  prefixIcon: const Icon(
                                    SolarIconsOutline.scale,
                                    color: HeronFitTheme.primary,
                                    size: 20,
                                  ),
                                  suffixText: 'KG',
                                  suffixStyle: HeronFitTheme
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: HeronFitTheme.textMuted,
                                      ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: HeronFitTheme.bgSecondary,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 16,
                                  ),
                                ),
                                style: HeronFitTheme.textTheme.bodyLarge,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter weight';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Invalid number';
                                  }
                                  if (double.parse(value) <= 0) {
                                    return 'Must be > 0';
                                  }
                                  return null;
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _heightController,
                                onChanged:
                                    (value) => registrationNotifier
                                        .updateHeight(value.trim()),
                                decoration: InputDecoration(
                                  labelText: 'Your Height',
                                  prefixIcon: const Icon(
                                    SolarIconsOutline.ruler,
                                    color: HeronFitTheme.primary,
                                    size: 20,
                                  ),
                                  suffixText: 'CM',
                                  suffixStyle: HeronFitTheme
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: HeronFitTheme.textMuted,
                                      ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: HeronFitTheme.bgSecondary,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 16,
                                  ),
                                ),
                                style: HeronFitTheme.textTheme.bodyLarge,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter height';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Invalid number';
                                  }
                                  if (int.parse(value) <= 0) {
                                    return 'Must be > 0';
                                  }
                                  return null;
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      registrationNotifier.updateWeight(
                        _weightController.text.trim(),
                      );
                      registrationNotifier.updateHeight(
                        _heightController.text.trim(),
                      );
                      context.pushNamed(AppRoutes.registerSetGoals);
                    }
                  },
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
                  child: const Text('Next'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
