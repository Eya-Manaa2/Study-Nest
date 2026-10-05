'use client'

import Image from 'next/image'
import { useStudyNest } from '@/lib/studynest-store'

export function AuthScreen() {
  const { setScreen } = useStudyNest()

  return (
    <section
      className="flex-1 flex flex-col items-center justify-between px-7 pb-10 pt-[10vh] sn-screen-enter overflow-y-auto"
      style={{ scrollbarWidth: 'none' }}
      aria-label="Authentification"
    >
      {/* Top spacer */}
      <div />

      {/* Center content */}
      <div className="flex flex-col items-center gap-4 text-center w-full max-w-[360px]">
        {/* Hero blob */}
        <div
          className="w-[140px] h-[140px] rounded-[38px] flex items-center justify-center mb-2 relative"
          style={{ background: 'var(--sn-surface2)', boxShadow: '0 20px 50px -10px var(--sn-shadow)' }}
          aria-hidden="true"
        >
          <Image
            src="/logo.png"
            alt="StudyNest logo"
            fill
            className="object-contain p-3"
            priority
          />
        </div>

        <h1
          className="text-[36px] font-bold leading-none"
          style={{ fontFamily: 'var(--sn-font-display)', letterSpacing: '-0.5px' }}
        >
          Study<span style={{ color: 'var(--sn-accent)' }}>Nest</span>
        </h1>

        <p
          className="text-[16px] leading-relaxed max-w-[270px]"
          style={{ color: 'var(--sn-muted)' }}
        >
          Ton espace, tes études, tout organisé.
        </p>

        {/* Auth buttons */}
        <div className="w-full flex flex-col gap-3 mt-6">
          <button
            onClick={() => setScreen('home')}
            className="w-full flex items-center justify-center gap-3 rounded-[16px] py-[15px] px-5 text-[15px] font-bold text-white transition-all duration-150 active:scale-[0.97]"
            style={{
              background: 'var(--sn-accent)',
              boxShadow: '0 8px 24px -6px var(--sn-shadow)',
            }}
          >
            <svg width="18" height="18" viewBox="0 0 48 48" aria-hidden="true">
              <path fill="#fff" d="M43.6 20.5H42V20H24v8h11.3C33.7 32.9 29.3 36 24 36c-6.6 0-12-5.4-12-12s5.4-12 12-12c3.1 0 5.9 1.2 8 3.1l5.7-5.7C34.6 6.3 29.6 4 24 4 12.9 4 4 12.9 4 24s8.9 20 20 20 20-8.9 20-20c0-1.2-.1-2.3-.4-3.5z"/>
            </svg>
            Continuer avec Google
          </button>

          <button
            onClick={() => setScreen('home')}
            className="w-full rounded-[16px] py-[15px] px-5 text-[15px] font-bold transition-all duration-150 active:scale-[0.97] border"
            style={{
              background: 'var(--sn-surface)',
              color: 'var(--sn-text)',
              borderColor: 'var(--sn-line)',
            }}
          >
            Continuer avec e-mail
          </button>
        </div>
      </div>

      {/* Bottom fine print */}
      <p className="text-[12px] text-center leading-relaxed px-4 mt-8" style={{ color: 'var(--sn-muted)' }}>
        En continuant, tu acceptes nos{' '}
        <span className="font-bold" style={{ color: 'var(--sn-accent)' }}>Conditions</span>{' '}
        et notre{' '}
        <span className="font-bold" style={{ color: 'var(--sn-accent)' }}>Politique de confidentialité</span>.
      </p>
    </section>
  )
}
