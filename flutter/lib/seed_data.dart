import 'package:flutter/material.dart';
import 'models.dart';

final List<Subject> seedSubjects = [
  Subject(
    id: 's1',
    name: 'Mathématiques',
    emoji: '∑',
    color: const Color(0xFF7C2333),
    semester: 1,
    docs: [
      StudyDocument(
        id: 'd1', subjectId: 's1',
        title: 'Cours — Algèbre linéaire',
        type: DocType.cours,
        date: DateTime(2026, 7, 28),
        favorite: true,
        filePath: null,
        fileName: 'algebre_lineaire.pdf',
        fileFormat: FileFormat.pdf,
      ),
      StudyDocument(
        id: 'd2', subjectId: 's1',
        title: 'TD n°3 — Matrices',
        type: DocType.td,
        date: DateTime(2026, 7, 25),
        filePath: null,
        fileName: 'td_matrices.docx',
        fileFormat: FileFormat.docx,
      ),
      StudyDocument(
        id: 'd3', subjectId: 's1',
        title: 'Examen blanc S1',
        type: DocType.examen,
        date: DateTime(2026, 7, 20),
        favorite: true,
        filePath: null,
        fileName: 'examen_blanc.pdf',
        fileFormat: FileFormat.pdf,
      ),
    ],
    grades: [
      Grade(
        id: 'g1',
        value: 15.5,
        coefficient: 2.0,
        label: 'DS1',
        date: DateTime(2026, 7, 15),
      ),
      Grade(
        id: 'g2',
        value: 18.0,
        coefficient: 1.5,
        label: 'TD1',
        date: DateTime(2026, 7, 20),
      ),
    ],
  ),
  Subject(
    id: 's2',
    name: 'Physique',
    emoji: '⚡',
    color: const Color(0xFF1C8CA3),
    semester: 1,
    docs: [
      StudyDocument(
        id: 'd4', subjectId: 's2',
        title: 'Cours — Électromagnétisme',
        type: DocType.cours,
        date: DateTime(2026, 7, 29),
        filePath: null,
        fileName: 'electromagnetisme.pdf',
        fileFormat: FileFormat.pdf,
      ),
      StudyDocument(
        id: 'd5', subjectId: 's2',
        title: 'TP — Oscilloscope',
        type: DocType.tp,
        date: DateTime(2026, 7, 22),
        favorite: true,
        filePath: null,
        fileName: 'tp_oscilloscope.pptx',
        fileFormat: FileFormat.pptx,
      ),
    ],
    grades: [
      Grade(
        id: 'g3',
        value: 14.0,
        coefficient: 2.0,
        label: 'DS1',
        date: DateTime(2026, 7, 18),
      ),
    ],
  ),
  Subject(
    id: 's3',
    name: 'Informatique',
    emoji: '💻',
    color: const Color(0xFF4C7A3B),
    semester: 1,
    docs: [
      StudyDocument(
        id: 'd6', subjectId: 's3',
        title: 'Cours — Algorithmes de tri',
        type: DocType.cours,
        date: DateTime(2026, 7, 30),
        filePath: null,
        fileName: 'algorithmes_tri.pdf',
        fileFormat: FileFormat.pdf,
      ),
      StudyDocument(
        id: 'd7', subjectId: 's3',
        title: 'TD n°5 — Récursivité',
        type: DocType.td,
        date: DateTime(2026, 7, 27),
        filePath: null,
        fileName: 'td_recursivite.docx',
        fileFormat: FileFormat.docx,
      ),
      StudyDocument(
        id: 'd8', subjectId: 's3',
        title: 'TP — Mini-projet Python',
        type: DocType.tp,
        date: DateTime(2026, 7, 24),
        favorite: true,
        filePath: null,
        fileName: 'mini_projet.pdf',
        fileFormat: FileFormat.pdf,
      ),
    ],
    grades: [
      Grade(
        id: 'g4',
        value: 16.5,
        coefficient: 1.0,
        label: 'TP1',
        date: DateTime(2026, 7, 25),
      ),
    ],
  ),
  Subject(
    id: 's4',
    name: 'Télécommunications',
    emoji: '📡',
    color: const Color(0xFF1857A4),
    semester: 1,
    docs: [
      StudyDocument(
        id: 'd9', subjectId: 's4',
        title: 'Cours — Modulation AM/FM',
        type: DocType.cours,
        date: DateTime(2026, 7, 26),
        filePath: null,
        fileName: 'modulation_am_fm.pdf',
        fileFormat: FileFormat.pdf,
      ),
      StudyDocument(
        id: 'd10', subjectId: 's4',
        title: 'Résumé Chapitre 2',
        type: DocType.resume,
        date: DateTime(2026, 7, 21),
        favorite: true,
        filePath: null,
        fileName: 'resume_chap2.docx',
        fileFormat: FileFormat.docx,
      ),
    ],
    grades: [],
  ),
];

final List<Note> seedNotes = [
  Note(
    id: 'n1',
    title: 'Révisions exam Maths',
    body: 'Revoir les chapitres 4 à 7 sur les matrices. Insister sur les changements de base et diagonalisation.',
    date: DateTime(2026, 7, 29),
  ),
  Note(
    id: 'n2',
    title: 'Questions à poser en Physique',
    body: 'Demander prof clarification sur le théorème de Poynting. Réfléchir lien avec équations de Maxwell.',
    date: DateTime(2026, 7, 28),
  ),
];

final List<Todo> seedTodos = [
  Todo(
    id: 't1',
    title: 'Réviser chapitre 4 Maths',
    isCompleted: false,
    dueDate: DateTime(2026, 7, 25),
    subjectId: 's1',
    priority: 2,
  ),
  Todo(
    id: 't2',
    title: 'TP Physique rapport',
    isCompleted: true,
    dueDate: DateTime(2026, 7, 22),
    subjectId: 's2',
    priority: 1,
  ),
  Todo(
    id: 't3',
    title: 'Préparer examen Informatique',
    isCompleted: false,
    dueDate: DateTime(2026, 7, 30),
    subjectId: 's3',
    priority: 2,
  ),
];

final List<Semester> seedSemesters = [
  const Semester(
    id: 'sem1',
    name: 'Semestre 1',
    order: 0,
  ),
  const Semester(
    id: 'sem2',
    name: 'Semestre 2',
    order: 1,
  ),
];
