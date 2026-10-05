'use client'

import { useState } from 'react'
import { useStudyNest } from '@/lib/studynest-store'
import { useToast } from '../toast'

export function NotesScreen() {
  const { notes, addNote, deleteNote, setScreen } = useStudyNest()
  const { showToast } = useToast()
  const [showSheet, setShowSheet] = useState(false)
  const [titleInput, setTitleInput] = useState('')
  const [bodyInput, setBodyInput] = useState('')

  function handleSave() {
    if (!titleInput.trim()) return
    addNote(titleInput.trim(), bodyInput.trim())
    setTitleInput('')
    setBodyInput('')
    setShowSheet(false)
    showToast('Note enregistrée !')
  }

  function handleDelete(id: string) {
    deleteNote(id)
    showToast('Note supprimée')
  }

  return (
    <section
      className="flex-1 flex flex-col overflow-hidden relative sn-screen-enter"
      aria-label="Mes notes"
    >
      {/* App bar */}
      <div
        className="flex-none px-5 pt-4 pb-3 flex items-center justify-between"
        style={{ background: 'var(--sn-bg)' }}
      >
        <div className="flex items-center gap-3">
          <button
            className="w-[40px] h-[40px] rounded-full flex items-center justify-center"
            style={{ background: 'var(--sn-surface2)', color: 'var(--sn-text)' }}
            onClick={() => setScreen('profile')}
            aria-label="Retour au profil"
          >
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" className="w-5 h-5" aria-hidden="true">
              <path d="M15 18l-6-6 6-6" strokeLinecap="round" strokeLinejoin="round"/>
            </svg>
          </button>
          <h1 className="text-[22px] font-bold" style={{ fontFamily: 'var(--sn-font-display)' }}>Mes notes</h1>
        </div>
        <button
          className="w-[40px] h-[40px] rounded-full flex items-center justify-center"
          style={{ background: 'var(--sn-accent)', color: '#fff', boxShadow: '0 4px 12px var(--sn-shadow)' }}
          onClick={() => setShowSheet(true)}
          aria-label="Nouvelle note"
        >
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" className="w-5 h-5" aria-hidden="true">
            <path d="M12 5v14M5 12h14" strokeLinecap="round"/>
          </svg>
        </button>
      </div>

      <div
        className="flex-1 overflow-y-auto px-5 pb-6"
        style={{ scrollbarWidth: 'none' }}
      >
        {notes.length === 0 ? (
          <div className="text-center py-20" style={{ color: 'var(--sn-muted)' }}>
            <p className="text-[52px] mb-3">📝</p>
            <p className="font-bold text-[16px]" style={{ color: 'var(--sn-text)' }}>Aucune note</p>
            <p className="text-[13px] mt-2">Crée ta première note ici</p>
          </div>
        ) : (
          <div className="flex flex-col gap-[10px]">
            {notes.map((note) => (
              <div
                key={note.id}
                className="rounded-[20px] p-5 border"
                style={{
                  background: 'var(--sn-surface)',
                  borderColor: 'var(--sn-line)',
                  boxShadow: '0 2px 8px var(--sn-shadow)',
                }}
              >
                <div className="flex justify-between items-start gap-3">
                  <div className="flex-1 min-w-0">
                    <p
                      className="text-[10.5px] font-extrabold uppercase tracking-widest mb-1.5"
                      style={{ color: 'var(--sn-accent)' }}
                    >
                      Note personnelle
                    </p>
                    <p className="font-bold text-[14.5px]">{note.title}</p>
                    <p className="text-[12.5px] mt-2 leading-relaxed" style={{ color: 'var(--sn-muted)' }}>
                      {note.body}
                    </p>
                  </div>
                  <button
                    className="p-2 flex-none rounded-full active:scale-90 transition-transform"
                    style={{ color: 'var(--sn-muted)', background: 'var(--sn-surface2)' }}
                    onClick={() => handleDelete(note.id)}
                    aria-label="Supprimer la note"
                  >
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" className="w-4 h-4" aria-hidden="true">
                      <path d="M3 6h18M8 6V4h8v2M19 6l-1 14H6L5 6" strokeLinecap="round" strokeLinejoin="round"/>
                    </svg>
                  </button>
                </div>
                <p className="text-[11px] mt-3" style={{ color: 'var(--sn-muted)' }}>
                  {new Date(note.date).toLocaleDateString('fr-FR', { day: 'numeric', month: 'long', year: 'numeric' })}
                </p>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Add note sheet */}
      {showSheet && (
        <div
          className="absolute inset-0 z-[60] flex items-end"
          style={{ background: 'rgba(10,6,8,.5)' }}
          onClick={(e) => { if (e.target === e.currentTarget) setShowSheet(false) }}
        >
          <div
            className="w-full rounded-t-[28px] p-5 pb-8 sn-sheet-enter"
            style={{ background: 'var(--sn-surface)' }}
            role="dialog"
            aria-label="Nouvelle note"
          >
            <div className="w-10 h-1 rounded-full mx-auto mb-5" style={{ background: 'var(--sn-line)' }} aria-hidden="true" />
            <h3 className="text-[17px] font-bold mb-4" style={{ fontFamily: 'var(--sn-font-display)' }}>Nouvelle note</h3>
            <input
              type="text"
              value={titleInput}
              onChange={(e) => setTitleInput(e.target.value)}
              placeholder="Titre de la note"
              className="w-full border rounded-[14px] px-4 py-3 text-[14px] outline-none"
              style={{
                borderColor: 'var(--sn-line)',
                background: 'var(--sn-bg)',
                color: 'var(--sn-text)',
                fontFamily: 'Manrope, sans-serif',
              }}
              autoFocus
            />
            <textarea
              value={bodyInput}
              onChange={(e) => setBodyInput(e.target.value)}
              placeholder="Écris ta note ici…"
              className="w-full border rounded-[14px] px-4 py-3 text-[14px] outline-none resize-none mt-3 h-[100px]"
              style={{
                borderColor: 'var(--sn-line)',
                background: 'var(--sn-bg)',
                color: 'var(--sn-text)',
                fontFamily: 'Manrope, sans-serif',
              }}
              onKeyDown={(e) => {
                if (e.key === 'Enter' && !e.shiftKey && !e.nativeEvent.isComposing && e.keyCode !== 229) {
                  e.preventDefault()
                  handleSave()
                }
              }}
            />
            <div className="flex gap-3 mt-4">
              <button
                className="flex-1 rounded-[14px] py-[14px] text-[14.5px] font-bold"
                style={{ background: 'var(--sn-surface2)', color: 'var(--sn-text)' }}
                onClick={() => setShowSheet(false)}
              >
                Annuler
              </button>
              <button
                className="flex-1 rounded-[14px] py-[14px] text-[14.5px] font-bold text-white"
                style={{ background: 'var(--sn-accent)', boxShadow: '0 4px 14px var(--sn-shadow)' }}
                onClick={handleSave}
              >
                Enregistrer
              </button>
            </div>
          </div>
        </div>
      )}
    </section>
  )
}
