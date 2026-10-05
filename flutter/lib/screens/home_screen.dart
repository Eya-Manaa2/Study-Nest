import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_provider.dart';
import '../models.dart';
import '../widgets/sn_card.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class HomeScreen extends ConsumerWidget {
  final void Function(String subjectId) onOpenSubject;
  final VoidCallback onGoToSearch;
  final VoidCallback onGoToFavorites;
  final VoidCallback onGoToSubjects;
  final VoidCallback onGoToNotes;
  final VoidCallback onGoToProfile;
  final VoidCallback onGoToAssistant;

  const HomeScreen({
    super.key,
    required this.onOpenSubject,
    required this.onGoToSearch,
    required this.onGoToFavorites,
    required this.onGoToSubjects,
    required this.onGoToNotes,
    required this.onGoToProfile,
    required this.onGoToAssistant,
  });

  void _showDeleteDialog(BuildContext context, RichDocument doc, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer le document'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${doc.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              
              try {
                final firestoreService = ref.read(firestoreServiceProvider);
                final storageService = ref.read(storageServiceProvider);
                
                // Supprimer le fichier de Firebase Storage
                if (doc.doc.fileName != null) {
                  await storageService.deleteFile(
                    subjectId: doc.subjectId,
                    fileName: doc.doc.fileName!,
                  );
                }
                
                // Supprimer le document de Firestore
                await firestoreService.deleteDocument(doc.subjectId, doc.id);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Document supprimé avec succès'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur lors de la suppression: $e'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(appProvider);
    final t        = state.theme;
    final notifier = ref.read(appProvider.notifier);
    final recent   = state.recentDocs;
    final favCount = state.favDocs.length;
    final totalDocs = state.subjects.fold<int>(0, (acc, s) => acc + s.docCount);
    final authState = ref.watch(authStateProvider);

    final completedTodos = state.todos.where((todo) => todo.isCompleted).length;
    final pendingTodos = state.todos.length - completedTodos;
    final streak = (state.subjects.length + state.todos.length + completedTodos) % 9 + 3;
    final highlightSubject = state.subjects.isNotEmpty ? state.subjects.first.name : 'Aucune matière';
    final nextAction = state.subjects.isNotEmpty
        ? 'Réviser ${state.subjects.first.name} pendant 15 min'
        : 'Ajouter une première matière';
    final dailyChallenge = state.subjects.isNotEmpty
        ? 'Défi du jour : 10 min sur ${state.subjects.first.name}'
        : 'Défi du jour : crée ta première matière';

    final today = DateTime.now();
    final todayString = '${today.day}/${today.month}/${today.year}';
    
    String userName = 'Utilisateur';
    authState.whenData((user) {
      if (user != null) {
        userName = user.displayName ?? user.email?.split('@')[0] ?? 'Utilisateur';
      }
    });

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onGoToProfile,
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: t.accent,
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'E',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Fraunces',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bonjour, $userName',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Fraunces',
                          color: t.textColor,
                        ),
                      ),
                      Text(
                        todayString,
                        style: TextStyle(fontSize: 12, color: t.muted),
                      ),
                    ],
                  ),
                ),
                _CircleIconBtn(
                  icon: Icons.notifications_none_rounded,
                  onTap: () => _showSnack(context, 'Notifications — bientôt disponible'),
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 20)),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...state.semesters.map((sem) => SnChip(
                    label: sem.name,
                    active: false,
                    onTap: () => _showSnack(context, '${sem.name} sélectionné'),
                  )),
                SnChip(label: '+', active: false, onTap: () => _showAddSemesterDialog(context, ref)),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 20)),

        if (state.subjects.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: t.surface,
                  border: Border.all(color: t.line),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: t.accent.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Premiers pas',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Fraunces',
                        color: t.textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Crée ta première matière et organise ton semestre dès maintenant.',
                      style: TextStyle(
                        fontSize: 13,
                        color: t.muted,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _PrimaryActionChip(
                          label: 'Créer une matière',
                          icon: Icons.school_rounded,
                          onTap: onGoToSubjects,
                        ),
                        _PrimaryActionChip(
                          label: 'Écrire une note',
                          icon: Icons.note_add_rounded,
                          onTap: onGoToNotes,
                        ),
                        _PrimaryActionChip(
                          label: 'Quiz IA',
                          icon: Icons.psychology_rounded,
                          onTap: onGoToAssistant,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.1,
                children: [
                  _StatCard(icon: Icons.folder_rounded, value: totalDocs, label: 'Documents rangés', onTap: onGoToSubjects),
                  _StatCard(icon: Icons.favorite_rounded, value: favCount, label: 'Favoris', onTap: onGoToFavorites),
                  _StatCard(icon: Icons.school_rounded, value: state.subjects.length, label: 'Matières', onTap: onGoToSubjects),
                  _StatCard(icon: Icons.note_rounded, value: state.notes.length, label: 'Notes rapides', onTap: onGoToNotes),
                ],
              ),
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [t.accent.withValues(alpha: 0.18), t.surface],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: t.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: t.accent,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.local_fire_department_rounded, size: 14, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              '$streak jours',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Objectif du jour',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: t.muted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    pendingTodos == 0
                        ? 'Toutes les tâches sont terminées 👏'
                        : 'Poursuis sur ${pendingTodos == 1 ? '1 tâche' : '$pendingTodos tâches'} à finir',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Fraunces',
                      color: t.textColor,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _DailyFocusTile(
                          label: 'Focus',
                          value: highlightSubject,
                          icon: Icons.school_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _DailyFocusTile(
                          label: 'Progression',
                          value: state.todos.isEmpty ? '0/1' : '$completedTodos/${state.todos.length}',
                          icon: Icons.check_circle_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  InkWell(
                    onTap: onGoToAssistant,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: t.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: t.line),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.psychology_rounded, color: t.accent, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Plan de révision 25 min sur $highlightSubject',
                              style: TextStyle(
                                color: t.textColor,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_forward_rounded, color: t.muted, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: t.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: t.line),
              ),
              child: Row(
                children: [
                  Icon(Icons.flash_on_rounded, size: 26, color: t.accent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Prochaine action recommandée',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                            color: t.muted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          nextAction,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: t.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onGoToAssistant,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: t.accent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Lancer'),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: t.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: t.line),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: t.accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.emoji_events_rounded, color: t.accent, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Défi du jour',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: t.muted,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dailyChallenge,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: t.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: onGoToAssistant,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: t.accent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Go'),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Le plan de la journée',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Fraunces',
                    color: t.textColor,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.05,
                  children: [
                    _QuickStudyAction(
                      icon: Icons.psychology_rounded,
                      label: 'Quiz 5 min',
                      onTap: onGoToAssistant,
                    ),
                    _QuickStudyAction(
                      icon: Icons.summarize_rounded,
                      label: 'Résumé rapide',
                      onTap: onGoToAssistant,
                    ),
                    _QuickStudyAction(
                      icon: Icons.event_note_rounded,
                      label: 'Plan de révision',
                      onTap: onGoToAssistant,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pourquoi StudyNest ?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Fraunces',
                    color: t.textColor,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.72,
                  children: const [
                    _DifferentiatorCard(
                      icon: Icons.psychology_rounded,
                      title: 'IA révision',
                      subtitle: 'Quiz, résumés et plans',
                    ),
                    _DifferentiatorCard(
                      icon: Icons.auto_awesome_mosaic_rounded,
                      title: 'Tout centralisé',
                      subtitle: 'Matières, notes, docs',
                    ),
                    _DifferentiatorCard(
                      icon: Icons.speed_rounded,
                      title: 'Gain de temps',
                      subtitle: 'Moins de friction, plus d’action',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SectionHeader(
              title: 'Récemment ajoutés',
              actionLabel: 'Tout voir',
              onAction: onGoToSearch,
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 12)),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final doc = recent[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SnCard(
                    onTap: () => onOpenSubject(doc.subjectId),
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        DocIconTile(icon: doc.type.icon),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doc.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: ref.watch(appProvider).theme.textColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${doc.subjectName} · ${doc.type.label}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: ref.watch(appProvider).theme.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        FavoriteButton(
                          isFavorite: doc.favorite,
                          accentColor: t.accent,
                          onTap: () => notifier.toggleFavorite(doc.id),
                        ),
                        GestureDetector(
                          onTap: () => _showDeleteDialog(context, doc, ref),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(Icons.delete_outline, size: 16, color: Colors.red.shade400),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: recent.length,
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: () => _showSnack(context, 'Offre Pro — bientôt disponible'),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [t.accent, t.accent2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: t.accent.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.rocket_launch_rounded, size: 32, color: Colors.white),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Passe à StudyNest Pro',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Fraunces',
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Stockage illimité, thèmes exclusifs, sauvegarde auto',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: t.accent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => _showSnack(context, 'Offre Pro — bientôt disponible'),
                      child: const Text(
                        'Voir',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 90)),
      ],
    );
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAddSemesterDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un semestre'),
        content: SingleChildScrollView(
          child: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Nom du semestre',
              hintText: 'Ex: Semestre 3',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) return;
              ref.read(appProvider.notifier).addSemester(
                nameController.text.trim(),
              );
              Navigator.pop(context);
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }
}

class _QuickStudyAction extends ConsumerWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickStudyAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appProvider).theme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: t.line),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: t.accent),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: t.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyFocusTile extends ConsumerWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DailyFocusTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appProvider).theme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: t.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: t.accent),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: t.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5,
              color: t.textColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _DifferentiatorCard extends ConsumerWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _DifferentiatorCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appProvider).theme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.line),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 26, color: t.accent),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: t.textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.5,
              color: t.muted,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionChip extends ConsumerWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PrimaryActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appProvider).theme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: t.accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: t.accent.withValues(alpha: 0.15)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: t.accent),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: t.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends ConsumerWidget {
  final IconData icon;
  final int value;
  final String label;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appProvider).theme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: t.line),
          boxShadow: [
            BoxShadow(
              color: t.accent.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: t.accent),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$value',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Fraunces',
                      color: t.textColor,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: t.muted, height: 1.2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIconBtn extends ConsumerWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appProvider).theme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: t.surface,
          shape: BoxShape.circle,
          border: Border.all(color: t.line),
          boxShadow: [
            BoxShadow(
              color: t.accent.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: t.textColor),
      ),
    );
  }
}
