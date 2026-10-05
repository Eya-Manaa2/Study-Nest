import 'package:flutter/material.dart';

// ─── Enums ────────────────────────────────────────────────────────────────────

enum DocType { cours, td, tp, examen, resume, photo }

enum FileFormat { pdf, docx, pptx, xlsx, jpg, png, mp4, mp3, other }

extension DocTypeExt on DocType {
  String get label {
    switch (this) {
      case DocType.cours:   return 'Cours';
      case DocType.td:      return 'TD';
      case DocType.tp:      return 'TP';
      case DocType.examen:  return 'Examen';
      case DocType.resume:  return 'Résumé';
      case DocType.photo:   return 'Photo';
    }
  }

  IconData get icon {
    switch (this) {
      case DocType.cours:   return Icons.menu_book_rounded;
      case DocType.td:      return Icons.edit_note_rounded;
      case DocType.tp:      return Icons.science_rounded;
      case DocType.examen:  return Icons.quiz_rounded;
      case DocType.resume:  return Icons.description_rounded;
      case DocType.photo:   return Icons.photo_library_rounded;
    }
  }
}

extension FileFormatExt on FileFormat {
  String get label {
    switch (this) {
      case FileFormat.pdf:   return 'PDF';
      case FileFormat.docx:  return 'Word';
      case FileFormat.pptx:  return 'PowerPoint';
      case FileFormat.xlsx:  return 'Excel';
      case FileFormat.jpg:   return 'Image JPG';
      case FileFormat.png:   return 'Image PNG';
      case FileFormat.mp4:   return 'Vidéo MP4';
      case FileFormat.mp3:   return 'Audio MP3';
      case FileFormat.other: return 'Autre';
    }
  }

  String get extension {
    switch (this) {
      case FileFormat.pdf:   return '.pdf';
      case FileFormat.docx:  return '.docx';
      case FileFormat.pptx:  return '.pptx';
      case FileFormat.xlsx:  return '.xlsx';
      case FileFormat.jpg:   return '.jpg';
      case FileFormat.png:   return '.png';
      case FileFormat.mp4:   return '.mp4';
      case FileFormat.mp3:   return '.mp3';
      case FileFormat.other: return '';
    }
  }

  IconData get icon {
    switch (this) {
      case FileFormat.pdf:   return Icons.picture_as_pdf;
      case FileFormat.docx:  return Icons.description;
      case FileFormat.pptx:  return Icons.slideshow;
      case FileFormat.xlsx:  return Icons.table_chart;
      case FileFormat.jpg:   return Icons.image;
      case FileFormat.png:   return Icons.image;
      case FileFormat.mp4:   return Icons.videocam;
      case FileFormat.mp3:   return Icons.audiotrack;
      case FileFormat.other: return Icons.insert_drive_file;
    }
  }

  Color get color {
    switch (this) {
      case FileFormat.pdf:   return const Color(0xFFE74C3C);
      case FileFormat.docx:  return const Color(0xFF3498DB);
      case FileFormat.pptx:  return const Color(0xFFE67E22);
      case FileFormat.xlsx:  return const Color(0xFF27AE60);
      case FileFormat.jpg:   return const Color(0xFF9B59B6);
      case FileFormat.png:   return const Color(0xFF9B59B6);
      case FileFormat.mp4:   return const Color(0xFFE91E63);
      case FileFormat.mp3:   return const Color(0xFF00BCD4);
      case FileFormat.other:  return const Color(0xFF95A5A6);
    }
  }
}

// ─── Models ───────────────────────────────────────────────────────────────────

class Semester {
  final String id;
  final String name;
  final int order;

  const Semester({
    required this.id,
    required this.name,
    this.order = 0,
  });

  Semester copyWith({
    String? id,
    String? name,
    int? order,
  }) {
    return Semester(
      id: id ?? this.id,
      name: name ?? this.name,
      order: order ?? this.order,
    );
  }
}

class StudyDocument {
  final String id;
  final String subjectId;
  final String title;
  final DocType type;
  final DateTime date;
  final bool favorite;
  final String? filePath; // Chemin local du fichier
  final String? fileName; // Nom du fichier original
  final FileFormat fileFormat; // Format du fichier (PDF, Word, etc.)

  const StudyDocument({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.type,
    required this.date,
    this.favorite = false,
    this.filePath,
    this.fileName,
    this.fileFormat = FileFormat.other,
  });

