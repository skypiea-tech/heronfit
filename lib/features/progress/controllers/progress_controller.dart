import 'dart:async'; // Import for FutureOr
// Keep for File usage if needed elsewhere, maybe remove later
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heronfit/features/progress/models/progress_record.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'progress_controller.g.dart';

// --- Progress Records Notifier --- Provider to fetch and add progress records

final progressRecordsProvider =
    StateNotifierProvider<ProgressNotifier, AsyncValue<List<ProgressRecord>>>((
      ref,
    ) {
      return ProgressNotifier(ref);
    });

class ProgressNotifier extends StateNotifier<AsyncValue<List<ProgressRecord>>> {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  final Ref _ref;

  ProgressNotifier(this._ref) : super(const AsyncValue.loading()) {
    fetchProgressRecords();
  }

  Future<void> fetchProgressRecords() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final response = await _supabaseClient
          .from('progress_records')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false);

      final data = response as List<dynamic>;
      final records =
          data
              .map((e) => ProgressRecord.fromJson(e as Map<String, dynamic>))
              .toList();
      state = AsyncValue.data(records);
    } catch (e, st) {
      print('Error fetching progress records: $e\n$st');
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addWeightEntry(double weight, String? picUrl) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    final previousState = state.value ?? [];

    final optimisticRecord = ProgressRecord(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      weight: weight,
      photoUrl: picUrl,
    );
    state = AsyncValue.data([optimisticRecord, ...previousState]);

    try {
      final Map<String, dynamic> newRecordData = {
        'user_id': user.id,
        'date': optimisticRecord.date.toIso8601String(),
        'weight_kg': weight, // Use weight_kg instead of weight
        'photo_url': picUrl,
      };

      final response =
          await _supabaseClient
              .from('progress_records')
              .insert(newRecordData)
              .select()
              .single();

      final confirmedRecord = ProgressRecord.fromJson(response);

      state = AsyncValue.data(
        previousState
            .map((r) => r.id == optimisticRecord.id ? confirmedRecord : r)
            .toList(),
      );
      await fetchProgressRecords();
    } catch (e, st) {
      print('Error adding weight entry: $e\n$st');
      state = AsyncValue.data(previousState);
      throw Exception('Failed to save weight entry: ${e.toString()}');
    }
  }
}

// --- User Goal Provider --- Fetches the user's goal string

@riverpod
Future<String?> userGoal(UserGoalRef ref) async {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id;

  if (userId == null) {
    return null;
  }

  try {
    final response =
        await supabase
            .from('users')
            .select('goal')
            .eq('id', userId)
            .maybeSingle();

    if (response == null || response['goal'] == null) {
      return null;
    }

    return response['goal'] as String?;
  } catch (e, st) {
    print('Error fetching user goal: $e\n$st');
    return null;
  }
}

// --- Progress Controller (Actions) --- Provider for actions like updating goal

final progressControllerProvider =
    StateNotifierProvider<ProgressController, AsyncValue<void>>((ref) {
      return ProgressController(ref);
    });

class ProgressController extends StateNotifier<AsyncValue<void>> {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  final Ref _ref;

  ProgressController(this._ref) : super(const AsyncValue.data(null));

  Future<void> updateGoal({required String goalType}) async {
    state = const AsyncValue.loading();
    final user = _supabaseClient.auth.currentUser;

    if (user == null) {
      state = AsyncValue.error('User not logged in', StackTrace.current);
      throw Exception('User not logged in');
    }

    try {
      await _supabaseClient
          .from('users')
          .update({'goal': goalType})
          .eq('id', user.id);

      state = const AsyncValue.data(null);
      _ref.invalidate(userGoalProvider);
    } catch (e, stackTrace) {
      print('Error updating goal: $e\n$stackTrace');
      state = AsyncValue.error('Failed to update goal: $e', stackTrace);
      throw Exception('Failed to update goal: ${e.toString()}');
    }
  }
}
