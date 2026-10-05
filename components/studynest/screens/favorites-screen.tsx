'use client'

import { useStudyNest, getFavDocs, DOC_EMOJIS } from '@/lib/studynest-store'

export function FavoritesScreen() {
  const { subjects, toggleFavorite, openSubject } = useStudyNest()
  const favs = getFavDocs(subjects)

  return (
    <section
      className="flex-1 flex flex-col overflow-hidden sn-screen-enter"
      aria-label="Favoris"
    >
      {/* App bar */}
      <div
        className="flex-none px-5 pt-4 pb-3"
        style={{ background: 'var(--sn-bg)' }}
      >
        <h1 className="text-[22px] font-bold" style={{ fontFamily: 'var(--sn-font-display)' }}>Favoris</h1>
        <p className="text-[13px] mt-1" style={{ color: 'var(--sn-muted)' }}>
          Accès rapide à ce qui compte avant l&apos;examen.
        </p>
      </div>

      <div
        className="flex-1 overflow-y-auto px-5 pb-[80px]"
        style={{ scrollbarWidth: 'none' }}
      >
        {favs.length === 0 ? (
          <div className="text-center py-20" style={{ color: 'var(--sn-muted)' }}>
            <p className="text-[52px] mb-3">💛</p>
            <p className="font-bold text-[16px]" style={{ color: 'var(--sn-text)' }}>Aucun favori</p>
            <p className="text-[13px] mt-2">Marque des documents pour les retrouver ici</p>
          </div>
        ) : (
          <div className="flex flex-col gap-[10px]">
            {favs.map((doc) => (
              <div
                key={doc.id}
                className="flex items-center gap-3 rounded-[18px] p-4 border transition-all duration-150"
                style={{
                  background: 'var(--sn-surface)',
                  borderColor: 'var(--sn-line)',
                  boxShadow: '0 2px 8px var(--sn-shadow)',
                }}
              >
                {/* color accent bar */}
                <div
                  className="w-[5px] self-stretch rounded-full flex-none min-h-[42px]"
                  style={{ background: doc.subjectColor }}
                  aria-hidden="true"
                />
                <button
                  className="flex items-center gap-3 flex-1 min-w-0 text-left active:scale-[0.98]"
                  onClick={() => openSubject(doc.subjectId)}
                  aria-label={`Ouvrir ${doc.title}`}
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
                      {doc.subjectName} · {doc.type}
                    </p>
                  </div>
                </button>
                <button
                  className="p-2 flex-none rounded-full active:scale-90 transition-transform"
                  style={{ color: 'var(--sn-accent)' }}
                  onClick={() => toggleFavorite(doc.id)}
                  aria-label="Retirer des favoris"
                >
                  <svg viewBox="0 0 24 24" fill="currentColor" stroke="currentColor" strokeWidth="1.8" className="w-5 h-5" aria-hidden="true">
                    <path d="M12 21s-7-4.6-9.5-9C.7 8.4 2 4.8 5.3 4.1 7.6 3.6 9.8 4.8 12 7c2.2-2.2 4.4-3.4 6.7-2.9C22 4.8 23.3 8.4 21.5 12 19 16.4 12 21 12 21z"/>
                  </svg>
                </button>
              </div>
            ))}
          </div>
        )}
      </div>
    </section>
  )
}
