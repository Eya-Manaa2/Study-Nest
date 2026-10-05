'use client'

import { create } from 'zustand'

// ─── Types ───────────────────────────────────────────────────────────────────

export type DocType = 'Cours' | 'TD' | 'TP' | 'Examen' | 'Résumé' | 'Photo'

export interface Document {
  id: string
  subjectId: string
  title: string
  type: DocType
  date: string // ISO date string
  favorite: boolean
}

export interface Subject {
  id: string
  name: string
  emoji: string
  color: string // hex
  semester: 1 | 2
  docs: Document[]
}

export interface Note {
  id: string
  title: string
  body: string
  date: string
}

export type ThemeId =
  | 'clair'
  | 'sombre'
  | 'sakura'
  | 'ocean'
  | 'galaxie'
  | 'bibliotheque'
  | 'foret'
  | 'science'
  | 'reseau'
  | 'construction'

export type ScreenId =
  | 'auth'
  | 'home'
  | 'subjects'
  | 'subject-detail'
  | 'search'
  | 'favorites'
  | 'notes'
  | 'profile'

// ─── Theme definitions ───────────────────────────────────────────────────────

export interface ThemeDef {
  id: ThemeId
  label: string
  cssClass: string
  bg: string
  accent: string
  emoji: string
}

export const THEMES: ThemeDef[] = [
  { id: 'clair', label: 'Clair', cssClass: 'theme-clair', bg: '#FBF6F1', accent: '#7C2333', emoji: '☀️' },
  { id: 'sombre', label: 'Sombre', cssClass: 'theme-sombre', bg: '#161119', accent: '#E2536E', emoji: '🌙' },
  { id: 'sakura', label: 'Sakura', cssClass: 'theme-sakura', bg: '#FFF2F6', accent: '#E8637F', emoji: '🌸' },
  { id: 'ocean', label: 'Océan', cssClass: 'theme-ocean', bg: '#EAF6F8', accent: '#1C8CA3', emoji: '🌊' },
  { id: 'galaxie', label: 'Galaxie', cssClass: 'theme-galaxie', bg: '#130E29', accent: '#8B6CF0', emoji: '🔭' },
  { id: 'bibliotheque', label: 'Bibliothèque', cssClass: 'theme-bibliotheque', bg: '#F5EEDC', accent: '#8A5A2B', emoji: '📚' },
  { id: 'foret', label: 'Forêt', cssClass: 'theme-foret', bg: '#EEF5E9', accent: '#4C7A3B', emoji: '🌿' },
  { id: 'science', label: 'Science', cssClass: 'theme-science', bg: '#EFF7F6', accent: '#1F8A94', emoji: '🔬' },
  { id: 'reseau', label: 'Réseau', cssClass: 'theme-reseau', bg: '#EAF1FB', accent: '#1857A4', emoji: '📡' },
  { id: 'construction', label: 'Construction', cssClass: 'theme-construction', bg: '#FBF4E3', accent: '#E0A106', emoji: '🏗️' },
]

// ─── Seed data ───────────────────────────────────────────────────────────────

const SEED_SUBJECTS: Subject[] = [
  {
    id: 's1',
    name: 'Mathématiques',
    emoji: '∑',
    color: '#7C2333',
    semester: 1,
    docs: [
      { id: 'd1', subjectId: 's1', title: 'Cours — Algèbre linéaire', type: 'Cours', date: '2026-07-28', favorite: true },
      { id: 'd2', subjectId: 's1', title: 'TD n°3 — Matrices', type: 'TD', date: '2026-07-25', favorite: false },
      { id: 'd3', subjectId: 's1', title: 'Examen blanc S1', type: 'Examen', date: '2026-07-20', favorite: true },
    ],
  },
  {
    id: 's2',
    name: 'Physique',
    emoji: '⚡',
    color: '#1C8CA3',
    semester: 1,
    docs: [
      { id: 'd4', subjectId: 's2', title: 'Cours — Électromagnétisme', type: 'Cours', date: '2026-07-29', favorite: false },
      { id: 'd5', subjectId: 's2', title: 'TP — Oscilloscope', type: 'TP', date: '2026-07-22', favorite: true },
    ],
  },
  {
    id: 's3',
    name: 'Informatique',
    emoji: '💻',
    color: '#4C7A3B',
    semester: 1,
    docs: [
      { id: 'd6', subjectId: 's3', title: 'Cours — Algorithmes de tri', type: 'Cours', date: '2026-07-30', favorite: false },
      { id: 'd7', subjectId: 's3', title: 'TD n°5 — Récursivité', type: 'TD', date: '2026-07-27', favorite: false },
      { id: 'd8', subjectId: 's3', title: 'TP — Mini-projet Python', type: 'TP', date: '2026-07-24', favorite: true },
    ],
  },
  {
    id: 's4',
    name: 'Télécommunications',
    emoji: '📡',
    color: '#1857A4',
    semester: 1,
    docs: [
      { id: 'd9', subjectId: 's4', title: 'Cours — Modulation AM/FM', type: 'Cours', date: '2026-07-26', favorite: false },
      { id: 'd10', subjectId: 's4', title: 'Résumé Chapitre 2', type: 'Résumé', date: '2026-07-21', favorite: true },
    ],
  },
]

