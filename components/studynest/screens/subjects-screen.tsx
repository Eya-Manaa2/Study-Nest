'use client'

import { useState } from 'react'
import { useStudyNest } from '@/lib/studynest-store'
import { useToast } from '../toast'

const SUBJECT_COLORS = [
  '#7C2333', '#1C8CA3', '#4C7A3B', '#1857A4',
  '#8B6CF0', '#E8637F', '#8A5A2B', '#E0A106',
]

export function SubjectsScreen() {
  const { subjects, openSubject, addSubject } = useStudyNest()
  const { showToast } = useToast()
  const [showAdd, setShowAdd] = useState(false)
  const [newName, setNewName] = useState('')
  const [newEmoji, setNewEmoji] = useState('📖')
  const [newColor, setNewColor] = useState(SUBJECT_COLORS[0])

  const sem1 = subjects.filter((s) => s.semester === 1)

  function handleAdd() {
    if (!newName.trim()) return
    addSubject(newName.trim(), newEmoji, newColor)
    setNewName('')
    setNewEmoji('📖')
    setNewColor(SUBJECT_COLORS[0])
    setShowAdd(false)
    showToast('Matière ajoutée !')
  }

  return (
    <section
      className="flex-1 flex flex-col overflow-hidden relative sn-screen-enter"
      aria-label="Mes matières"
    >
      {/* App bar */}
      <div
        className="sticky top-0 z-20 px-5 pt-4 pb-3 flex items-center justify-between flex-none"
        style={{ background: 'var(--sn-bg)' }}
      >
        <h1 className="text-[22px] font-bold" style={{ fontFamily: 'var(--sn-font-display)' }}>
          Mes matières
        </h1>
        <button
          className="w-[40px] h-[40px] rounded-full flex items-center justify-center"
          style={{ background: 'var(--sn-accent)', color: '#fff', boxShadow: '0 4px 12px var(--sn-shadow)' }}
          onClick={() => setShowAdd(true)}
          aria-label="Ajouter une matière"
        >
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" className="w-5 h-5" aria-hidden="true">
            <path d="M12 5v14M5 12h14" strokeLinecap="round"/>
          </svg>
        </button>
      </div>

      {/* Semester chips */}
      <div className="flex gap-2 px-5 mb-4 flex-none">
        <button
          className="text-[12.5px] font-bold py-[8px] px-[16px] rounded-full text-white"
          style={{ background: 'var(--sn-accent)' }}
        >
          Semestre 1
        </button>
        <button
          className="text-[12.5px] font-bold py-[8px] px-[16px] rounded-full opacity-50 cursor-default"
          style={{ background: 'var(--sn-surface2)', color: 'var(--sn-muted)' }}
          disabled
        >
          Semestre 2 · Bientôt
        </button>
      </div>

      {/* Grid */}
      <div
        className="flex-1 overflow-y-auto px-5 pb-[80px]"
        style={{ scrollbarWidth: 'none' }}
      >
        <div className="grid grid-cols-2 gap-3">
          {sem1.map((subj) => {
            const progress = subj.docs.length > 0 ? Math.min(subj.docs.length * 12, 100) : 0
            return (
              <button
                key={subj.id}
                className="rounded-[20px] p-4 border text-left flex flex-col justify-between min-h-[160px] relative overflow-hidden transition-all duration-150 active:scale-[0.97]"
                style={{
                  background: 'var(--sn-surface)',
                  borderColor: 'var(--sn-line)',
                  boxShadow: '0 4px 14px var(--sn-shadow)',
                }}
                onClick={() => openSubject(subj.id)}
              >
                {/* color wash */}
                <div
                  className="absolute inset-0 opacity-[0.08] pointer-events-none"
                  style={{ background: subj.color }}
                  aria-hidden="true"
                />
                {/* Accent corner */}
                <div
                  className="absolute top-0 right-0 w-14 h-14 rounded-bl-[40px] opacity-20 pointer-events-none"
                  style={{ background: subj.color }}
                  aria-hidden="true"
                />
                <div
                  className="w-10 h-10 rounded-[14px] flex items-center justify-center text-[20px] relative z-10 shadow-sm"
                  style={{ background: 'var(--sn-surface)' }}
                  aria-hidden="true"
                >
                  {subj.emoji}
                </div>
                <div className="relative z-10">
                  <p className="font-extrabold text-[14.5px] leading-tight">{subj.name}</p>
                  <p className="text-[11px] mt-0.5" style={{ color: 'var(--sn-muted)' }}>
                    {subj.docs.length} document{subj.docs.length !== 1 ? 's' : ''}
                  </p>
                  <div
                    className="h-[5px] rounded-full mt-[10px] overflow-hidden"
                    style={{ background: 'var(--sn-surface2)' }}
                    role="progressbar"
                    aria-valuenow={progress}
                    aria-valuemin={0}
                    aria-valuemax={100}
                  >
                    <div
                      className="h-full rounded-full transition-all duration-500"
                      style={{ width: `${progress}%`, background: subj.color }}
                    />
                  </div>
                  <p className="text-[10px] mt-1" style={{ color: 'var(--sn-muted)' }}>
                    {progress}% rempli
                  </p>
                </div>
              </button>
            )
          })}

          {/* Add button */}
          <button
            className="rounded-[20px] border-[2px] border-dashed flex flex-col items-center justify-center gap-2 min-h-[160px] text-[13px] font-bold transition-opacity hover:opacity-80 active:scale-[0.97]"
            style={{ borderColor: 'var(--sn-line)', color: 'var(--sn-muted)' }}
            onClick={() => setShowAdd(true)}
            aria-label="Ajouter une matière"
          >
            <div
              className="w-10 h-10 rounded-full flex items-center justify-center"
              style={{ background: 'var(--sn-surface2)' }}
              aria-hidden="true"
            >
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className="w-5 h-5" aria-hidden="true">
                <path d="M12 5v14M5 12h14" strokeLinecap="round"/>
              </svg>
            </div>
            Nouvelle matière
          </button>
        </div>
      </div>

      {/* Add sheet modal */}
      {showAdd && (
        <div
          className="absolute inset-0 z-[60] flex items-end"
          style={{ background: 'rgba(10,6,8,.5)' }}
          onClick={(e) => { if (e.target === e.currentTarget) setShowAdd(false) }}
        >
          <div
            className="w-full rounded-t-[28px] p-5 pb-8 sn-sheet-enter"
            style={{ background: 'var(--sn-surface)' }}
            role="dialog"
            aria-label="Nouvelle matière"
          >
            <div className="w-10 h-1 rounded-full mx-auto mb-5" style={{ background: 'var(--sn-line)' }} aria-hidden="true" />
            <h3 className="text-[17px] font-bold mb-4" style={{ fontFamily: 'var(--sn-font-display)' }}>
              Nouvelle matière
            </h3>
            <input
              type="text"
              value={newName}
              onChange={(e) => setNewName(e.target.value)}
              placeholder="Nom de la matière"
              className="w-full border rounded-[14px] px-4 py-3 text-[14px] outline-none"
              style={{
                borderColor: 'var(--sn-line)',
                background: 'var(--sn-bg)',
                color: 'var(--sn-text)',
                fontFamily: 'var(--font-sans)',
              }}
              autoFocus
            />
            <div className="mt-4">
              <p className="text-[11px] font-bold mb-2.5 uppercase tracking-wider" style={{ color: 'var(--sn-muted)' }}>Emoji</p>
              <div className="flex gap-2 flex-wrap">
                {['📖', '⚡', '💻', '📡', '🔬', '🧮', '🌍', '🎨'].map((e) => (
                  <button
                    key={e}
                    onClick={() => setNewEmoji(e)}
                    className="w-10 h-10 rounded-[12px] text-[20px] border-[2px] transition-all"
                    style={{
                      borderColor: newEmoji === e ? 'var(--sn-accent)' : 'var(--sn-line)',
                      background: newEmoji === e ? 'var(--sn-surface2)' : 'var(--sn-surface)',
                    }}
                  >
                    {e}
                  </button>
                ))}
              </div>
            </div>
            <div className="mt-4">
              <p className="text-[11px] font-bold mb-2.5 uppercase tracking-wider" style={{ color: 'var(--sn-muted)' }}>Couleur</p>
              <div className="flex gap-2.5">
                {SUBJECT_COLORS.map((c) => (
                  <button
                    key={c}
                    onClick={() => setNewColor(c)}
                    className="w-7 h-7 rounded-full border-[2.5px] transition-all"
                    style={{
                      background: c,
                      borderColor: newColor === c ? 'var(--sn-text)' : 'transparent',
                    }}
                    aria-label={`Couleur ${c}`}
                  />
                ))}
              </div>
            </div>
            <div className="flex gap-3 mt-5">
              <button
                className="flex-1 rounded-[14px] py-[14px] text-[14.5px] font-bold"
                style={{ background: 'var(--sn-surface2)', color: 'var(--sn-text)' }}
                onClick={() => setShowAdd(false)}
              >
                Annuler
              </button>
              <button
                className="flex-1 rounded-[14px] py-[14px] text-[14.5px] font-bold text-white"
                style={{ background: 'var(--sn-accent)', boxShadow: '0 4px 14px var(--sn-shadow)' }}
                onClick={handleAdd}
              >
                Ajouter
              </button>
            </div>
          </div>
        </div>
      )}
    </section>
  )
}
