import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_provider.dart';
import '../widgets/sn_card.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import '../themes.dart';

class ProfileScreen extends ConsumerWidget {
  final VoidCallback onLogout;
  final VoidCallback onGoToNotes;
  final VoidCallback onGoToTodos;

  const ProfileScreen({
    super.key,
    required this.onLogout,
    required this.onGoToNotes,
    required this.onGoToTodos,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(appProvider);
    final t        = state.theme;
    final notifier = ref.read(appProvider.notifier);
    final authState = ref.watch(authStateProvider);
    
    // Récupérer les infos utilisateur depuis Firebase Auth
    String userName = 'Utilisateur';
    String userEmail = 'utilisateur@example.com';
    String userInitial = 'U';
    
    authState.whenData((user) {
      if (user != null) {
        userName = user.displayName ?? user.email?.split('@')[0] ?? 'Utilisateur';
        userEmail = user.email ?? 'utilisateur@example.com';
        userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
      }
    });

    void snack(String msg) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:  Text(msg),
          behavior: SnackBarBehavior.floating,
          shape:    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }

    final menuItems = [
      _MenuItem(
        icon: Icons.menu_book_rounded,
        label: 'Mes notes',
        onTap: onGoToNotes,
        showChevron: true,
      ),
      _MenuItem(
        icon: Icons.check_circle_rounded,
        label: 'Mes tâches',
        onTap: onGoToTodos,
        showChevron: true,
      ),
      _MenuItem(
        icon: Icons.cloud_upload_outlined,
        label: 'Sauvegarde & synchronisation',
        onTap: () => snack('Sauvegarde à jour · Firebase'),
        showChevron: true,
      ),
      _MenuItem(
        icon: Icons.support_agent_rounded,
        label: 'Support',
        onTap: () => _showSupportDialog(context),
        showChevron: true,
      ),
      _MenuItem(
        icon: Icons.privacy_tip_outlined,
        label: 'Politique de confidentialité',
        onTap: () => _showPrivacyDialog(context),
        showChevron: true,
      ),
      _MenuItem(
        icon: Icons.share_outlined,
        label: 'Partager un dossier',
        onTap: () => snack('Partage de dossiers — arrive en V2'),
        showChevron: true,
      ),
      _MenuItem(
        icon: Icons.fingerprint_rounded,
        label: 'Verrouillage biométrique',
        badge: 'PREMIUM',
        onTap: () => snack('Fonctionnalité Premium'),
      ),
      _MenuItem(
        icon: Icons.delete_forever_rounded,
        label: 'Réinitialiser toutes les données',
        danger: true,
        onTap: () => _showResetDialog(context, ref),
      ),
      _MenuItem(
        icon: Icons.logout_rounded,
        label: 'Se déconnecter',
        danger: true,
        onTap: onLogout,
      ),
    ];

    return Scaffold(
      backgroundColor: t.bg,
      body: CustomScrollView(
        slivers: [
          // ── Profile hero ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [t.accent, t.accent2],
                  begin:  Alignment.topLeft,
                  end:    Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => _showEditProfileDialog(context, ref, userName, userEmail),
                      child: Stack(
                        children: [
                          Container(
                            width:  64,
                            height: 64,
                            decoration: BoxDecoration(
                              color:        Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              userInitial,
                              style: const TextStyle(
                                fontSize:   24,
                                fontWeight: FontWeight.w800,
                                color:      Colors.white,
                                fontFamily: 'Fraunces',
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width:  24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Icon(
                                Icons.edit,
                                size: 14,
                                color: t.accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize:   19,
                            fontWeight: FontWeight.w800,
                            color:      Colors.white,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          userEmail,
                          style: TextStyle(
                            fontSize: 12.5,
                            color:    Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:        Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Text(
                            'Gratuit',
                            style: TextStyle(
                              fontSize:   10.5,
                              fontWeight: FontWeight.w700,
                              color:      Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Theme picker ──────────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: SectionHeader(title: 'Thème immersif'),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 96,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding:         const EdgeInsets.fromLTRB(20, 8, 20, 0),
                itemCount:       appThemes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (ctx, i) {
                  final theme    = appThemes[i];
                  final isActive = state.activeThemeId == theme.id;

                  return GestureDetector(
                    onTap: () {
                      notifier.setTheme(theme.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:  Text('Thème ${theme.label} activé'),
                          behavior: SnackBarBehavior.floating,
                          shape:    RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: theme.bg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isActive ? theme.accent : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: theme.accent.withValues(alpha: 0.35),
                                      blurRadius: 14,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 6,
                                    ),
                                  ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            theme.emoji,
                            style: const TextStyle(fontSize: 26),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          theme.label,
                          style: TextStyle(
                            fontSize:   10.5,
                            fontWeight: FontWeight.w700,
                            color: isActive ? t.accent : t.muted,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Account section ───────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: SectionHeader(title: 'Compte'),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color:        t.surface,
                  borderRadius: BorderRadius.circular(20),
                  border:       Border.all(color: t.line),
                  boxShadow: [
                    BoxShadow(
                      color:      t.accent.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset:     const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: menuItems.asMap().entries.map((entry) {
                    final i    = entry.key;
                    final item = entry.value;
                    final isLast = i == menuItems.length - 1;
                    return _MenuRow(
                      item:    item,
                      isDivided: !isLast,
                      theme:   t,
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // Version label
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 110),
              child: Center(
                child: Text(
                  'StudyNest v1.0.0 · Fait avec soin pour les étudiants',
                  style: TextStyle(fontSize: 11, color: t.muted),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, WidgetRef ref, String currentName, String currentEmail) {
    final nameController = TextEditingController(text: currentName);
    final emailController = TextEditingController(text: currentEmail);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le profil'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  hintText: 'Votre nom',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'votre@email.com',
                ),
                enabled: false, // Email cannot be changed via Firebase Auth
              ),
              const SizedBox(height: 8),
              const Text(
                'Note: L\'email ne peut être modifié via Firebase Auth',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              try {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await user.updateDisplayName(nameController.text.trim());
                }
                if (!context.mounted) return;
                Navigator.pop(context);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profil mis à jour avec succès'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur: $e'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Support StudyNest'),
        content: const Text(
          'Pour toute question, aide ou demande concernant l’application :\n\neyamanaa3@gmail.com',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Politique de confidentialité'),
        content: const SingleChildScrollView(
          child: Text(
            'StudyNest traite les données nécessaires au bon fonctionnement de l’application : matières, notes, tâches, documents et préférences utilisateur.\n\nLes données ne sont pas vendues à des tiers. Elles sont utilisées pour organiser l’expérience d’étude, gérer la synchronisation si elle est activée, et améliorer la qualité du service.\n\nVous pouvez demander la suppression ou la consultation de vos données via le support : eyamanaa3@gmail.com',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réinitialiser toutes les données'),
        content: const Text('Êtes-vous sûr de vouloir supprimer TOUTES vos données (matières, documents, notes, tâches) ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                final firestoreService = ref.read(firestoreServiceProvider);
                await firestoreService.deleteAllUserData();
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Toutes les données ont été supprimées'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $e'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer tout'),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _MenuItem {
  final IconData icon;
  final String label;
  final String? badge;
  final bool showChevron;
  final bool danger;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
    this.showChevron = false,
    this.danger = false,
  });
}

class _MenuRow extends StatelessWidget {
  final _MenuItem item;
  final bool isDivided;
  final dynamic theme;

  const _MenuRow({
    required this.item,
    required this.isDivided,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Column(
      children: [
        InkWell(
          onTap:        item.onTap,
          borderRadius: isDivided
              ? BorderRadius.zero
              : const BorderRadius.vertical(bottom: Radius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size:  22,
                  color: item.danger ? t.accent : t.textColor,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize:   14,
                      fontWeight: FontWeight.w600,
                      color:      item.danger ? t.accent : t.textColor,
                    ),
                  ),
                ),
                if (item.badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color:        t.surface2,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      item.badge!,
                      style: TextStyle(
                        fontSize:   10,
                        fontWeight: FontWeight.w800,
                        color:      t.accent,
                      ),
                    ),
                  ),
                if (item.showChevron)
                  Icon(
                    Icons.chevron_right_rounded,
                    size:  20,
                    color: t.muted,
                  ),
              ],
            ),
          ),
        ),
        if (isDivided) Divider(height: 1, color: t.line, indent: 52),
      ],
    );
  }
}
