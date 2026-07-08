import '/backend/supabase/supabase.dart';

Future<User?> emailSignInFunc(
  String email,
  String password,
) async {
  final AuthResponse res = await SupaFlow.client.auth
      .signInWithPassword(email: email, password: password);
  return res.user;
}

Future<User?> emailCreateAccountFunc(
  String email,
  String password, {
  Map<String, dynamic>? data,
}) async {
  final AuthResponse res = await SupaFlow.client.auth.signUp(
    email: email,
    password: password,
    data: data,
  );

  return res.user;
}
