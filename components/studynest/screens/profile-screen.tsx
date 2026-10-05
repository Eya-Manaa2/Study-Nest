'use client'

import { useStudyNest, THEMES, type ThemeId } from '@/lib/studynest-store'
import { useToast } from '../toast'

export function ProfileScreen() {
  const { activeTheme, setTheme, setScreen } = useStudyNest()
  const { showToast } = useToast()

  return (
    <section
      className="flex-1 overflow-y-auto pb-[80px] sn-screen-enter"
      style={{ scrollbarWidth: 'none' }}
      aria-label="Profil"
    >
      {/* Profile hero */}
      <div
        className="px-5 pt-6 pb-5 relative overflow-hidden"
        style={{
          background: `linear-gradient(160deg, var(--sn-accent) 0%, var(--sn-accent2) 100%)`,
        }}
      >
        <div className="flex items-center gap-4">
          <div
            className="w-[64px] h-[64px] rounded-[22px] flex items-center justify-center text-[24px] font-bold flex-none text-white"
            style={{ background: 'rgba(255,255,255,0.2)' }}
            aria-hidden="true"
          >
            E
          </div>
          <div>
            <h2 className="text-[19px] font-extrabold text-white leading-tight" style={{ fontFamily: 'var(--sn-font-display)' }}>
              Eya Ben Salah
            </h2>
            <p className="text-[12.5px] text-white opacity-80 mt-0.5">
              eya.bensalah@etu.tn
            </p>
            <span
              className="inline-block text-[10.5px] font-bold mt-1.5 px-2.5 py-0.5 rounded-full"
              style={{ background: 'rgba(255,255,255,0.25)', color: '#fff' }}
            >
              Gratuit
            </span>
          </div>
        </div>
      </div>

      <div className="px-5">
        {/* Theme section */}
        <div className="flex items-center justify-between mt-6 mb-4">
          <h3 className="text-[16px] font-bold" style={{ fontFamily: 'var(--sn-font-display)' }}>
            Thème immersif
          </h3>
        </div>

        <div
          className="flex gap-3 overflow-x-auto py-1 -mx-5 px-5"
          style={{ scrollbarWidth: 'none' }}
          role="radiogroup"
          aria-label="Choisir un thème"
        >
          {THEMES.map((theme) => (
            <button
              key={theme.id}
              role="radio"
              aria-checked={activeTheme === theme.id}
              onClick={() => {
                setTheme(theme.id as ThemeId)
                showToast(`Thème ${theme.label} activé`)
              }}
              className="flex-none flex flex-col items-center gap-[6px] cursor-pointer"
            >
              <div
                className="w-[60px] h-[60px] rounded-[20px] flex items-center justify-center text-[26px] transition-all duration-200"
                style={{
                  background: theme.bg,
                  border: activeTheme === theme.id
                    ? `3px solid ${theme.accent}`
                    : '3px solid transparent',
                  boxShadow: activeTheme === theme.id
                    ? `0 4px 16px ${theme.accent}55`
                    : '0 2px 6px rgba(0,0,0,0.10)',
                }}
                aria-hidden="true"
              >
                {theme.emoji}
              </div>
              <p
                className="text-[10.5px] font-bold leading-tight text-center max-w-[60px] truncate"
                style={{ color: activeTheme === theme.id ? 'var(--sn-accent)' : 'var(--sn-muted)' }}
              >
                {theme.label}
              </p>
            </button>
          ))}
        </div>

        {/* Settings */}
        <h3 className="text-[16px] font-bold mt-6 mb-3" style={{ fontFamily: 'var(--sn-font-display)' }}>Compte</h3>

        <div
          className="rounded-[20px] overflow-hidden border"
          style={{
            background: 'var(--sn-surface)',
            borderColor: 'var(--sn-line)',
            boxShadow: '0 2px 8px var(--sn-shadow)',
          }}
          role="list"
        >
          {[
            {
              icon: '📓',
              label: 'Mes notes',
              badge: null,
              action: () => setScreen('notes'),
              showChevron: true,
            },
            {
              icon: '☁️',
              label: 'Sauvegarde & synchronisation',
              badge: null,
              action: () => showToast('Sauvegarde à jour · Firebase'),
              showChevron: true,
            },
            {
              icon: '🔗',
              label: 'Partager un dossier',
              badge: null,
              action: () => showToast('Partage de dossiers — arrive en V2'),
              showChevron: true,
            },
            {
              icon: '🔒',
              label: 'Verrouillage biométrique',
              badge: 'PREMIUM',
              action: () => showToast('Fonctionnalité Premium'),
              showChevron: false,
            },
            {
              icon: '🚪',
              label: 'Se déconnecter',
              badge: null,
              action: () => setScreen('auth'),
              showChevron: false,
              danger: true,
            },
          ].map((item, i, arr) => (
            <button
              key={i}
              role="listitem"
              className="flex items-center gap-3.5 w-full px-4 py-4 text-left transition-colors"
              style={{
                borderBottom: i < arr.length - 1 ? '1px solid var(--sn-line)' : 'none',
                color: item.danger ? 'var(--sn-accent)' : 'var(--sn-text)',
              }}
              onClick={item.action}
            >
              <span className="text-[20px] flex-none" aria-hidden="true">{item.icon}</span>
              <span className="flex-1 text-[14px] font-semibold">{item.label}</span>
              {item.badge && (
                <span
                  className="text-[10px] font-extrabold px-2.5 py-1 rounded-full flex-none"
                  style={{ color: 'var(--sn-accent)', background: 'var(--sn-surface2)' }}
                >
                  {item.badge}
                </span>
              )}
              {item.showChevron && (
                <svg
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="2"
                  className="w-4 h-4 flex-none"
                  style={{ color: 'var(--sn-muted)' }}
                  aria-hidden="true"
                >
                  <path d="M9 6l6 6-6 6" strokeLinecap="round" strokeLinejoin="round"/>
                </svg>
              )}
            </button>
          ))}
        </div>

        {/* Version */}
        <p className="text-center text-[11px] mt-6" style={{ color: 'var(--sn-muted)' }}>
          StudyNest v1.0.0 · Fait avec ❤️ pour les étudiants
        </p>
      </div>
    </section>
  )
}
