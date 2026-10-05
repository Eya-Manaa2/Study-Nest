import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_provider.dart';
import '../models.dart';
import '../widgets/sn_card.dart';

const _subjectColors = [
  Color(0xFF7C2333), Color(0xFF1C8CA3), Color(0xFF4C7A3B), Color(0xFF1857A4),
  Color(0xFF8B6CF0), Color(0xFFE8637F), Color(0xFF8A5A2B), Color(0xFFE0A106),
];

class SubjectsScreen extends ConsumerStatefulWidget {
  final void Function(String subjectId) onOpenSubject;

  const SubjectsScreen({super.key, required this.onOpenSubject});

  @override
  ConsumerState<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends ConsumerState<SubjectsScreen> {
  bool _showSheet = false;
  String? _selectedSemesterId;

  final _nameCtrl  = TextEditingController();
  String _emoji    = '📖';
  Color  _color    = _subjectColors[0];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _handleAdd(String? semesterId) {
    if (_nameCtrl.text.trim().isEmpty) return;
    final state = ref.read(appProvider);
    
    // S'il n'y a pas de semesters, utiliser le semestre par défaut (ordre 1)
    int semesterOrder = 1;
    if (semesterId != null && state.semesters.isNotEmpty) {
      try {
        final semester = state.semesters.firstWhere((s) => s.id == semesterId);
        semesterOrder = semester.order + 1;
      } catch (e) {
        semesterOrder = 1;
      }
    }
    
    ref.read(appProvider.notifier).addSubject(
      _nameCtrl.text.trim(), _emoji, _color, semesterOrder,
    );
    _nameCtrl.clear();
    setState(() { _showSheet = false; });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Matière ajoutée !'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProvider);
    final t     = state.theme;
    
    // Get selected semester
    final selectedSemester = _selectedSemesterId != null
        ? state.semesters.firstWhere((s) => s.id == _selectedSemesterId, orElse: () => state.semesters.first)
        : (state.semesters.isNotEmpty ? state.semesters.first : null);
    
    // Filter subjects by semester
    final filteredSubjects = selectedSemester != null
        ? state.subjects.where((s) => s.semester == selectedSemester.order + 1).toList()
        : state.subjects;

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                // ── App bar ──────────────────────────────────────────────────
                SliverAppBar(
                  pinned:              true,
                  backgroundColor:     t.bg,
                  surfaceTintColor:    Colors.transparent,
                  title: Text(
                    'Mes matières',
                    style: TextStyle(
                      fontFamily: 'Fraunces',
                      fontWeight: FontWeight.w800,
                      fontSize:   22,
                      color:      t.textColor,
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: GestureDetector(
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
                    ),
                  ],
                ),

                // ── Semester chips ───────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...state.semesters.map((sem) => SnChip(
                            label: sem.name,
                            active: _selectedSemesterId == sem.id,
                            onTap: () => setState(() => _selectedSemesterId = sem.id),
                          )),
                        GestureDetector(
                          onTap: () => _showAddSemesterDialog(context, ref),
                          child: const SnChip(label: '+'),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Subjects grid ────────────────────────────────────────────
                if (filteredSubjects.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: t.surface,
                          border: Border.all(color: t.line),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Aucune matière pour ce semestre',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Fraunces',
                                color: t.textColor,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Commence par ajouter une matière pour organiser ton semestre.',
                              style: TextStyle(fontSize: 13, color: t.muted, height: 1.5),
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => setState(() => _showSheet = true),
                                icon: const Icon(Icons.add_rounded),
                                label: const Text('Ajouter une matière'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: t.accent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:   2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing:  12,
                        childAspectRatio: 0.82,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) {
                          if (i == filteredSubjects.length) return _AddSubjectCard(onTap: () => setState(() => _showSheet = true));
                          final s = filteredSubjects[i];
                          return _SubjectCard(
                            subject:     s,
                            onTap:       () => widget.onOpenSubject(s.id),
                            onEdit:      () => _showEditSubjectDialog(context, ref, s),
                          );
                        },
                        childCount: filteredSubjects.length + 1,
                      ),
                    ),
                  ),
              ],
            ),

            // ── Bottom sheet overlay ─────────────────────────────────────────
            if (_showSheet)
              _AddSubjectSheet(
                nameCtrl:  _nameCtrl,
                emoji:     _emoji,
                color:     _color,
                onEmojiChanged: (e) => setState(() => _emoji = e),
                onColorChanged: (c) => setState(() => _color = c),
                onCancel:  () => setState(() => _showSheet = false),
                onAdd:     () => _handleAdd(_selectedSemesterId),
              ),
          ],
        ),
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

  void _showEditSubjectDialog(BuildContext context, WidgetRef ref, Subject subject) {
    final nameController = TextEditingController(text: subject.name);
    Color selectedColor = subject.color;
    String selectedEmoji = subject.emoji;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier la matière'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la matière',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Emoji: '),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: selectedEmoji,
                    items: const ['📖', '⚡', '💻', '📡', '🔬', '🌍', '🎨', '⚗️'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (e) => selectedEmoji = e ?? selectedEmoji,
                  ),
                ],
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
            onPressed: () {
              if (nameController.text.trim().isEmpty) return;
              final updatedSubject = subject.copyWith(
                name: nameController.text.trim(),
                color: selectedColor,
                emoji: selectedEmoji,
              );
              ref.read(appProvider.notifier).updateSubject(updatedSubject);
              Navigator.pop(context);
            },
            child: const Text('Modifier'),
          ),
        ],
      ),
    );
  }
}