const SEED_NOTES: Note[] = [
  {
    id: 'n1',
    title: 'Révisions exam Maths',
    body: 'Revoir les chapitres 4 à 7 sur les matrices. Insister sur les changements de base et diagonalisation.',
    date: '2026-07-29',
  },
  {
    id: 'n2',
    title: 'Questions à poser en Physique',
    body: 'Demander prof clarification sur le théorème de Poynting. Réfléchir lien avec équations de Maxwell.',
    date: '2026-07-28',
  },
]

// ─── Store ───────────────────────────────────────────────────────────────────

interface StudyNestState {
  screen: ScreenId
  prevScreen: ScreenId | null
  activeTheme: ThemeId
  subjects: Subject[]
  notes: Note[]
  activeSubjectId: string | null
  activeDocType: DocType | 'Tous' | null
  searchQuery: string

  // Actions
  setScreen: (screen: ScreenId) => void
  goBack: () => void
  setTheme: (theme: ThemeId) => void
  openSubject: (id: string) => void
  setActiveDocType: (type: DocType | 'Tous') => void
  toggleFavorite: (docId: string) => void
  addNote: (title: string, body: string) => void
  deleteNote: (id: string) => void
  setSearchQuery: (q: string) => void
  addSubject: (name: string, emoji: string, color: string) => void
}

export const useStudyNest = create<StudyNestState>((set, get) => ({
  screen: 'auth',
  prevScreen: null,
  activeTheme: 'clair',
  subjects: SEED_SUBJECTS,
  notes: SEED_NOTES,
  activeSubjectId: null,
  activeDocType: 'Tous',
  searchQuery: '',

  setScreen: (screen) =>
    set((s) => ({ screen, prevScreen: s.screen })),

  goBack: () =>
    set((s) => ({ screen: s.prevScreen ?? 'home', prevScreen: null })),

  setTheme: (theme) => set({ activeTheme: theme }),

  openSubject: (id) =>
    set({ activeSubjectId: id, activeDocType: 'Tous', screen: 'subject-detail', prevScreen: 'subjects' }),

  setActiveDocType: (type) => set({ activeDocType: type }),

  toggleFavorite: (docId) =>
    set((s) => ({
      subjects: s.subjects.map((subj) => ({
        ...subj,
        docs: subj.docs.map((doc) =>
          doc.id === docId ? { ...doc, favorite: !doc.favorite } : doc
        ),
      })),
    })),

  addNote: (title, body) =>
    set((s) => ({
      notes: [
        {
          id: `n${Date.now()}`,
          title,
          body,
          date: new Date().toISOString().slice(0, 10),
        },
        ...s.notes,
      ],
    })),

  deleteNote: (id) =>
    set((s) => ({ notes: s.notes.filter((n) => n.id !== id) })),

  setSearchQuery: (q) => set({ searchQuery: q }),

  addSubject: (name, emoji, color) =>
    set((s) => ({
      subjects: [
        ...s.subjects,
        {
          id: `s${Date.now()}`,
          name,
          emoji,
          color,
          semester: 1,
          docs: [],
        },
      ],
    })),
}))

// ─── Helpers ─────────────────────────────────────────────────────────────────

export function getTheme(id: ThemeId): ThemeDef {
  return THEMES.find((t) => t.id === id)!
}

export function getAllDocs(subjects: Subject[]): (Document & { subjectName: string; subjectEmoji: string; subjectColor: string })[] {
  return subjects.flatMap((s) =>
    s.docs.map((d) => ({ ...d, subjectName: s.name, subjectEmoji: s.emoji, subjectColor: s.color }))
  )
}

export function getFavDocs(subjects: Subject[]) {
  return getAllDocs(subjects).filter((d) => d.favorite)
}

export function getRecentDocs(subjects: Subject[], limit = 4) {
  return getAllDocs(subjects)
    .sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime())
    .slice(0, limit)
}

export const DOC_TYPES: (DocType | 'Tous')[] = ['Tous', 'Cours', 'TD', 'TP', 'Examen', 'Résumé', 'Photo']

export const DOC_EMOJIS: Record<DocType, string> = {
  Cours: '📖',
  TD: '✏️',
  TP: '🔬',
  Examen: '📝',
  Résumé: '📋',
  Photo: '📷',
}
