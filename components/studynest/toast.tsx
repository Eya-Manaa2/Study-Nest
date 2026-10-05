'use client'

import { useState, useCallback } from 'react'
import { createContext, useContext } from 'react'

interface ToastContextType {
  showToast: (msg: string) => void
}

const ToastContext = createContext<ToastContextType>({ showToast: () => {} })

export function useToast() {
  return useContext(ToastContext)
}

export function ToastProvider({ children }: { children: React.ReactNode }) {
  const [message, setMessage] = useState('')
  const [visible, setVisible] = useState(false)
  const [timer, setTimer] = useState<ReturnType<typeof setTimeout> | null>(null)

  const showToast = useCallback((msg: string) => {
    if (timer) clearTimeout(timer)
    setMessage(msg)
    setVisible(true)
    const t = setTimeout(() => setVisible(false), 2400)
    setTimer(t)
  }, [timer])

  return (
    <ToastContext.Provider value={{ showToast }}>
      {children}
      {/* Toast sits above the bottom tab bar */}
      <div
        className="absolute left-4 right-4 z-[90] pointer-events-none transition-all duration-300"
        style={{
          bottom: 'calc(64px + env(safe-area-inset-bottom, 0px) + 12px)',
          opacity: visible ? 1 : 0,
          transform: `translateY(${visible ? '0' : '16px'})`,
        }}
        role="status"
        aria-live="polite"
      >
        <div
          className="rounded-[16px] px-4 py-3.5 text-[13px] font-bold text-white flex items-center gap-2.5 shadow-xl"
          style={{ background: 'var(--sn-text)' }}
        >
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" className="w-4 h-4 flex-none opacity-80" aria-hidden="true">
            <path d="M20 6L9 17l-5-5" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
          {message}
        </div>
      </div>
    </ToastContext.Provider>
  )
}