  StudyDocument copyWith({
    String? id,
    String? subjectId,
    String? title,
    DocType? type,
    DateTime? date,
    bool? favorite,
    String? filePath,
    String? fileName,
    FileFormat? fileFormat,
  }) {
    return StudyDocument(
      id:        id        ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      title:     title     ?? this.title,
      type:      type      ?? this.type,
      date:      date      ?? this.date,
      favorite:  favorite  ?? this.favorite,
      filePath:  filePath  ?? this.filePath,
      fileName:  fileName  ?? this.fileName,
      fileFormat: fileFormat ?? this.fileFormat,
    );
  }
}

class Subject {
  final String id;
  final String name;
  final String emoji;
  final Color color;
  final int semester;
  final List<StudyDocument> docs;
  final List<Grade> grades;

  const Subject({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    this.semester = 1,
    this.docs = const [],
    this.grades = const [],
  });

  Subject copyWith({
    String? id,
    String? name,
    String? emoji,
    Color? color,
    int? semester,
    List<StudyDocument>? docs,
    List<Grade>? grades,
  }) {
    return Subject(
      id:       id       ?? this.id,
      name:     name     ?? this.name,
      emoji:    emoji    ?? this.emoji,
      color:    color    ?? this.color,
      semester: semester ?? this.semester,
      docs:     docs     ?? this.docs,
      grades:   grades   ?? this.grades,
    );
  }

  int get docCount => docs.length;
  int get favCount => docs.where((d) => d.favorite).length;
  double get progress => docs.isEmpty ? 0 : (docs.length * 0.12).clamp(0.0, 1.0);
  double get average => grades.isEmpty ? 0 : grades.map((g) => g.value * g.coefficient).reduce((a, b) => a + b) / grades.map((g) => g.coefficient).reduce((a, b) => a + b);
}

class Grade {
  final String id;
  final double value;
  final double coefficient;
  final String label;
  final DateTime date;

  const Grade({
    required this.id,
    required this.value,
    required this.coefficient,
    required this.label,
    required this.date,
  });

  Grade copyWith({
    String? id,
    double? value,
    double? coefficient,
    String? label,
    DateTime? date,
  }) {
    return Grade(
      id: id ?? this.id,
      value: value ?? this.value,
      coefficient: coefficient ?? this.coefficient,
      label: label ?? this.label,
      date: date ?? this.date,
    );
  }
}

class Todo {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime dueDate;
  final String? subjectId;
  final int priority; // 0: faible, 1: moyenne, 2: haute, 3: urgente
  final TimeOfDay? reminderTime; // Exact time for notification

  const Todo({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.dueDate,
    this.subjectId,
    this.priority = 1,
    this.reminderTime,
  });

  Todo copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? dueDate,
    String? subjectId,
    int? priority,
    TimeOfDay? reminderTime,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      subjectId: subjectId ?? this.subjectId,
      priority: priority ?? this.priority,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}

class Note {
  final String id;
  final String title;
  final String body;
  final DateTime date;

  const Note({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
  });
}

class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation = '',
  });

  QuizQuestion copyWith({
    String? id,
    String? question,
    List<String>? options,
    int? correctIndex,
    String? explanation,
  }) {
    return QuizQuestion(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
      correctIndex: correctIndex ?? this.correctIndex,
      explanation: explanation ?? this.explanation,
    );
  }
}

class Quiz {
  final String id;
  final String title;
  final String subject;
  final List<QuizQuestion> questions;
  final DateTime createdAt;

  const Quiz({
    required this.id,
    required this.title,
    required this.subject,
    required this.questions,
    required this.createdAt,
  });

  Quiz copyWith({
    String? id,
    String? title,
    String? subject,
    List<QuizQuestion>? questions,
    DateTime? createdAt,
  }) {
    return Quiz(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      questions: questions ?? this.questions,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// ─── Enriched doc (with subject info) ────────────────────────────────────────

class RichDocument {
  final StudyDocument doc;
  final String subjectName;
  final String subjectEmoji;
  final Color subjectColor;

  const RichDocument({
    required this.doc,
    required this.subjectName,
    required this.subjectEmoji,
    required this.subjectColor,
  });

  String get id          => doc.id;
  String get title       => doc.title;
  DocType get type       => doc.type;
  DateTime get date      => doc.date;
  bool get favorite      => doc.favorite;
  String get subjectId   => doc.subjectId;
}

// ─── Theme model ─────────────────────────────────────────────────────────────

class AppThemeDef {
  final String id;
  final String label;
  final String emoji;
  final Color bg;
  final Color surface;
  final Color surface2;
  final Color accent;
  final Color accent2;
  final Color textColor;
  final Color muted;
  final Color line;
  final bool isDark;

  const AppThemeDef({
    required this.id,
    required this.label,
    required this.emoji,
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.accent,
    required this.accent2,
    required this.textColor,
    required this.muted,
    required this.line,
    this.isDark = false,
  });
}
