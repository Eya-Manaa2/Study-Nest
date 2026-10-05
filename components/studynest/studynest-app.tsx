'use client'

import { useStudyNest, getTheme } from '@/lib/studynest-store'
import { TabBar } from './tab-bar'
import { ToastProvider } from './toast'
import { AuthScreen } from './screens/auth-screen'
import { HomeScreen } from './screens/home-screen'
import { SubjectsScreen } from './screens/subjects-screen'
import { SubjectDetailScreen } from './screens/subject-detail-screen'
import { SearchScreen } from './screens/search-screen'
import { FavoritesScreen } from './screens/favorites-screen'
import { NotesScreen } from './screens/notes-screen'
import { ProfileScreen } from './screens/profile-screen'

const TAB_SCREENS = ['home', 'subjects', 'search', 'favorites', 'profile']

function AppContent() {
  const { screen } = useStudyNest()
  const showTabBar = TAB_SCREENS.includes(screen)

  return (
    <ToastProvider>
      {screen === 'auth' && <AuthScreen />}
      {screen === 'home' && <HomeScreen />}
      {screen === 'subjects' && <SubjectsScreen />}
      {screen === 'subject-detail' && <SubjectDetailScreen />}
      {screen === 'search' && <SearchScreen />}
      {screen === 'favorites' && <FavoritesScreen />}
      {screen === 'notes' && <NotesScreen />}
      {screen === 'profile' && <ProfileScreen />}
      {showTabBar && <TabBar />}
    </ToastProvider>
  )
}

export function StudyNestApp() {
  const { activeTheme } = useStudyNest()
  const theme = getTheme(activeTheme)

  return (
    <div
      className={`w-full h-[100dvh] flex flex-col relative overflow-hidden transition-colors duration-300 ${theme.cssClass}`}
      style={{ backgroundColor: 'var(--sn-bg)', color: 'var(--sn-text)', fontFamily: 'Manrope, sans-serif' }}
    >
      {/* Flutter-style status bar */}
      <div
        className="w-full flex-none h-[env(safe-area-inset-top,0px)]"
        style={{ background: 'var(--sn-bg)' }}
      />
      <AppContent />
    </div>
  )
}
