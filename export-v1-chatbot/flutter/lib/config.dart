/// Configuration globale de l'application.
class AppConfig {
  /// URL de base de ton backend (le projet Next.js déployé sur Vercel).
  ///
  /// En développement local avec un émulateur Android, `localhost` ne pointe
  /// PAS vers ta machine : utilise `http://10.0.2.2:3000`.
  /// Sur un appareil physique, utilise l'IP locale de ta machine (ex.
  /// `http://192.168.1.20:3000`) ou l'URL de production.
  ///
  /// En production, remplace par ton domaine Vercel, par ex. :
  ///   static const String apiBaseUrl = 'https://studynest.vercel.app';
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://studynest.vercel.app',
  );
}
