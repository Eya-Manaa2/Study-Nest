import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models.dart';
import 'themes.dart';
import 'services/firestore_service.dart';
import 'services/notification_service.dart';

// ─── App State ────────────────────────────────────────────────────────────────

class AppState {
  final List<Subject> subjects;
  final List<Note> notes;
  final List<Todo> todos;
  final List<Semester> semesters;
  final String activeThemeId;
  final String? activeSubjectId;
  final DocType? activeDocType; // null = Tous
  final String searchQuery;

  const AppState({
    required this.subjects,
    required this.notes,
    required this.todos,
    this.semesters = const [],
    this.activeThemeId = 'clair',
    this.activeSubjectId,
    this.activeDocType,
    this.searchQuery = '',
  });

  AppState copyWith({
    List<Subject>? subjects,
    List<Note>? notes,
    List<Todo>? todos,
    List<Semester>? semesters,
    String? activeThemeId,
    String? activeSubjectId,
    Object? activeDocType = _sentinel, // allows null
    String? searchQuery,
  }) {
    return AppState(
      subjects:        subjects        ?? this.subjects,
      notes:           notes           ?? this.notes,
      todos:           todos           ?? this.todos,
      semesters:       semesters       ?? this.semesters,
      activeThemeId:   activeThemeId   ?? this.activeThemeId,
      activeSubjectId: activeSubjectId ?? this.activeSubjectId,
      activeDocType:   activeDocType == _sentinel
          ? this.activeDocType
          : activeDocType as DocType?,
      searchQuery:     searchQuery     ?? this.searchQuery,
    );
  }

  // ── Derived helpers ─────────────────────────────────────────────────────────

  Subject? get activeSubject =>
      activeSubjectId == null
          ? null
          : subjects.firstWhere((s) => s.id == activeSubjectId,
              orElse: () => subjects.first);

  AppThemeDef get theme => appThemes.firstWhere((t) => t.id == activeThemeId);

  List<RichDocument> get allDocs => subjects.expand((s) => s.docs.map((d) =>
      RichDocument(
        doc: d,
        subjectName: s.name,
        subjectEmoji: s.emoji,
        subjectColor: s.color,
      ))).toList();

  List<RichDocument> get recentDocs {
    final sorted = [...allDocs]
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(4).toList();
  }

  List<RichDocument> get favDocs =>
      allDocs.where((d) => d.favorite).toList();

  List<RichDocument> searchDocs(String query) {
    if (query.trim().isEmpty) return [];
    final q = query.toLowerCase();
    return allDocs.where((d) =>
        d.title.toLowerCase().contains(q) ||
        d.subjectName.toLowerCase().contains(q) ||
        d.type.label.toLowerCase().contains(q)).toList();
  }
}

// Sentinel for nullable copyWith
const _sentinel = Object();

// ─── Notifier ────────────────────────────────────────────────────────────────

class AppNotifier extends StateNotifier<AppState> {
  final FirestoreService _firestoreService;
  final NotificationService _notificationService;
  
  AppNotifier(this._firestoreService)
      : _notificationService = NotificationService(),
        super(const AppState(subjects: [], notes: [], todos: [], semesters: [])) {
    _loadDataFromFirestore();
    _notificationService.initialize();
  }

  void _loadDataFromFirestore() {
    // Charger les matières depuis Firestore
    _firestoreService.getSubjects().listen((subjects) {
      if (mounted) {
        state = state.copyWith(subjects: subjects);
        // Charger les documents pour chaque matière
        for (var subject in subjects) {
          _firestoreService.getDocuments(subject.id).listen((docs) {
            if (mounted) {
              _updateSubjectDocs(subject.id, docs);
            }
          });
        }
      }
    });

    // Charger les notes depuis Firestore
    _firestoreService.getNotes().listen((notes) {
      if (mounted) {
        state = state.copyWith(notes: notes);
      }
    });

    // Charger les semesters depuis Firestore
    _firestoreService.getSemesters().listen((semesters) {
      if (mounted) {
        state = state.copyWith(semesters: semesters);
      }
    });

    // Charger les todos depuis Firestore
    _firestoreService.getTodos().listen((todos) {
      if (mounted) {
        state = state.copyWith(todos: todos);
      }
    });
  }

  void _updateSubjectDocs(String subjectId, List<StudyDocument> docs) {
    final updatedSubjects = state.subjects.map((s) {
      if (s.id == subjectId) {
        return s.copyWith(docs: docs);
      }
      return s;
    }).toList();
    state = state.copyWith(subjects: updatedSubjects);
  }

  void setTheme(String id) => state = state.copyWith(activeThemeId: id);

  void openSubject(String id) =>
      state = state.copyWith(activeSubjectId: id, activeDocType: _sentinel);

  void setActiveDocType(DocType? type) =>
      state = state.copyWith(activeDocType: type);

  void toggleFavorite(String docId) {
    // Trouver le document et le mettre à jour localement
    final updatedSubjects = state.subjects.map((s) {
      final updatedDocs = s.docs.map((d) {
        if (d.id == docId) {
          final updatedDoc = d.copyWith(favorite: !d.favorite);
          // Synchroniser avec Firestore
          _firestoreService.saveDocument(updatedDoc);
          return updatedDoc;
        }
        return d;
      }).toList();
      return s.copyWith(docs: updatedDocs);
    }).toList();

    state = state.copyWith(subjects: updatedSubjects);
  }

