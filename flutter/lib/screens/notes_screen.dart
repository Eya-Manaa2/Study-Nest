import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_provider.dart';
import '../widgets/sn_card.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  bool _showSheet = false;
  final _titleCtrl = TextEditingController();
  final _bodyCtrl  = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_titleCtrl.text.trim().isEmpty) return;
    ref.read(appProvider.notifier).addNote(
      _titleCtrl.text.trim(),
      _bodyCtrl.text.trim(),
    );
    _titleCtrl.clear();
    _bodyCtrl.clear();
    setState(() => _showSheet = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:  const Text('Note enregistrée !'),
        behavior: SnackBarBehavior.floating,
        shape:    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state    = ref.watch(appProvider);
    final t        = state.theme;
    final notifier = ref.read(appProvider.notifier);

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Main content ──────────────────────────────────────────────
            Column(
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
                  child: Row(
                    children: [
                      Text(
                        'Mes notes',
                        style: TextStyle(
                          fontSize:   22,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Fraunces',
                          color:      t.textColor,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setState(() => _showSheet = true),
                        child: Container(
                          width:  40,
                          height: 40,
                          decoration: BoxDecoration(
                            color:        t.accent,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color:      t.accent.withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset:     const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size:  22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: state.notes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('📝', style: TextStyle(fontSize: 52)),
                              const SizedBox(height: 12),
                              Text(
                                'Aucune note',
                                style: TextStyle(
                                  fontSize:   16,
                                  fontWeight: FontWeight.w700,
                                  color:      t.textColor,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Crée ta première note ici',
                                style: TextStyle(fontSize: 13, color: t.muted),
                              ),
                              const SizedBox(height: 18),
                              ElevatedButton.icon(
                                onPressed: () => setState(() => _showSheet = true),
                                icon: const Icon(Icons.add_rounded),
                                label: const Text('Créer une note'),
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
                        )
                      : ListView.separated(
                          padding:    const EdgeInsets.fromLTRB(20, 4, 20, 90),
                          itemCount:  state.notes.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (ctx, i) {
                            final note = state.notes[i];
                            return SnCard(
                              padding: const EdgeInsets.all(18),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Note personnelle',
                                          style: TextStyle(
                                            fontSize:      10.5,
                                            fontWeight:    FontWeight.w800,
                                            letterSpacing: 1.2,
                                            color:         t.accent,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          note.title,
                                          style: TextStyle(
                                            fontSize:   14.5,
                                            fontWeight: FontWeight.w700,
                                            color:      t.textColor,
                                          ),
                                        ),
                                        if (note.body.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Text(
                                            note.body,
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              color:    t.muted,
                                              height:   1.5,
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 10),
                                        Text(
                                          '${note.date.day}/${note.date.month}/${note.date.year}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color:    t.muted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      notifier.deleteNote(note.id);
                                      ScaffoldMessenger.of(ctx).showSnackBar(
                                        SnackBar(
                                          content:  const Text('Note supprimée'),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      );
                                    },
                                    icon: Icon(
                                      Icons.delete_outline_rounded,
                                      color: t.muted,
                                      size:  20,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),

            // ── Add note bottom sheet ──────────────────────────────────────
            if (_showSheet)
              GestureDetector(
                onTap: () => setState(() => _showSheet = false),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.82,
                        maxWidth: 560,
                      ),
                      child: GestureDetector(
                        onTap: () {},
                        child: SingleChildScrollView(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom > 0
                                ? MediaQuery.of(context).viewInsets.bottom
                                : 0,
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                            decoration: BoxDecoration(
                              color: t.surface,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(28),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Container(
                                    width:  40,
                                    height: 4,
                                    margin: const EdgeInsets.only(bottom: 20),
                                    decoration: BoxDecoration(
                                      color:        t.line,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                                Text(
                                  'Nouvelle note',
                                  style: TextStyle(
                                    fontSize:   17,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'Fraunces',
                                    color:      t.textColor,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: _titleCtrl,
                                  autofocus:  true,
                                  style:      TextStyle(color: t.textColor),
                                  decoration: const InputDecoration(
                                    hintText: 'Titre de la note',
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _bodyCtrl,
                                  maxLines:   4,
                                  style:      TextStyle(color: t.textColor),
                                  textInputAction: TextInputAction.done,
                                  decoration: const InputDecoration(
                                    hintText: 'Écris ta note ici…',
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: t.textColor,
                                          side: BorderSide(color: t.line),
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                        ),
                                        onPressed: () => setState(() => _showSheet = false),
                                        child: const Text(
                                          'Annuler',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize:   14.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: t.accent,
                                          foregroundColor: Colors.white,
                                          elevation:       0,
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                        ),
                                        onPressed: _handleSave,
                                        child: const Text(
                                          'Enregistrer',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize:   14.5,
                                          ),
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
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
