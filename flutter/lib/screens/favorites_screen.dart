import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_provider.dart';
import '../models.dart';
import '../widgets/sn_card.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class FavoritesScreen extends ConsumerWidget {
  final void Function(String subjectId) onOpenSubject;
  final VoidCallback onGoToSearch;
  const FavoritesScreen({
    super.key,
    required this.onOpenSubject,
    required this.onGoToSearch,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(appProvider);
    final t        = state.theme;
    final notifier = ref.read(appProvider.notifier);
    final favs     = state.favDocs;

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App bar ──────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Favoris',
                      style: TextStyle(
                        fontSize:   22,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Fraunces',
                        color:      t.textColor,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:        t.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        '${favs.length}',
                        style: TextStyle(
                          fontSize:   13,
                          fontWeight: FontWeight.w800,
                          color:      t.accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── List ─────────────────────────────────────────────────────────
            favs.isEmpty
                ? SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('❤️', style: TextStyle(fontSize: 52)),
                          const SizedBox(height: 12),
                          Text(
                            'Aucun favori',
                            style: TextStyle(
                              fontSize:   16,
                              fontWeight: FontWeight.w700,
                              color:      t.textColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Ajoute des documents à tes favoris',
                            style: TextStyle(fontSize: 13, color: t.muted),
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton.icon(
                            onPressed: onGoToSearch,
                            icon: const Icon(Icons.search_rounded),
                            label: const Text('Chercher un document'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: t.accent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 90),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) {
                          final doc = favs[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: SnCard(
                              onTap:   () => onOpenSubject(doc.subjectId),
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Accent bar
                                  Container(
                                    width:        5,
                                    height:       42,
                                    decoration: BoxDecoration(
                                      color:        doc.subjectColor,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
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
                                            fontSize:   12.5,
                                            fontWeight: FontWeight.w700,
                                            color:      t.textColor,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${doc.subjectName} · ${doc.type.label}',
                                          style: TextStyle(
                                            fontSize: 10, color: t.muted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  FavoriteButton(
                                    isFavorite:  true,
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
                        childCount: favs.length,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, RichDocument doc, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer le document'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${doc.title}" ?\nCette action supprimera aussi le fichier associé si présent.'),
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
}
