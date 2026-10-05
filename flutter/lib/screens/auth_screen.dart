import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_provider.dart';
import '../services/firebase_auth_service.dart';

class AuthScreen extends ConsumerStatefulWidget {
  final VoidCallback onLogin;
  const AuthScreen({super.key, required this.onLogin});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLoading = false;
  bool _showEmailForm = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    
    try {
      final authService = ref.read(firebaseAuthServiceProvider);
      await authService.signInWithGoogle();
      widget.onLogin();
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleEmailSignIn() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final authService = ref.read(firebaseAuthServiceProvider);
      await authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      widget.onLogin();
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleEmailSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final authService = ref.read(firebaseAuthServiceProvider);
      await authService.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      widget.onLogin();
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(appProvider).theme;

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // ── Logo ────────────────────────────────────────────────────────
              Container(
                width:  140,
                height: 140,
                decoration: BoxDecoration(
                  color:        t.surface2,
                  borderRadius: BorderRadius.circular(38),
                  boxShadow: [
                    BoxShadow(
                      color:      t.accent.withValues(alpha: 0.18),
                      blurRadius: 40,
                      offset:     const Offset(0, 14),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(38),
                  child: Image.asset(
                    'assets/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Wordmark ─────────────────────────────────────────────────────
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize:   38,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Fraunces',
                    color:      t.textColor,
                    letterSpacing: -0.5,
                  ),
                  children: [
                    TextSpan(text: 'Study'),
                    TextSpan(
                      text:  'Nest',
                      style: TextStyle(color: t.accent),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Ton espace, tes études, tout organisé.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize:  16,
                  height:    1.5,
                  color:     t.muted,
                  fontFamily: 'Manrope',
                ),
              ),

              const SizedBox(height: 32),

              if (!_showEmailForm) ...[
                SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: const [
                      _ValuePill(icon: Icons.menu_book_rounded, label: 'Matières'),
                      _ValuePill(icon: Icons.note_alt_rounded, label: 'Notes'),
                      _ValuePill(icon: Icons.check_circle_rounded, label: 'Tâches'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // ── Auth buttons ─────────────────────────────────────────────────
              if (!_showEmailForm) ...[
                _AuthButton(
                  label: _isLoading ? 'Connexion...' : 'Continuer avec Google',
                  icon:  Icons.g_mobiledata_rounded,
                  filled: true,
                  onTap:  _isLoading ? null : _handleGoogleSignIn,
                ),

                const SizedBox(height: 12),

                _AuthButton(
                  label: 'Continuer avec e-mail',
                  icon:  Icons.mail_outline_rounded,
                  filled: false,
                  onTap:  () => setState(() => _showEmailForm = true),
                ),
              ] else ...[
                // Email form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          filled: true,
                          fillColor: t.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: t.line),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: t.line),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre email';
                          }
                          if (!value.contains('@')) {
                            return 'Email invalide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          hintText: 'Mot de passe',
                          filled: true,
                          fillColor: t.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: t.line),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: t.line),
                          ),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre mot de passe';
                          }
                          if (value.length < 6) {
                            return 'Le mot de passe doit contenir au moins 6 caractères';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _AuthButton(
                              label: _isLoading ? 'Connexion...' : 'Se connecter',
                              icon:  Icons.login,
                              filled: true,
                              onTap: _isLoading ? null : _handleEmailSignIn,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _AuthButton(
                              label: _isLoading ? 'Création...' : 'S\'inscrire',
                              icon:  Icons.person_add,
                              filled: false,
                              onTap: _isLoading ? null : _handleEmailSignUp,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => setState(() => _showEmailForm = false),
                        child: Text(
                          'Retour',
                          style: TextStyle(color: t.accent),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const Spacer(),

              // ── Fine print ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 12,
                      color:    t.muted,
                      height:   1.6,
                      fontFamily: 'Manrope',
                    ),
                    children: [
                      const TextSpan(text: 'En continuant, tu acceptes nos '),
                      TextSpan(
                        text:  'Conditions d’utilisation',
                        style: TextStyle(
                          color:      t.accent,
                          fontWeight: FontWeight.w700,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => _showInfo('Conditions d’utilisation — StudyNest traite les données nécessaires au bon fonctionnement de l’application.'),
                      ),
                      const TextSpan(text: ' et notre '),
                      TextSpan(
                        text:  'Politique de confidentialité',
                        style: TextStyle(
                          color:      t.accent,
                          fontWeight: FontWeight.w700,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => _showInfo('Politique publique : StudyNest protège la vie privée. Contact : eyamanaa3@gmail.com'),
                      ),
                      const TextSpan(text: '.'),
                    ],
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

class _ValuePill extends ConsumerWidget {
  final IconData icon;
  final String label;

  const _ValuePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appProvider).theme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border.all(color: theme.line),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.accent),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: theme.textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthButton extends ConsumerWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback? onTap;

  const _AuthButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appProvider).theme;

    if (filled) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: onTap != null ? t.accent : t.muted,
            foregroundColor: Colors.white,
            elevation:       0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: onTap,
          icon:  Icon(icon, size: 20),
          label: Text(
            label,
            style: const TextStyle(
              fontSize:   15,
              fontWeight: FontWeight.w700,
              fontFamily: 'Manrope',
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width:  double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: onTap != null ? t.textColor : t.muted,
          side:            BorderSide(color: onTap != null ? t.line : t.muted, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onTap,
        icon:  Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(
            fontSize:   15,
            fontWeight: FontWeight.w700,
            fontFamily: 'Manrope',
          ),
        ),
      ),
    );
  }
}
