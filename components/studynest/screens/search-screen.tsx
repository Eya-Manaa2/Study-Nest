'use client'

import { useStudyNest, getAllDocs, DOC_EMOJIS, DOC_TYPES, type DocType } from '@/lib/studynest-store'
import { useState } from 'react'

export function SearchScreen() {
  const { subjects, searchQuery, setSearchQuery, toggleFavorite, openSubject } = useStudyNest()
  const [filterType, setFilterType] = useState<DocType | 'Tous'>('Tous')

  const allDocs = getAllDocs(subjects)
  const filtered = allDocs.filter((doc) => {
    const q = searchQuery.toLowerCase()
    const matchesQuery = !q || doc.title.toLowerCase().includes(q) || doc.subjectName.toLowerCase().includes(q) || doc.type.toLowerCase().includes(q)
    const matchesType = filterType === 'Tous' || doc.type === filterType
    return matchesQuery && matchesType
  })

  return (
    <section
      className="flex-1 flex flex-col overflow-hidden sn-screen-enter"
      aria-label="Recherche"
    >
      {/* App bar */}
      <div
        className="flex-none px-5 pt-4 pb-3"
        style={{ background: 'var(--sn-bg)' }}
      >
        <h1 className="text-[22px] font-bold mb-3" style={{ fontFamily: 'var(--sn-font-display)' }}>
          Recherche
        </h1>

        {/* Search bar */}
        <div
          className="flex items-center gap-3 rounded-[16px] px-4 py-[13px] border"
          style={{
            background: 'var(--sn-surface)',
            borderColor: 'var(--sn-line)',
            boxShadow: '0 2px 8px var(--sn-shadow)',
          }}
        >
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className="w-5 h-5 flex-none" style={{ color: 'var(--sn-muted)' }} aria-hidden="true">
            <circle cx="11" cy="11" r="7"/><path d="M21 21l-4.3-4.3" strokeLinecap="round"/>
          </svg>
          <input
            type="search"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Un cours, un TD, une note…"
            className="flex-1 bg-transparent border-none outline-none text-[14.5px]"
            style={{ color: 'var(--sn-text)', fontFamily: 'Manrope, sans-serif' }}
            aria-label="Rechercher des documents"
          />
          {searchQuery && (
            <button
              onClick={() => setSearchQuery('')}
              className="flex-none w-6 h-6 rounded-full flex items-center justify-center"
              style={{ background: 'var(--sn-surface2)', color: 'var(--sn-muted)' }}
              aria-label="Effacer la recherche"
            >
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" className="w-3.5 h-3.5" aria-hidden="true">
                <path d="M18 6 6 18M6 6l12 12" strokeLinecap="round"/>
              </svg>
            </button>
          )}
        </div>

        {/* Filter chips */}
        <div
          className="flex gap-2 mt-3 overflow-x-auto pb-1"
          style={{ scrollbarWidth: 'none' }}
          role="group"
          aria-label="Filtrer par type"
        >
          {(['Tous', ...DOC_TYPES.filter(t => t !== 'Tous')] as (DocType | 'Tous')[]).map((type) => (
            <button
              key={type}
              onClick={() => setFilterType(type)}
              className="text-[12.5px] font-bold whitespace-nowrap py-[7px] px-[14px] rounded-full flex-none transition-all duration-150"
              style={{
                background: filterType === type ? 'var(--sn-accent)' : 'var(--sn-surface2)',
                color: filterType === type ? '#fff' : 'var(--sn-muted)',
              }}
              aria-pressed={filterType === type}
            >
              {type === 'Tous' ? 'Tous' : `${DOC_EMOJIS[type as DocType]} ${type}`}
            </button>
          ))}
        </div>
      </div>

      {/* Count */}
      <p className="text-[12px] px-5 py-2 flex-none" style={{ color: 'var(--sn-muted)' }}>
        {filtered.length} résultat{filtered.length !== 1 ? 's' : ''}
        {searchQuery ? ` pour « ${searchQuery} »` : ''}
      </p>

      {/* Results */}
      <div
        className="flex-1 overflow-y-auto px-5 pb-[80px]"
        style={{ scrollbarWidth: 'none' }}
      >
        {filtered.length === 0 ? (
          <div className="text-center py-16" style={{ color: 'var(--sn-muted)' }}>
            <p className="text-[44px] mb-3">🔍</p>
            <p className="font-bold text-[15px]" style={{ color: 'var(--sn-text)' }}>Aucun résultat</p>
            <p className="text-[12.5px] mt-1">Essaie un autre mot-clé</p>
          </div>
        ) : (
          <div className="flex flex-col gap-[10px]">
            {filtered.map((doc) => (
              <div
                key={doc.id}
                className="flex items-center gap-3 rounded-[18px] p-4 border transition-all duration-150"
                style={{
                  background: 'var(--sn-surface)',
                  borderColor: 'var(--sn-line)',
                  boxShadow: '0 2px 8px var(--sn-shadow)',
                }}
              >
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
    </section>
  )
}
