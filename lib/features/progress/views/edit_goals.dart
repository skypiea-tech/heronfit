import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/theme.dart'; // Import HeronFitTheme
import 'package:heronfit/features/progress/controllers/progress_controller.dart';
// Import SolarIcons

class EditGoalsWidget extends ConsumerStatefulWidget {
  const EditGoalsWidget({super.key});

  @override
  ConsumerState<EditGoalsWidget> createState() => _EditGoalsWidgetState();
}

class _EditGoalsWidgetState extends ConsumerState<EditGoalsWidget> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedGoalType;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadExistingGoals();
  }

  void _loadExistingGoals() {
    final goalAsyncValue = ref.read(userGoalProvider);
    goalAsyncValue.whenData((goal) {
      if (goal != null && mounted) {
        setState(() {
          _selectedGoalType = goal;
        });
      }
    });
  }

  Future<void> _submitGoals() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        await ref
            .read(progressControllerProvider.notifier)
            .updateGoal(goalType: _selectedGoalType!);

        ref.invalidate(userGoalProvider);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Goal updated successfully!')),
        );
        context.pop();
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'Failed to update goal: $e';
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $_errorMessage')));
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      setState(() {
        _errorMessage = 'Please select a goal.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
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
            'Edit Goals',
            style: theme.textTheme.titleLarge?.copyWith(
              color: HeronFitTheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: _buildForm(context),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 4,
                      color: Colors.black.withAlpha(25),
                      offset: const Offset(0, 2),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(
                            Icons.radar,
                            color: theme.primaryColor,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Select Your Primary Goal',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedGoalType,
                        items: const [
                          DropdownMenuItem(
                            value: 'Weight Loss',
                            child: Text('Weight Loss'),
                          ),
                          DropdownMenuItem(
                            value: 'Gain Muscle',
                            child: Text('Gain Muscle'),
                          ),
                          DropdownMenuItem(
                            value: 'Improve Endurance',
                            child: Text('Improve Endurance'),
                          ),
                          DropdownMenuItem(
                            value: 'Overall Fitness',
                            child: Text('Overall Fitness'),
                          ),
                        ],
                        onChanged: (val) {
                          setState(() {
                            _selectedGoalType = val;
                            _errorMessage = null;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Select a goal',
                          filled: true,
                          fillColor:
                              theme.inputDecorationTheme.fillColor ??
                              theme.scaffoldBackgroundColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Please select a goal'
                                    : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitGoals,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBackgroundColor: theme.colorScheme.secondary
                      .withAlpha(128),
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                        : Text(
                          'Save Goal',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