// ─── Subject card ─────────────────────────────────────────────────────────────

class _SubjectCard extends ConsumerWidget {
  final Subject subject;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const _SubjectCard({required this.subject, required this.onTap, required this.onEdit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appProvider).theme;
    final progress = subject.progress;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:    const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:        t.surface,
          borderRadius: BorderRadius.circular(20),
          border:       Border.all(color: t.line),
          boxShadow: [
            BoxShadow(
              color:      subject.color.withValues(alpha: 0.12),
              blurRadius: 14,
              offset:     const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Color wash
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color:        subject.color.withValues(alpha: 0.07),
                ),
              ),
            ),
            // Accent corner
            Positioned(
              top:   0,
              right: 0,
              child: Container(
                width:  52,
                height: 52,
                decoration: BoxDecoration(
                  color: subject.color.withValues(alpha: 0.18),
                  borderRadius: const BorderRadius.only(
                    topRight:    Radius.circular(20),
                    bottomLeft:  Radius.circular(40),
                  ),
                ),
              ),
            ),
            // Action buttons
            Positioned(
              top:    8,
              right:  8,
              child: Row(
                children: [
                  // Edit button
                  GestureDetector(
                    onTap: onEdit,
                    child: Container(
                      width:  28,
                      height: 28,
                      decoration: BoxDecoration(
                        color:        t.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.edit,
                        size:  16,
                        color: t.accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Delete button
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Supprimer la matière'),
                          content: Text('Voulez-vous vraiment supprimer "${subject.name}" ?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Annuler'),
                            ),
                            TextButton(
                              onPressed: () {
                                ref.read(appProvider.notifier).deleteSubject(subject.id);
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Matière supprimée'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Container(
                      width:  28,
                      height: 28,
                      decoration: BoxDecoration(
                        color:        t.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.close,
                        size:  18,
                        color: t.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width:  42,
                  height: 42,
                  decoration: BoxDecoration(
                    color:        t.surface,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color:      Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    subject.emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const Spacer(),
                Text(
                  subject.name,
                  maxLines:  2,
                  overflow:  TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize:   14.5,
                    color:      t.textColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${subject.docCount} document${subject.docCount != 1 ? 's' : ''}',
                  style: TextStyle(fontSize: 11, color: t.muted),
                ),
                const SizedBox(height: 10),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value:            progress,
                    backgroundColor:  t.surface2,
                    color:            subject.color,
                    minHeight:        5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(progress * 100).toInt()}% rempli',
                  style: TextStyle(fontSize: 10, color: t.muted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddSubjectCard extends StatelessWidget {
  final VoidCallback onTap;
  const _AddSubjectCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:  t.outline.withValues(alpha: 0.4),
            width:  2,
            style:  BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width:  42,
              height: 42,
              decoration: BoxDecoration(
                color:  t.surfaceContainerHighest,
                shape:  BoxShape.circle,
              ),
              child: Icon(Icons.add_rounded, color: t.onSurface.withValues(alpha: 0.4)),
            ),
            const SizedBox(height: 8),
            Text(
              'Nouvelle matière',
              style: TextStyle(
                fontSize:   13,
                fontWeight: FontWeight.w700,
                color:      t.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Add subject bottom sheet ─────────────────────────────────────────────────

class _AddSubjectSheet extends ConsumerWidget {
  final TextEditingController nameCtrl;
  final String emoji;
  final Color color;
  final void Function(String) onEmojiChanged;
  final void Function(Color) onColorChanged;
  final VoidCallback onCancel;
  final VoidCallback onAdd;

  const _AddSubjectSheet({
    required this.nameCtrl,
    required this.emoji,
    required this.color,
    required this.onEmojiChanged,
    required this.onColorChanged,
    required this.onCancel,
    required this.onAdd,
  });

  static const _emojis = ['📖', '⚡', '💻', '📡', '🔬', '🌍', '🎨', '⚗️'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appProvider).theme;

    return GestureDetector(
      onTap: onCancel,
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.82,
              maxWidth: 560,
            ),
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
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: t.line,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const Text(
                      'Nouvelle matière',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Fraunces',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameCtrl,
                      autofocus: true,
                      style: TextStyle(color: t.textColor),
                      decoration: const InputDecoration(
                        hintText: 'Nom de la matière',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'EMOJI',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: t.muted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _emojis.map((e) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => onEmojiChanged(e),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: emoji == e ? t.surface2 : t.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: emoji == e ? t.accent : t.line,
                                  width: emoji == e ? 2 : 1,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(e, style: const TextStyle(fontSize: 20)),
                            ),
                          ),
                        )).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'COULEUR',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: t.muted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _subjectColors.map((c) => Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: GestureDetector(
                            onTap: () => onColorChanged(c),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: color == c ? t.textColor : Colors.transparent,
                                  width: 2.5,
                                ),
                              ),
                            ),
                          ),
                        )).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
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
                            onPressed: onCancel,
                            child: const Text(
                              'Annuler',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14.5,
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
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: onAdd,
                            child: const Text(
                              'Ajouter',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14.5,
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
    );
  }
}
