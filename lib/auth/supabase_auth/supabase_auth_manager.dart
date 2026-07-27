import 'dart:async';

import 'package:flutter/material.dart';
import '/auth/auth_manager.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'email_auth.dart';

import 'supabase_user_provider.dart';

export '/auth/base_auth_user_provider.dart';

class SupabaseAuthManager extends AuthManager with EmailSignInManager {
  @override
  Future signOut() {
    return SupaFlow.client.auth.signOut();
  }

  @override
  Future deleteUser(BuildContext context) async {
    try {
      if (!loggedIn) {
        print('Error: delete user attempted with no logged in user!');
        return;
      }
      await currentUser?.delete();
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    }
  }

  @override
  Future updateEmail({
    required String email,
    required BuildContext context,
  }) async {
    try {
      if (!loggedIn) {
        print('Error: update email attempted with no logged in user!');
        return;
      }
      await currentUser?.updateEmail(email);
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email change confirmation email sent')),
    );
  }

  @override
  Future<bool> updatePassword({
    required String newPassword,
    required BuildContext context,
  }) async {
    final session = SupaFlow.client.auth.currentSession;
    if (session == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Sua sessão expirou. Solicite um novo link de recuperação.'),
        ),
      );
      return false;
    }

    try {
      final response = await SupaFlow.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      if (response.user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível atualizar a senha.')),
        );
        return false;
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Não foi possível atualizar a senha: ${e.message}')),
      );
      return false;
    } catch (_) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível atualizar a senha.')),
      );
      return false;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Senha atualizada com sucesso.')),
    );
    return true;
  }

  @override
  Future<bool> resetPassword({
    required String email,
    required BuildContext context,
    String? redirectTo,
  }) async {
    try {
      await SupaFlow.client.auth
          .resetPasswordForEmail(email, redirectTo: redirectTo);
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
      return false;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('E-mail de recuperação enviado.')),
    );
    return true;
  }

  @override
  Future<BaseAuthUser?> signInWithEmail(
    BuildContext context,
    String email,
    String password,
  ) =>
      _signInOrCreateAccount(
        context,
        () => emailSignInFunc(email, password),
      );

  @override
  Future<BaseAuthUser?> createAccountWithEmail(
    BuildContext context,
    String email,
    String password, {
    Map<String, dynamic>? data,
  }) =>
      _signInOrCreateAccount(
        context,
        () => emailCreateAccountFunc(email, password, data: data),
      );

  /// Tries to sign in or create an account using Supabase Auth.
  /// Returns the User object if sign in was successful.
  Future<BaseAuthUser?> _signInOrCreateAccount(
    BuildContext context,
    Future<User?> Function() signInFunc,
  ) async {
    try {
      final user = await signInFunc();
      final authUser = user == null ? null : InLidaWebSupabaseUser(user);

      // Update currentUser here in case user info needs to be used immediately
      // after a user is signed in. This should be handled by the user stream,
      // but adding here too in case of a race condition where the user stream
      // doesn't assign the currentUser in time.
      final hasActiveSession =
          SupaFlow.client.auth.currentSession?.user.id == user?.id;
      if (authUser != null && hasActiveSession) {
        currentUser = authUser;
        AppStateNotifier.instance.update(authUser);
      }
      return authUser;
    } on AuthException catch (e) {
      final errorMsg = e.message.contains('User already registered')
          ? 'Error: The email is already in use by a different account'
          : 'Error: ${e.message}';
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
      return null;
    }
  }
}
