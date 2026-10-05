# StudyNest

StudyNest is a cross-platform study organizer with a web app and a Flutter mobile app. It helps students organize subjects, notes, study documents, favorites, and revision activities, with an AI assistant for study support.

## Features

- Organize subjects, course documents, notes, and favorites
- Search and browse study material
- Upload and manage documents in the Flutter app
- Use an AI assistant for study questions, summaries, quizzes, and revision plans
- Use speech input in the Flutter assistant
- Authenticate and sync mobile data with Firebase Authentication, Cloud Firestore, and Cloud Storage

## AI scope

The current assistant calls Groq from server-side API routes. The web API supports chat plus generated quizzes, summaries, and revision plans.

This repository does **not** currently implement a RAG pipeline, embeddings, or a vector database. The document-search and quiz tools in the web chat route are placeholders and do not retrieve a user's files or persist generated quizzes. Describe those capabilities as future work, not as shipped features.

Set `GROQ_API_KEY` on the server. Do not expose it in client-side code or commit it to Git.

## Technology

- Web: Next.js 16, React 19, TypeScript
- Mobile: Flutter, Dart, Riverpod
- Backend services: Firebase Authentication, Cloud Firestore, Firebase Storage
- AI: Groq API through the Vercel AI SDK

## Run the web app

Requirements: Node.js 20.9 or newer and npm.

```bash
npm install
```

Set the server-side Groq key, then start the development server:

```powershell
$env:GROQ_API_KEY="your-groq-api-key"
npm run dev
```

Open `http://localhost:3000`.

## Run the Flutter app

Requirements: Flutter SDK and an Android or iOS development environment.

```bash
cd flutter
flutter pub get
flutter run
```

The mobile app needs a reachable StudyNest API URL. Update `AppConfig.apiBaseUrl` in `flutter/lib/config.dart` for your local network or deployment. Firebase must also be configured for the target platform; Android uses `flutter/android/app/google-services.json`, while iOS needs its own `GoogleService-Info.plist`.

## Repository layout

```text
app/                 Next.js web app and API routes
components/studynest/ Web app screens and navigation
flutter/             Flutter mobile app
lib/                 Shared web utilities and stores
```

## Configuration notes

- Keep `GROQ_API_KEY` on the server only.
- Configure Firebase Authentication, Firestore, and Storage rules in the Firebase console before using real accounts or files.
- The Flutter API base URL is currently a local development value and should be changed for each environment.
