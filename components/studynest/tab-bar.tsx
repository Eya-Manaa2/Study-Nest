'use client'

import { useStudyNest, type ScreenId } from '@/lib/studynest-store'
import { cn } from '@/lib/utils'

interface TabItem {
  id: string
  tab: ScreenId
  label: string
  icon: (active: boolean) => React.ReactNode
}

const TABS: TabItem[] = [
  {
    id: 'home',
    tab: 'home',
    label: 'Accueil',
    icon: (active) => (
      <svg viewBox="0 0 24 24" fill={active ? 'currentColor' : 'none'} stroke="currentColor" strokeWidth="1.8" className="w-[24px] h-[24px]">
        <path d="M3 12L12 4l9 8" strokeLinecap="round"/>
        <path d="M5 10v9a1 1 0 001 1h4v-5h4v5h4a1 1 0 001-1v-9" strokeLinecap="round" strokeLinejoin="round"/>
      </svg>
    ),
  },
  {
    id: 'subjects',
    tab: 'subjects',
    label: 'Matières',
    icon: (active) => (
      <svg viewBox="0 0 24 24" fill={active ? 'currentColor' : 'none'} stroke="currentColor" strokeWidth="1.8" className="w-[24px] h-[24px]">
        <path d="M4 19.5A2.5 2.5 0 016.5 17H20"/>
        <path d="M6.5 2H20v20H6.5A2.5 2.5 0 014 19.5v-15A2.5 2.5 0 016.5 2z" strokeLinejoin="round"/>
      </svg>
    ),
  },
  {
    id: 'search',
    tab: 'search',
    label: 'Recherche',
    icon: (active) => (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={active ? '2.2' : '1.8'} className="w-[24px] h-[24px]">
        <circle cx="11" cy="11" r="7"/>
        <path d="M21 21l-4.3-4.3" strokeLinecap="round"/>
      </svg>
    ),
  },
  {
    id: 'favorites',
    tab: 'favorites',
    label: 'Favoris',
    icon: (active) => (
      <svg viewBox="0 0 24 24" fill={active ? 'currentColor' : 'none'} stroke="currentColor" strokeWidth="1.8" className="w-[24px] h-[24px]">
        <path d="M12 21s-7-4.6-9.5-9C.7 8.4 2 4.8 5.3 4.1 7.6 3.6 9.8 4.8 12 7c2.2-2.2 4.4-3.4 6.7-2.9C22 4.8 23.3 8.4 21.5 12 19 16.4 12 21 12 21z"/>
      </svg>
    ),
  },
  {
    id: 'profile',
    tab: 'profile',
    label: 'Profil',
    icon: (active) => (
      <svg viewBox="0 0 24 24" fill={active ? 'currentColor' : 'none'} stroke="currentColor" strokeWidth="1.8" className="w-[24px] h-[24px]">
        <circle cx="12" cy="8" r="4" strokeLinejoin="round"/>
        <path d="M4 20c0-4 3.6-7 8-7s8 3 8 7" strokeLinecap="round"/>
      </svg>
    ),
  },
]

export function TabBar() {
  const { screen, setScreen } = useStudyNest()

  return (
    <nav
      className="absolute left-0 right-0 bottom-0 z-[70] flex-none"
      style={{ background: 'var(--sn-surface)', borderTop: '1px solid var(--sn-line)', paddingBottom: 'env(safe-area-inset-bottom, 0px)' }}
    >
      <div className="flex items-center justify-around h-[64px]">
        {TABS.map((tab) => {
          const active = screen === tab.tab
          return (
            <button
              key={tab.id}
              onClick={() => setScreen(tab.tab)}
              className={cn(
                'flex flex-col items-center justify-center gap-[3px] flex-1 h-full relative transition-all duration-150 active:scale-90',
              )}
              style={{ color: active ? 'var(--sn-accent)' : 'var(--sn-muted)' }}
              aria-label={tab.label}
              aria-current={active ? 'page' : undefined}
            >
              {/* Active pill indicator */}
              {active && (
                <span
                  className="absolute top-[10px] w-[36px] h-[28px] rounded-full opacity-15"
                  style={{ background: 'var(--sn-accent)' }}
                  aria-hidden="true"
                />
              )}
              <span className="relative z-10">{tab.icon(active)}</span>
              <span
                className="relative z-10 text-[10px] font-bold tracking-tight"
                style={{ fontFamily: 'Manrope, sans-serif' }}
              >
                {tab.label}
              </span>
            </button>
          )
        })}
      </div>
    </nav>
  )
}
