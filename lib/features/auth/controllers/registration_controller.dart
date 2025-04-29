import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart'; // Added for debugPrint
import '../models/registration_model.dart';

class RegistrationController extends StateNotifier<RegistrationModel> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Ref _ref; // Add Ref if needed for reading other providers

  RegistrationController(this._ref) : super(const RegistrationModel());

  void updateFirstName(String value) =>
      state = state.copyWith(firstName: _capitalizeFirstLetter(value));

  void updateLastName(String value) =>
      state = state.copyWith(lastName: _capitalizeFirstLetter(value));

  void updateEmail(String value) => state = state.copyWith(email: value);
  void updatePassword(String value) => state = state.copyWith(password: value);
  void updateGender(String value) => state = state.copyWith(gender: value);
  void updateBirthday(String value) => state = state.copyWith(birthday: value);
  void updateWeight(String value) => state = state.copyWith(weight: value);
  void updateHeight(String value) => state = state.copyWith(height: value);
  void updateGoal(String value) => state = state.copyWith(goal: value);

  void reset() => state = const RegistrationModel();

  // Step 1: Initiate Sign Up (sends verification email)
  Future<void> initiateSignUp() async {
    debugPrint('Attempting to initiate sign up for: ${state.email}');
    try {
      final AuthResponse res = await _supabase.auth.signUp(
        email: state.email,
        password: state.password,
        // Email verification is handled by Supabase settings
      );
      debugPrint('Supabase signUp call completed.');
      // Check if user requires confirmation - success even if user exists but is unconfirmed
      if (res.user == null && res.session != null) {
        debugPrint(
          'Sign up initiated, session exists but user is null (likely existing unconfirmed user).',
        );
        // Allow proceeding to verification
      } else if (res.user != null) {
        debugPrint(
          'Sign up initiated successfully for new user: ${res.user!.id}',
        );
        // Allow proceeding to verification
      } else {
        // This case might indicate an unexpected issue or configuration problem
        debugPrint('Supabase signUp response has null user and null session.');
        throw Exception('Sign up initiation failed. Please try again.');
      }
    } on AuthException catch (e) {
      debugPrint(
        'Supabase AuthException during signUp initiation: ${e.message}',
      );
      if (e.message.toLowerCase().contains('user already registered')) {
        // Consider if you want to let them proceed to verify anyway, or show error
        // Let's throw a specific error for now.
        throw Exception(
          'This email is already registered. Please log in or try verifying.',
        );
      }
      throw Exception('Sign up failed: ${e.message}');
    } catch (e) {
      debugPrint('General error during signUp initiation: ${e.toString()}');
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  // Step 2: Insert User Profile (called AFTER successful OTP verification)
  Future<void> insertUserProfile(String userId) async {
    debugPrint('Attempting to insert profile for user ID: $userId');
    try {
      await _supabase.from('users').insert({
        'id': userId,
        'first_name': state.firstName,
        'last_name': state.lastName,
        'email_address': state.email, // Use the correct column name
        'gender': state.gender,
        'birthday': state.birthday.isEmpty ? null : state.birthday,
        'weight': state.weight,
        'height': int.tryParse(state.height),
        'goal': state.goal,
        'created_at': DateTime.now().toIso8601String(),
      });
      debugPrint('User profile inserted successfully for user: $userId');
    } catch (e) {
      debugPrint('Error inserting user profile for $userId: ${e.toString()}');
      // Decide how to handle profile insertion failure - user is verified but profile failed.
      // Maybe log it, notify admin, or inform user?
      // For now, rethrow to indicate the step failed.
      throw Exception('Failed to save user profile details: ${e.toString()}');
    }
  }

  String _capitalizeFirstLetter(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }
}

final registrationProvider =
    StateNotifierProvider<RegistrationController, RegistrationModel>((ref) {
      return RegistrationController(ref);
    });
