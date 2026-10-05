import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models.dart';

// ─── Firestore Service ─────────────────────────────────────────────────────────

class FirestoreService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  FirebaseAuth get _auth => FirebaseAuth.instance;

  // Obtenir l'ID de l'utilisateur courant
  String? get _userId => _auth.currentUser?.uid;

  // ─── Helpers de conversion ─────────────────────────────────────────────────────

  Color _colorFromMap(Map<String, dynamic>? map) {
    if (map == null) return const Color(0xFF6C63FF);
    final intValue = map['argb'] as int? ?? 0xFF6C63FF;
    return Color(intValue);
  }

  Map<String, dynamic> _colorToMap(Color color) {
    return {'argb': color.toARGB32()};
  }

  DocType _docTypeFromString(String type) {
    switch (type) {
      case 'cours': return DocType.cours;
      case 'td': return DocType.td;
      case 'tp': return DocType.tp;
      case 'examen': return DocType.examen;
      case 'resume': return DocType.resume;
      case 'photo': return DocType.photo;
      default: return DocType.cours;
    }
  }

  String _docTypeToString(DocType type) {
    switch (type) {
      case DocType.cours: return 'cours';
      case DocType.td: return 'td';
      case DocType.tp: return 'tp';
      case DocType.examen: return 'examen';
      case DocType.resume: return 'resume';
      case DocType.photo: return 'photo';
    }
  }

  FileFormat _fileFormatFromString(String format) {
    switch (format) {
      case 'pdf': return FileFormat.pdf;
      case 'docx': return FileFormat.docx;
      case 'pptx': return FileFormat.pptx;
      case 'xlsx': return FileFormat.xlsx;
      case 'jpg': return FileFormat.jpg;
      case 'png': return FileFormat.png;
      case 'mp4': return FileFormat.mp4;
      case 'mp3': return FileFormat.mp3;
      default: return FileFormat.other;
    }
  }

  String _fileFormatToString(FileFormat format) {
    switch (format) {
      case FileFormat.pdf: return 'pdf';
      case FileFormat.docx: return 'docx';
      case FileFormat.pptx: return 'pptx';
      case FileFormat.xlsx: return 'xlsx';
      case FileFormat.jpg: return 'jpg';
      case FileFormat.png: return 'png';
      case FileFormat.mp4: return 'mp4';
      case FileFormat.mp3: return 'mp3';
      case FileFormat.other: return 'other';
    }
  }

  // ─── Subjects ─────────────────────────────────────────────────────────────────

  // Stream de toutes les matières de l'utilisateur
  Stream<List<Subject>> getSubjects() {
    final firestore = _firestore;
    if (_userId == null) return Stream.value([]);
    
    return firestore
        .collection('users')
        .doc(_userId)
        .collection('subjects')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _subjectFromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Créer ou mettre à jour une matière
  Future<void> saveSubject(Subject subject) async {
    final firestore = _firestore;
    if (_userId == null) return;
    
    await firestore
        .collection('users')
        .doc(_userId)
        .collection('subjects')
        .doc(subject.id)
        .set(_subjectToFirestore(subject));
  }

  // Supprimer une matière
  Future<void> deleteSubject(String subjectId) async {
    final firestore = _firestore;
    if (_userId == null) return;
    
    // Supprimer d'abord tous les documents de la matière
    final docsSnapshot = await firestore
        .collection('users')
        .doc(_userId)
        .collection('subjects')
        .doc(subjectId)
        .collection('documents')
        .get();
    
    for (var doc in docsSnapshot.docs) {
      await doc.reference.delete();
    }
    
    // Supprimer la matière
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('subjects')
        .doc(subjectId)
        .delete();
  }

  // ─── Documents ───────────────────────────────────────────────────────────────

  // Stream de tous les documents d'une matière
  Stream<List<StudyDocument>> getDocuments(String subjectId) {
    final firestore = _firestore;
    if (_userId == null) return Stream.value([]);
    
    return firestore
        .collection('users')
        .doc(_userId)
        .collection('subjects')
        .doc(subjectId)
        .collection('documents')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _documentFromFirestore(doc.data(), doc.id, subjectId))
            .toList());
  }

  // Stream de tous les documents favoris
  Stream<List<StudyDocument>> getFavoriteDocuments() {
    final firestore = _firestore;
    if (_userId == null) return Stream.value([]);
    
    return firestore
        .collection('users')
        .doc(_userId)
        .collection('favorites')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _documentFromFirestore(doc.data(), doc.id, doc.data()['subjectId'] as String))
            .toList());
  }

  // Créer ou mettre à jour un document
  Future<void> saveDocument(StudyDocument document) async {
    final firestore = _firestore;
    if (_userId == null) return;
    
    final docRef = firestore
        .collection('users')
        .doc(_userId)
        .collection('subjects')
        .doc(document.subjectId)
        .collection('documents')
        .doc(document.id);
    
    await docRef.set(_documentToFirestore(document));
    
    // Si c'est un favori, l'ajouter à la collection favorites
    if (document.favorite) {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('favorites')
          .doc(document.id)
          .set(_documentToFirestore(document));
    } else {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('favorites')
          .doc(document.id)
          .delete();
    }
  }

  // Supprimer un document
  Future<void> deleteDocument(String subjectId, String documentId) async {
    final firestore = _firestore;
    if (_userId == null) return;
    
    // Supprimer de la collection documents
    await firestore
        .collection('users')
        .doc(_userId)
        .collection('subjects')
        .doc(subjectId)
        .collection('documents')
        .doc(documentId)
        .delete();
    
    // Supprimer de la collection favorites
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('favorites')
        .doc(documentId)
        .delete();
  }

  // Supprimer toutes les données de l'utilisateur
  Future<void> deleteAllUserData() async {
    if (_userId == null) throw Exception('Utilisateur non connecté');
    
    // Supprimer toutes les collections
    final collections = ['subjects', 'notes', 'todos', 'semesters', 'favorites'];
    
    for (final collection in collections) {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection(collection)
          .get();
      
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    }
  }

  // ─── Notes ───────────────────────────────────────────────────────────────────

  // Stream de toutes les notes de l'utilisateur
  Stream<List<Note>> getNotes() {
    if (_userId == null) return Stream.value([]);
    
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('notes')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _noteFromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Créer ou mettre à jour une note
  Future<void> saveNote(Note note) async {
    if (_userId == null) throw Exception('Utilisateur non connecté');
    
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('notes')
        .doc(note.id)
        .set(_noteToFirestore(note));
  }

  // Supprimer une note
  Future<void> deleteNote(String noteId) async {
    if (_userId == null) throw Exception('Utilisateur non connecté');
    
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('notes')
        .doc(noteId)
        .delete();
  }

  // ─── Todos ─────────────────────────────────────────────────────────────────────

  // Stream de toutes les todos de l'utilisateur
  Stream<List<Todo>> getTodos() {
    if (_userId == null) return Stream.value([]);
    
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('todos')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _todoFromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Créer ou mettre à jour une todo
  Future<void> saveTodo(Todo todo) async {
    if (_userId == null) throw Exception('Utilisateur non connecté');
    
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('todos')
        .doc(todo.id)
        .set(_todoToFirestore(todo));
  }

  // Supprimer une todo
  Future<void> deleteTodo(String todoId) async {
    if (_userId == null) throw Exception('Utilisateur non connecté');
    
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('todos')
        .doc(todoId)
        .delete();
  }

  // ─── Conversion methods ───────────────────────────────────────────────────────

  Subject _subjectFromFirestore(Map<String, dynamic> data, String id) {
    return Subject(
      id: id,
      name: data['name'] as String? ?? '',
      emoji: data['emoji'] as String? ?? '📚',
      color: _colorFromMap(data['color'] as Map<String, dynamic>?),
      semester: data['semester'] as int? ?? 1,
      grades: _gradesFromList(data['grades'] as List<dynamic>?),
    );
  }

  Map<String, dynamic> _subjectToFirestore(Subject subject) {
    return {
      'name': subject.name,
      'emoji': subject.emoji,
      'color': _colorToMap(subject.color),
      'semester': subject.semester,
      'grades': _gradesToList(subject.grades),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  StudyDocument _documentFromFirestore(Map<String, dynamic> data, String id, String subjectId) {
    return StudyDocument(
      id: id,
      subjectId: subjectId,
      title: data['title'] as String? ?? '',
      type: _docTypeFromString(data['type'] as String? ?? 'cours'),
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      favorite: data['favorite'] as bool? ?? false,
      filePath: data['filePath'] as String?,
      fileName: data['fileName'] as String?,
      fileFormat: data['fileFormat'] != null 
          ? _fileFormatFromString(data['fileFormat'] as String)
          : FileFormat.other,
    );
  }

  Map<String, dynamic> _documentToFirestore(StudyDocument document) {
    return {
      'title': document.title,
      'type': _docTypeToString(document.type),
      'date': Timestamp.fromDate(document.date),
      'favorite': document.favorite,
      'subjectId': document.subjectId,
      'filePath': document.filePath,
      'fileName': document.fileName,
      'fileFormat': _fileFormatToString(document.fileFormat),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Note _noteFromFirestore(Map<String, dynamic> data, String id) {
    return Note(
      id: id,
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> _noteToFirestore(Note note) {
    return {
      'title': note.title,
      'body': note.body,
      'date': Timestamp.fromDate(note.date),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  List<Grade> _gradesFromList(List<dynamic>? data) {
    if (data == null) return [];
    return data.map((g) => Grade(
      id: g['id'] as String? ?? '',
      value: (g['value'] as num?)?.toDouble() ?? 0.0,
      coefficient: (g['coefficient'] as num?)?.toDouble() ?? 1.0,
      label: g['label'] as String? ?? '',
      date: (g['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    )).toList();
  }

  List<Map<String, dynamic>> _gradesToList(List<Grade> grades) {
    return grades.map((g) => {
      'id': g.id,
      'value': g.value,
      'coefficient': g.coefficient,
      'label': g.label,
      'date': Timestamp.fromDate(g.date),
    }).toList();
  }

  Todo _todoFromFirestore(Map<String, dynamic> data, String id) {
    final reminderHour = data['reminderHour'] as int?;
    final reminderMinute = data['reminderMinute'] as int?;

    return Todo(
      id: id,
      title: data['title'] as String? ?? '',
      isCompleted: data['isCompleted'] as bool? ?? false,
      dueDate: (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      subjectId: data['subjectId'] as String?,
      priority: data['priority'] as int? ?? 1,
        reminderTime: reminderHour == null || reminderMinute == null
          ? null
          : TimeOfDay(hour: reminderHour, minute: reminderMinute),
    );
  }

  Map<String, dynamic> _todoToFirestore(Todo todo) {
    return {
      'title': todo.title,
      'isCompleted': todo.isCompleted,
      'dueDate': Timestamp.fromDate(todo.dueDate),
      'subjectId': todo.subjectId,
      'priority': todo.priority,
      'reminderHour': todo.reminderTime?.hour,
      'reminderMinute': todo.reminderTime?.minute,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // ─── Semester Methods ────────────────────────────────────────────────────────

  Stream<List<Semester>> getSemesters() {
    if (_userId == null) return Stream.value([]);
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('semesters')
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _semesterFromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<void> saveSemester(Semester semester) async {
    if (_userId == null) return;
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('semesters')
        .doc(semester.id)
        .set(_semesterToFirestore(semester));
  }

  Future<void> deleteSemester(String semesterId) async {
    if (_userId == null) return;
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('semesters')
        .doc(semesterId)
        .delete();
  }

  Semester _semesterFromFirestore(Map<String, dynamic> data, String id) {
    return Semester(
      id: id,
      name: data['name'] as String? ?? '',
      order: data['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> _semesterToFirestore(Semester semester) {
    return {
      'name': semester.name,
      'order': semester.order,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

// ─── Providers ─────────────────────────────────────────────────────────────────

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});
