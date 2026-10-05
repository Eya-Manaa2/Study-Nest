# Guide de configuration Firebase pour StudyNest

## Étapes préliminaires

1. **Créer un projet Firebase**
   - Allez sur [console.firebase.google.com](https://console.firebase.google.com/)
   - Cliquez sur "Ajouter un projet"
   - Nommez le projet "StudyNest"
   - Suivez les étapes de configuration

## Configuration Android

### 1. Enregistrer l'application Android

- Dans la console Firebase, cliquez sur l'icône Android
- Package name: `com.studynest.studynest_app`
- App nickname: `StudyNest Android`
- Debug signing certificate SHA-1: (optionnel pour le développement)

### 2. Télécharger google-services.json

- Après l'enregistrement, téléchargez le fichier `google-services.json`
- Placez-le dans: `flutter/android/app/google-services.json`

### 3. Vérifier la configuration

Les fichiers suivants sont déjà configurés:
- `android/build.gradle.kts` - Contient le plugin google-services
- `android/app/build.gradle.kts` - Applique le plugin google-services
- `android/app/src/main/AndroidManifest.xml` - Contient les permissions nécessaires

## Configuration iOS

### 1. Enregistrer l'application iOS

- Dans la console Firebase, cliquez sur l'icône iOS
- Bundle ID: `com.studynest.studynest_app`
- App nickname: `StudyNest iOS`
- App Store ID: (optionnel)

### 2. Télécharger GoogleService-Info.plist

- Après l'enregistrement, téléchargez le fichier `GoogleService-Info.plist`
- Placez-le dans: `flutter/ios/Runner/GoogleService-Info.plist`

### 3. Ajouter dans Xcode

- Ouvrez le projet iOS avec Xcode: `open ios/Runner.xcworkspace`
- Glissez le fichier `GoogleService-Info.plist` dans le projet
- Assurez-vous qu'il est ajouté au target "Runner"

### 4. Vérifier la configuration

Le fichier `ios/Runner/Info.plist` contient déjà les permissions nécessaires:
- NSPhotoLibraryUsageDescription
- NSCameraUsageDescription
- NSPhotoLibraryAddUsageDescription
- NSDocumentsFolderUsageDescription

## Configuration Firebase Console

### Activer les services

1. **Authentication**
   - Activez Email/Password
   - Activez Google Sign-in
   - Configurez les domaines autorisés

2. **Firestore Database**
   - Créez une base de données
   - Choisissez le mode "Production" ou "Test"
   - Configurez les règles de sécurité

3. **Cloud Storage**
   - Activez le storage
   - Configurez les règles de sécurité
   - Configurez CORS si nécessaire

### Règles de sécurité recommandées

#### Firestore
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

#### Storage
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Test de l'application

Après avoir ajouté les fichiers de configuration:

```bash
cd flutter
flutter pub get
flutter run
```

## Dépannage

### Erreur "FirebaseApp not initialized"
- Vérifiez que `google-services.json` ou `GoogleService-Info.plist` sont bien placés
- Vérifiez que Firebase.initializeApp() est appelé dans main()

### Erreur d'authentification Google
- Vérifiez que Google Sign-in est activé dans la console Firebase
- Vérifiez que le SHA-1 fingerprint est ajouté (pour Android release)

### Erreur Firestore/Storage
- Vérifiez que les services sont activés dans la console
- Vérifiez les règles de sécurité
- Vérifiez que l'utilisateur est authentifié

## Prochaines étapes

Une fois Firebase configuré:
1. Tester l'authentification email/password
2. Tester l'authentification Google
3. Tester la création de matières dans Firestore
4. Tester l'upload de fichiers dans Storage
5. Configurer les règles de sécurité pour la production
