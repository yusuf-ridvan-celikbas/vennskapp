import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';

/// Values come from `--dart-define-from-file=env/local.json` (see README).
const _supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'http://127.0.0.1:54321',
);
const _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (_supabaseAnonKey.isEmpty) {
    throw StateError(
      'SUPABASE_ANON_KEY is missing. Run with '
      '--dart-define-from-file=env/local.json',
    );
  }
  await Supabase.initialize(
      url: _supabaseUrl, publishableKey: _supabaseAnonKey);
  runApp(const ProviderScope(child: VennskApp()));
}
