import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Firebase Auth Service ─────────────────────────────────────────────────────

class FirebaseAuthService {
  FirebaseAuth? get _auth {
    if (Firebase.apps.isEmpty) return null;
    return FirebaseAuth.instance;
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Stream d'état d'authentification
  Stream<User?> get authStateChanges => _auth?.authStateChanges() ?? const Stream.empty();

  // Utilisateur courant
  User? get currentUser => _auth?.currentUser;

  // Login avec email/password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final auth = _auth;
    if (auth == null) {
      throw Exception('Firebase non initialisé');
    }

    try {
      return await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Création de compte avec email/password
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final auth = _auth;
    if (auth == null) {
      throw Exception('Firebase non initialisé');
    }

    try {
      return await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Login avec Google
  Future<UserCredential> signInWithGoogle() async {
    final auth = _auth;
    if (auth == null) {
      throw Exception('Firebase non initialisé');
    }

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Sign in aborted by user');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await auth.signInWithCredential(credential);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    final auth = _auth;
    if (auth == null) {
      return;
    }

    try {
      await Future.wait([
        auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw Exception('Erreur lors de la déconnexion: $e');
    }
  }

  // Réinitialisation du mot de passe
  Future<void> sendPasswordResetEmail(String email) async {
    final auth = _auth;
    if (auth == null) {
      throw Exception('Firebase non initialisé');
    }

    try {
      await auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Suppression du compte
  Future<void> deleteAccount() async {
    final auth = _auth;
    if (auth == null) {
      throw Exception('Firebase non initialisé');
    }

    try {
      await auth.currentUser?.delete();
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Gestion des erreurs
  String _handleAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'Aucun utilisateur trouvé avec cet email.';
        case 'wrong-password':
          return 'Mot de passe incorrect.';
        case 'email-already-in-use':
          return 'Cet email est déjà utilisé.';
        case 'invalid-email':
          return 'Format d\'email invalide.';
        case 'weak-password':
          return 'Le mot de passe est trop faible (minimum 6 caractères).';
        case 'user-disabled':
          return 'Ce compte a été désactivé.';
        case 'too-many-requests':
          return 'Trop de tentatives. Réessayez plus tard.';
        case 'operation-not-allowed':
          return 'Opération non autorisée.';
        default:
          return 'Erreur d\'authentification: ${error.message}';
      }
    }
    return 'Erreur inconnue: $error';
  }
}

// ─── Providers ─────────────────────────────────────────────────────────────────

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(firebaseAuthServiceProvider);
  return authService.authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  final authService = ref.watch(firebaseAuthServiceProvider);
  return authService.currentUser;
});