  void addNote(String title, String body) {
    final note = Note(
      id: 'n${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      date: DateTime.now(),
    );
    // Synchroniser avec Firestore
    _firestoreService.saveNote(note);
    state = state.copyWith(notes: [note, ...state.notes]);
  }

  void deleteNote(String id) {
    // Synchroniser avec Firestore
    _firestoreService.deleteNote(id);
    state = state.copyWith(notes: state.notes.where((n) => n.id != id).toList());
  }

  void setSearchQuery(String q) => state = state.copyWith(searchQuery: q);

  void addSubject(String name, String emoji, Color color, [int semester = 1]) {
    final s = Subject(
      id: 's${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      emoji: emoji,
      color: color,
      semester: semester,
    );
    _firestoreService.saveSubject(s);
    state = state.copyWith(subjects: [...state.subjects, s]);
  }

  void deleteSubject(String subjectId) {
    _firestoreService.deleteSubject(subjectId);
    state = state.copyWith(
      subjects: state.subjects.where((s) => s.id != subjectId).toList(),
    );
  }

  void updateSubject(Subject updatedSubject) {
    _firestoreService.saveSubject(updatedSubject);
    state = state.copyWith(
      subjects: state.subjects.map((s) => s.id == updatedSubject.id ? updatedSubject : s).toList(),
    );
  }

  void addGrade(String subjectId, double value, double coefficient, String label) {
    final grade = Grade(
      id: 'g${DateTime.now().millisecondsSinceEpoch}',
      value: value,
      coefficient: coefficient,
      label: label,
      date: DateTime.now(),
    );
    
    final updatedSubjects = state.subjects.map((s) {
      if (s.id == subjectId) {
        final updatedSubject = s.copyWith(grades: [...s.grades, grade]);
        _firestoreService.saveSubject(updatedSubject);
        return updatedSubject;
      }
      return s;
    }).toList();
    
    state = state.copyWith(subjects: updatedSubjects);
  }

  void deleteGrade(String subjectId, String gradeId) {
    final updatedSubjects = state.subjects.map((s) {
      if (s.id == subjectId) {
        final updatedSubject = s.copyWith(grades: s.grades.where((g) => g.id != gradeId).toList());
        _firestoreService.saveSubject(updatedSubject);
        return updatedSubject;
      }
      return s;
    }).toList();
    
    state = state.copyWith(subjects: updatedSubjects);
  }

  Future<void> addTodo(String title, DateTime dueDate, String? subjectId, int priority, {TimeOfDay? reminderTime}) async {
    final todo = Todo(
      id: 't${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      dueDate: dueDate,
      subjectId: subjectId,
      priority: priority,
      reminderTime: reminderTime,
    );
    await _firestoreService.saveTodo(todo);
    state = state.copyWith(todos: [todo, ...state.todos]);

    // Programmer une notification à l'heure exacte spécifiée
    if (reminderTime != null) {
      final scheduledDateTime = DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
        reminderTime.hour,
        reminderTime.minute,
      );
      
      if (scheduledDateTime.isAfter(DateTime.now())) {
        await _notificationService.scheduleNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: 'Rappel de tâche',
          body: 'Rappel: $title',
          scheduledDate: scheduledDateTime,
        );
      }
    } else {
      // Fallback: notification 1 heure avant la deadline si pas d'heure spécifiée
      final notificationTime = dueDate.subtract(const Duration(hours: 1));
      if (notificationTime.isAfter(DateTime.now())) {
        await _notificationService.scheduleNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: 'Rappel de tâche',
          body: 'La tâche "$title" est due dans 1 heure !',
          scheduledDate: notificationTime,
        );
      }
    }
  }

  void toggleTodo(String todoId) {
    final updatedTodos = state.todos.map((t) {
      if (t.id == todoId) {
        final updatedTodo = t.copyWith(isCompleted: !t.isCompleted);
        _firestoreService.saveTodo(updatedTodo);
        return updatedTodo;
      }
      return t;
    }).toList();
    
    state = state.copyWith(todos: updatedTodos);
  }

  void deleteTodo(String todoId) {
    _firestoreService.deleteTodo(todoId);
    state = state.copyWith(todos: state.todos.where((t) => t.id != todoId).toList());
    
    // Annuler la notification (en utilisant l'ID de la tâche)
    _notificationService.cancelNotification(int.parse(todoId.substring(1)) ~/ 1000);
  }

  // Semester management
  void addSemester(String name) {
    final semester = Semester(
      id: 'sem${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      order: state.semesters.length,
    );
    _firestoreService.saveSemester(semester);
    state = state.copyWith(semesters: [...state.semesters, semester]);
  }

  void updateSemester(Semester semester) {
    _firestoreService.saveSemester(semester);
    state = state.copyWith(
      semesters: state.semesters.map((s) => s.id == semester.id ? semester : s).toList(),
    );
  }

  void deleteSemester(String semesterId) {
    _firestoreService.deleteSemester(semesterId);
    state = state.copyWith(semesters: state.semesters.where((s) => s.id != semesterId).toList());
  }
}

// ─── Providers ───────────────────────────────────────────────────────────────

final appProvider = StateNotifierProvider<AppNotifier, AppState>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return AppNotifier(firestoreService);
});
