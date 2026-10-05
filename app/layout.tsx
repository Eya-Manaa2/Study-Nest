import type { Metadata, Viewport } from 'next'
import {
  Fraunces,
  Manrope,
  Playfair_Display,
  Quicksand,
  EB_Garamond,
  Comfortaa,
  Space_Mono,
} from 'next/font/google'
import './globals.css'

const _manrope = Manrope({ subsets: ['latin'], variable: '--loaded-manrope' })
const _fraunces = Fraunces({ subsets: ['latin'], variable: '--loaded-fraunces', axes: ['opsz'] })
const _playfair = Playfair_Display({ subsets: ['latin'], variable: '--loaded-playfair' })
const _quicksand = Quicksand({ subsets: ['latin'], variable: '--loaded-quicksand' })
const _garamond = EB_Garamond({ subsets: ['latin'], variable: '--loaded-garamond' })
const _comfortaa = Comfortaa({ subsets: ['latin'], variable: '--loaded-comfortaa' })
const _spaceMono = Space_Mono({ subsets: ['latin'], weight: ['400', '700'], variable: '--loaded-spacemono' })

export const metadata: Metadata = {
  title: 'StudyNest — Ton espace. Tes études. Tout organisé.',
  description:
    "StudyNest est l'espace numérique personnel de l'étudiant. Organise tes cours, TD, TP et notes par semestre et matière avec des thèmes visuels immersifs.",
  generator: 'v0.app',
}

export const viewport: Viewport = {
  themeColor: '#FBF6F1',
  width: 'device-width',
  initialScale: 1,
  maximumScale: 1,
  userScalable: false,
}

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode
}>) {
  return (
    <html
      lang="fr"
      className={`${_manrope.variable} ${_fraunces.variable} ${_playfair.variable} ${_quicksand.variable} ${_garamond.variable} ${_comfortaa.variable} ${_spaceMono.variable}`}
    >
      <body className="antialiased font-sans overflow-hidden">{children}</body>
    </html>
  )
}
