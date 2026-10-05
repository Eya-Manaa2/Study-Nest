'use client'

import { useStudyNest, DOC_TYPES, DOC_EMOJIS, type DocType } from '@/lib/studynest-store'
import { useToast } from '../toast'

export function SubjectDetailScreen() {
  const { subjects, activeSubjectId, activeDocType, setActiveDocType, setScreen, toggleFavorite } = useStudyNest()
  const { showToast } = useToast()

  const subject = subjects.find((s) => s.id === activeSubjectId)
  if (!subject) return null

  const visibleDocs = activeDocType === 'Tous'
    ? subject.docs
    : subject.docs.filter((d) => d.type === activeDocType)

  const typeCount = (type: DocType | 'Tous') =>
    type === 'Tous' ? subject.docs.length : subject.docs.filter((d) => d.type === type).length

  return (
    <section
      className="flex-1 flex flex-col overflow-hidden relative sn-screen-enter"
      aria-label={`Matière : ${subject.name}`}
    >
      {/* Hero header */}
      <div
        className="flex-none px-5 pt-4 pb-5 relative overflow-hidden"
        style={{ background: 'var(--sn-surface)' }}
      >
        <div
          className="absolute inset-0 opacity-15 pointer-events-none"
          style={{ background: `linear-gradient(135deg, ${subject.color}, transparent 70%)` }}
          aria-hidden="true"
        />
        <div className="relative z-10">
          <div className="flex items-center justify-between mb-4">
            <button
              className="w-[40px] h-[40px] rounded-full flex items-center justify-center"
              style={{ background: 'var(--sn-surface2)', color: 'var(--sn-text)' }}
              onClick={() => setScreen('subjects')}
              aria-label="Retour aux matières"
            >
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" className="w-5 h-5" aria-hidden="true">
                <path d="M15 18l-6-6 6-6" strokeLinecap="round" strokeLinejoin="round"/>
              </svg>
            </button>
            <button
              className="w-[40px] h-[40px] rounded-full flex items-center justify-center"
              style={{ background: 'var(--sn-surface2)', color: 'var(--sn-text)' }}
              onClick={() => showToast('Options de la matière')}
              aria-label="Plus d'options"
            >
              <svg viewBox="0 0 24 24" fill="currentColor" className="w-5 h-5" aria-hidden="true">
                <circle cx="5" cy="12" r="2"/><circle cx="12" cy="12" r="2"/><circle cx="19" cy="12" r="2"/>
              </svg>
            </button>
          </div>

          <div className="flex items-center gap-3 mb-4">
            <div
              className="w-[52px] h-[52px] rounded-[16px] flex items-center justify-center text-[26px] flex-none"
              style={{ background: subject.color + '22' }}
              aria-hidden="true"
            >
              {subject.emoji}
            </div>
            <div>
              <h1 className="text-[22px] font-bold leading-none" style={{ fontFamily: 'var(--sn-font-display)' }}>
                {subject.name}
              </h1>
              <p className="text-[12px] mt-1" style={{ color: 'var(--sn-muted)' }}>Semestre 1</p>
            </div>
          </div>

          <div className="flex gap-5">
            {[
              { label: 'Docs', value: subject.docs.length },
              { label: 'Favoris', value: subject.docs.filter((d) => d.favorite).length },
              { label: 'Types', value: new Set(subject.docs.map((d) => d.type)).size },
            ].map((stat) => (
              <div key={stat.label} className="text-center">
                <strong className="block text-[20px] font-extrabold" style={{ fontFamily: 'var(--sn-font-display)' }}>
                  {stat.value}
                </strong>
                <span className="text-[11px]" style={{ color: 'var(--sn-muted)' }}>{stat.label}</span>
              </div>
            ))}
          </div>
        </div>
        <div className="h-px mt-4" style={{ background: 'var(--sn-line)' }} />
      </div>

      {/* Type tabs */}
      <div
        className="flex gap-2 px-5 py-3 overflow-x-auto flex-none"
        style={{ scrollbarWidth: 'none', background: 'var(--sn-surface)' }}
        role="tablist"
        aria-label="Types de documents"
      >
        {DOC_TYPES.filter((t) => t === 'Tous' || typeCount(t) > 0).map((type) => (
          <button
            key={type}
            role="tab"
            aria-selected={activeDocType === type}
            onClick={() => setActiveDocType(type as DocType | 'Tous')}
            className="text-[12.5px] font-bold whitespace-nowrap px-[14px] py-[8px] rounded-full flex-none transition-all duration-150"
            style={{
              background: activeDocType === type ? 'var(--sn-accent)' : 'var(--sn-surface2)',
              color: activeDocType === type ? '#fff' : 'var(--sn-muted)',
            }}
          >
            {type !== 'Tous' ? `${DOC_EMOJIS[type as DocType]} ` : ''}{type}
            {type !== 'Tous' && typeCount(type) > 0 && (
              <span className="ml-1 opacity-75 text-[10px]">({typeCount(type)})</span>
            )}
          </button>
        ))}
      </div>

      {/* Documents list */}
      <div
        className="flex-1 overflow-y-auto px-5 pt-3 pb-24"
        style={{ scrollbarWidth: 'none', background: 'var(--sn-bg)' }}
        role="tabpanel"
      >
        {visibleDocs.length === 0 ? (
          <div className="text-center py-16" style={{ color: 'var(--sn-muted)' }}>
            <p className="text-[44px] mb-3">📄</p>
            <p className="font-bold text-[15px]" style={{ color: 'var(--sn-text)' }}>Aucun document</p>
            <p className="text-[12.5px] mt-1">Ajoute ton premier document ici</p>
          </div>
        ) : (
          <div className="flex flex-col gap-[10px]">
            {visibleDocs.map((doc) => (
              <div
                key={doc.id}
                className="flex items-center gap-3 rounded-[18px] p-4 border"
                style={{
                  background: 'var(--sn-surface)',
                  borderColor: 'var(--sn-line)',
                  boxShadow: '0 2px 8px var(--sn-shadow)',
                }}
              >
                <div
                  className="w-[42px] h-[42px] rounded-[14px] flex items-center justify-center text-[20px] flex-none"
                  style={{ background: 'var(--sn-surface2)' }}
                  aria-hidden="true"
                >
                  {DOC_EMOJIS[doc.type]}
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-[13.5px] font-bold truncate">{doc.title}</p>
                  <p className="text-[11px] mt-0.5" style={{ color: 'var(--sn-muted)' }}>
                    {doc.type} · {new Date(doc.date).toLocaleDateString('fr-FR', { day: 'numeric', month: 'short' })}
                  </p>
                </div>
                <button
                  className="p-2 flex-none rounded-full active:scale-90 transition-transform"
                  style={{ color: doc.favorite ? 'var(--sn-accent)' : 'var(--sn-muted)' }}
                  onClick={() => toggleFavorite(doc.id)}
                  aria-label={doc.favorite ? 'Retirer des favoris' : 'Ajouter aux favoris'}
                >
                  <svg viewBox="0 0 24 24" fill={doc.favorite ? 'currentColor' : 'none'} stroke="currentColor" strokeWidth="1.8" className="w-5 h-5" aria-hidden="true">
                    <path d="M12 21s-7-4.6-9.5-9C.7 8.4 2 4.8 5.3 4.1 7.6 3.6 9.8 4.8 12 7c2.2-2.2 4.4-3.4 6.7-2.9C22 4.8 23.3 8.4 21.5 12 19 16.4 12 21 12 21z"/>
                  </svg>
                </button>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* FAB */}
      <button
        className="absolute right-5 bottom-7 w-[56px] h-[56px] rounded-full flex items-center justify-center text-white z-30"
        style={{
          background: 'var(--sn-accent)',
          boxShadow: '0 8px 24px -4px var(--sn-shadow)',
        }}
        onClick={() => showToast('Ajouter un document — bientôt disponible')}
        aria-label="Ajouter un document"
      >
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4" className="w-6 h-6" aria-hidden="true">
          <path d="M12 5v14M5 12h14" strokeLinecap="round"/>
        </svg>
      </button>
    </section>
  )
}
