import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Provider for the Supabase client instance
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Provider that exposes the stream of authentication state changes
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return supabaseClient.auth.onAuthStateChange;
});

// Optional: Provider to get the current user synchronously (use cautiously)
final currentUserProvider = Provider<User?>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return supabaseClient.auth.currentUser;
});

// You can add more auth-related logic (login, logout methods) here
// in a StateNotifierProvider if needed for more complex state management.
