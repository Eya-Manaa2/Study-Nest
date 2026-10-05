import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_provider.dart';
import 'home_screen.dart';
import 'subjects_screen.dart';
import 'search_screen.dart';
import 'assistant_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'subject_detail_screen.dart';
import 'notes_screen.dart';

class MainScaffold extends ConsumerStatefulWidget {
  final VoidCallback onLogout;
  const MainScaffold({super.key, required this.onLogout});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  int _tabIndex = 0;

  // Subject detail overlay
  String? _detailSubjectId;

  // Notes overlay (shown from profile)
  bool _showNotes = false;

  void _openSubject(String id) {
    ref.read(appProvider.notifier).openSubject(id);
    setState(() {
      _detailSubjectId = id;
      _tabIndex = 1; // subjects tab
    });
  }

  void _closeDetail() => setState(() => _detailSubjectId = null);

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(appProvider).theme;

    // Subject detail takes over full screen
    if (_detailSubjectId != null) {
      return SubjectDetailScreen(
        subjectId: _detailSubjectId!,
        onBack:    _closeDetail,
      );
    }

    // Notes screen overlay (from profile)
    if (_showNotes) {
      return Scaffold(
        backgroundColor: t.bg,
        body: Column(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: t.textColor,
                        size:  20,
                      ),
                      onPressed: () => setState(() => _showNotes = false),
                    ),
                  ],
                ),
              ),
            ),
            const Expanded(child: NotesScreen()),
          ],
        ),
      );
    }

    final tabs = [
      HomeScreen(
        onOpenSubject: _openSubject,
        onGoToSearch:  () => setState(() => _tabIndex = 2),
      ),
      SubjectsScreen(onOpenSubject: _openSubject),
      SearchScreen(onOpenSubject: _openSubject),
      const AssistantScreen(),
      FavoritesScreen(onOpenSubject: _openSubject),
      ProfileScreen(
        onLogout:    widget.onLogout,
        onGoToNotes: () => setState(() => _showNotes = true),
      ),
    ];

    return Scaffold(
      backgroundColor: t.bg,
      body: IndexedStack(
        index: _tabIndex,
        children: tabs,
      ),
      bottomNavigationBar: _StudyNestNavBar(
        currentIndex: _tabIndex,
        onTap:        (i) => setState(() => _tabIndex = i),
      ),
    );
  }
}

// ─── Custom bottom nav bar ─────────────────────────────────────────────────────

class _StudyNestNavBar extends ConsumerWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const _StudyNestNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    _NavItem(icon: Icons.home_outlined,             activeIcon: Icons.home_rounded,            label: 'Accueil'),
    _NavItem(icon: Icons.menu_book_outlined,        activeIcon: Icons.menu_book_rounded,       label: 'Matières'),
    _NavItem(icon: Icons.search_outlined,           activeIcon: Icons.search_rounded,          label: 'Recherche'),
    _NavItem(icon: Icons.psychology_alt_outlined,   activeIcon: Icons.psychology_alt_rounded,  label: 'Assistant'),
    _NavItem(icon: Icons.favorite_outline,          activeIcon: Icons.favorite_rounded,        label: 'Favoris'),
    _NavItem(icon: Icons.person_outline,            activeIcon: Icons.person_rounded,          label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appProvider).theme;

    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(top: BorderSide(color: t.line, width: 1)),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(0.07),
            blurRadius: 16,
            offset:     const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: _items.asMap().entries.map((entry) {
              final i       = entry.key;
              final item    = entry.value;
              final isActive = i == currentIndex;

              return Expanded(
                child: GestureDetector(
                  onTap:      () => onTap(i),
                  behavior:   HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical:   5,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? t.accent.withOpacity(0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Icon(
                            isActive ? item.activeIcon : item.icon,
                            color: isActive ? t.accent : t.muted,
                            size:  24,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize:   10,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                            color:      isActive ? t.accent : t.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String   label;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
