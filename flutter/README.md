# StudyNest — App mobile Flutter

> Ton espace. Tes études. Tout organisé.

Code source Dart complet d'une app mobile Flutter native (Android + iOS), prête à builder et à publier sur le **Google Play Store**.

---

## 1. Prérequis (sur ta machine, pas dans v0)

- **Flutter SDK** 3.3+ : https://docs.flutter.dev/get-started/install
- **Android Studio** (avec Android SDK + un émulateur ou un téléphone en mode développeur)
- Vérifie l'installation : `flutter doctor`

> Important : v0 est un environnement web et ne peut **pas** compiler Flutter. Tout ce qui suit se fait en local sur ton ordinateur.

---

## 2. Créer le projet et importer le code

Le dossier `flutter/` contient le code applicatif (`lib/`, `pubspec.yaml`, `assets/`) mais pas les dossiers de plateforme (`android/`, `ios/`) qui sont générés par Flutter. Marche à suivre :

```bash
# 1. Génère un projet Flutter vierge avec les dossiers de plateforme
flutter create --org com.studynest --project-name studynest studynest_app

# 2. Remplace le code par celui fourni ici
cp -r flutter/lib studynest_app/
cp -r flutter/assets studynest_app/
cp flutter/pubspec.yaml studynest_app/
cp flutter/analysis_options.yaml studynest_app/

# 3. Installe les dépendances
cd studynest_app
flutter pub get

# 4. Lance en développement
flutter run
```

---

## 3. Structure du code

```
lib/
├── main.dart                  # Entrée, ProviderScope, gate d'authentification
├── models.dart                # Subject, StudyDocument, Note, DocType, AppThemeDef
├── seed_data.dart             # Données de démo (matières, documents, notes)
├── app_provider.dart          # State global Riverpod (favoris, notes, thème…)
├── themes.dart                # 10 thèmes + ThemeData Material 3
├── widgets/sn_card.dart       # Composants réutilisables (cartes, tuiles, chips)
└── screens/
    ├── auth_screen.dart
    ├── main_scaffold.dart     # Navigation par onglets en bas
    ├── home_screen.dart
    ├── subjects_screen.dart
    ├── subject_detail_screen.dart
    ├── search_screen.dart
    ├── favorites_screen.dart
    ├── notes_screen.dart
    └── profile_screen.dart
```

---

## 4. Publier sur le Play Store

### a. Icône & nom de l'app
- Icône : `flutter pub add flutter_launcher_icons` puis configure-la avec `assets/logo.png`.
- Nom affiché : `android/app/src/main/AndroidManifest.xml` → `android:label="StudyNest"`.

### b. Signer l'app (obligatoire pour le Play Store)

```bash
# Génère une clé de signature (garde-la précieusement, ne la perds jamais)
keytool -genkey -v -keystore ~/studynest-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias studynest
```

Crée `android/key.properties` :

```properties
storePassword=TON_MOT_DE_PASSE
keyPassword=TON_MOT_DE_PASSE
keyAlias=studynest
storeFile=/chemin/absolu/vers/studynest-key.jks
```

Puis configure `android/app/build.gradle` pour utiliser cette clé en `release` (voir doc officielle : https://docs.flutter.dev/deployment/android#signing-the-app).

### c. Construire l'App Bundle (.aab)

```bash
flutter build appbundle --release
```

Le fichier à uploader se trouve dans :
`build/app/outputs/bundle/release/app-release.aab`

### d. Mettre en ligne
1. Crée un compte développeur sur https://play.google.com/console (frais unique de 25 $).
2. Crée une nouvelle application, remplis la fiche (description, captures d'écran, politique de confidentialité).
3. Upload le fichier `app-release.aab`.
4. Soumets pour validation.

Guide officiel complet : https://docs.flutter.dev/deployment/android

---

## Notes

- Les données sont actuellement en mémoire (`seed_data.dart`) + `shared_preferences` pour le thème. Pour une vraie persistance multi-appareils, branche un backend (Firebase, Supabase, etc.).
- L'app est en Material 3 avec 10 thèmes commutables depuis l'écran Profil.
