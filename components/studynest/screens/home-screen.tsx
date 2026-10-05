'use client'

import { useStudyNest, getRecentDocs, getFavDocs, DOC_EMOJIS } from '@/lib/studynest-store'
import { useToast } from '../toast'

export function HomeScreen() {
  const { subjects, toggleFavorite, openSubject, setScreen } = useStudyNest()
  const { showToast } = useToast()

  const recent = getRecentDocs(subjects, 4)
  const favCount = getFavDocs(subjects).length
  const totalDocs = subjects.flatMap((s) => s.docs).length

  const today = new Date().toLocaleDateString('fr-FR', { weekday: 'long', day: 'numeric', month: 'long' })
  const todayCapitalized = today.charAt(0).toUpperCase() + today.slice(1)

  return (
    <section
      className="flex-1 overflow-y-auto pb-[80px] sn-screen-enter"
      style={{ scrollbarWidth: 'none' }}
      aria-label="Accueil"
    >
      {/* App bar */}
      <div
        className="sticky top-0 z-20 px-5 pt-4 pb-3 flex items-center justify-between"
        style={{ background: 'var(--sn-bg)' }}
      >
        <div className="flex items-center gap-3">
          <div
            className="w-[44px] h-[44px] rounded-full flex items-center justify-center text-[16px] font-bold flex-none relative"
            style={{ background: 'var(--sn-accent)', color: '#fff' }}
            aria-hidden="true"
          >
            E
          </div>
          <div>
            <h2 className="text-[18px] font-bold leading-none" style={{ fontFamily: 'var(--sn-font-display)' }}>
              Bonjour, Eya
            </h2>
            <p className="text-[12px] mt-0.5" style={{ color: 'var(--sn-muted)' }}>{todayCapitalized}</p>
          </div>
        </div>
        <button
          className="w-[40px] h-[40px] rounded-full flex items-center justify-center"
          style={{ background: 'var(--sn-surface)', color: 'var(--sn-text)', boxShadow: '0 2px 8px var(--sn-shadow)' }}
          onClick={() => showToast('Notifications — bientôt disponible')}
          aria-label="Notifications"
        >
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" className="w-5 h-5" aria-hidden="true">
            <path d="M18 8a6 6 0 10-12 0c0 7-3 9-3 9h18s-3-2-3-9"/>
            <path d="M13.7 21a2 2 0 01-3.4 0"/>
          </svg>
        </button>
      </div>

      <div className="px-5">
        {/* Semester chips */}
        <div className="flex gap-2 mb-5">
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

        {/* Summary grid */}
        <div className="grid grid-cols-2 gap-3 mb-6">
          {[
            { value: totalDocs, label: 'Documents rangés', icon: '📁' },
            { value: favCount, label: 'Favoris', icon: '❤️' },
            { value: subjects.length, label: 'Matières', icon: '📚' },
            { value: 2, label: 'Notes rapides', icon: '📝' },
          ].map((stat) => (
            <div
              key={stat.label}
              className="rounded-[20px] p-4 border flex items-center gap-3"
              style={{ background: 'var(--sn-surface)', borderColor: 'var(--sn-line)', boxShadow: '0 2px 8px var(--sn-shadow)' }}
            >
              <span className="text-[24px]" aria-hidden="true">{stat.icon}</span>
              <div>
                <div
                  className="text-[22px] font-extrabold leading-none"
                  style={{ fontFamily: 'var(--sn-font-display)', color: 'var(--sn-text)' }}
                >
                  {stat.value}
                </div>
                <div className="text-[11px] mt-0.5 leading-tight" style={{ color: 'var(--sn-muted)' }}>
                  {stat.label}
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Recent docs */}
        <div className="flex items-center justify-between mb-3">
          <h3
            className="text-[16px] font-bold"
            style={{ fontFamily: 'var(--sn-font-display)' }}
          >
            Récemment ajoutés
          </h3>
          <button
            className="text-[12.5px] font-bold"
            style={{ color: 'var(--sn-accent)' }}
            onClick={() => setScreen('search')}
          >
            Tout voir
          </button>
        </div>

        <div className="flex flex-col gap-[10px]">
          {recent.map((doc) => (
            <div
              key={doc.id}
              className="flex items-center gap-3 rounded-[18px] p-[14px] border transition-all duration-150"
              style={{ background: 'var(--sn-surface)', borderColor: 'var(--sn-line)', boxShadow: '0 2px 10px var(--sn-shadow)' }}
            >
              <button
                className="flex items-center gap-3 flex-1 min-w-0 text-left active:scale-[0.98]"
                onClick={() => openSubject(doc.subjectId)}
                aria-label={`Ouvrir ${doc.title}`}
              >
                <div
                  className="w-11 h-11 rounded-[14px] flex items-center justify-center text-[20px] flex-none"
                  style={{ background: 'var(--sn-surface2)' }}
                  aria-hidden="true"
                >
                  {DOC_EMOJIS[doc.type]}
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-[14px] font-bold truncate">{doc.title}</p>
                  <p className="text-[12px] mt-0.5" style={{ color: 'var(--sn-muted)' }}>
                    {doc.subjectName} · {doc.type}
                  </p>
                </div>
              </button>
              <button
                className="p-2 flex-none rounded-full transition-colors active:scale-90"
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

        {/* Premium banner */}
        <div
          className="mt-6 rounded-[20px] p-5 flex items-center gap-4"
          style={{
            background: `linear-gradient(135deg, var(--sn-accent), var(--sn-accent2))`,
            boxShadow: '0 8px 24px -6px var(--sn-shadow)',
          }}
        >
          <span className="text-[32px]" aria-hidden="true">🚀</span>
          <div className="flex-1">
            <p className="font-extrabold text-[14.5px] text-white">Passe à StudyNest Pro</p>
            <p className="text-[12px] text-white opacity-85 mt-0.5 leading-snug">
              Stockage illimité, thèmes exclusifs, sauvegarde auto
            </p>
          </div>
          <button
            className="rounded-full px-4 py-2.5 text-[12.5px] font-bold flex-none"
            style={{ background: '#fff', color: 'var(--sn-accent)' }}
            onClick={() => showToast('Offre Pro — bientôt disponible')}
          >
            Voir
          </button>
        </div>
      </div>
    </section>
  )
}
