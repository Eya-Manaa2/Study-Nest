import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_provider.dart';
import '../models.dart';
import '../widgets/sn_card.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final void Function(String subjectId) onOpenSubject;
  const SearchScreen({super.key, required this.onOpenSubject});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state    = ref.watch(appProvider);
    final t        = state.theme;
    final notifier = ref.read(appProvider.notifier);
    final results  = state.searchDocs(_query);

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── App bar ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Text(
                'Recherche',
                style: TextStyle(
                  fontSize:   22,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Fraunces',
                  color:      t.textColor,
                ),
              ),
            ),

            // ── Search field ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller:  _ctrl,
                autofocus:   false,
                style:       TextStyle(color: t.textColor),
                onChanged:   (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText:    'Cours, TD, matière…',
                  prefixIcon:  Icon(Icons.search_rounded, color: t.muted),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon:  Icon(Icons.clear_rounded, color: t.muted),
                          onPressed: () {
                            _ctrl.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Results ────────────────────────────────────────────────────
            Expanded(
              child: _query.trim().isEmpty
                  ? _EmptySearch(muted: t.muted)
                  : results.isEmpty
                      ? _NoResults(query: _query, muted: t.muted, text: t.textColor)
                      : ListView.separated(
                          padding:    const EdgeInsets.fromLTRB(20, 0, 20, 90),
                          itemCount:  results.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (ctx, i) {
                            final doc = results[i];
                            return _DocRow(
                              doc:         doc,
                              accentColor: t.accent,
                              onTap:       () => widget.onOpenSubject(doc.subjectId),
                              onFavorite:  () => notifier.toggleFavorite(doc.id),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _DocRow extends ConsumerWidget {
  final RichDocument doc;
  final Color accentColor;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  const _DocRow({
    required this.doc,
    required this.accentColor,
    required this.onTap,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appProvider).theme;
    return SnCard(
      onTap:   onTap,
      padding: const EdgeInsets.all(16),
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
                    fontSize:   12.5,
                    fontWeight: FontWeight.w700,
                    color:      t.textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${doc.subjectName} · ${doc.type.label}',
                  style: TextStyle(fontSize: 10, color: t.muted),
                ),
              ],
            ),
          ),
          FavoriteButton(
            isFavorite:  doc.favorite,
            accentColor: accentColor,
            onTap:       onFavorite,
          ),
          GestureDetector(
            onTap: () => _showDeleteDialog(context, ref),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(Icons.delete_outline, size: 16, color: Colors.red.shade400),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
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
}

class _EmptySearch extends StatelessWidget {
  final Color muted;
  const _EmptySearch({required this.muted});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔍', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 12),
            Text(
              'Recherche dans tous tes documents',
              style: TextStyle(fontSize: 14, color: muted),
            ),
            const SizedBox(height: 12),
            Text(
              'Cherche par matière, titre, type de document ou mot-clé.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: muted, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  final String query;
  final Color muted;
  final Color text;
  const _NoResults({required this.query, required this.muted, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_rounded, size: 52, color: muted.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text(
              'Aucun résultat pour "$query"',
              style: TextStyle(
                fontSize:   16,
                fontWeight: FontWeight.w700,
                color:      text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Essaie un autre mot-clé ou vérifie la matière concernée.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: muted, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
