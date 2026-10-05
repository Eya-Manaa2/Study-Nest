# StudyNest — Ajout du chatbot IA (v1, sans monétisation)

Ce dossier contient **uniquement** les fichiers à ajouter/remplacer pour brancher
l'assistant IA « NestIA » sur l'app Flutter StudyNest + son backend Next.js.
La monétisation (Premium, quotas, paywall) a été volontairement retirée de cette version.

---

## Arborescence du dossier d'export

```
export-v1-chatbot/
├── PROMPT_INTEGRATION.md              ← ce fichier
├── app/
│   └── api/
│       └── chat/
│           ├── route.ts               ← endpoint streaming (aperçu web)
│           └── plain/
│               └── route.ts           ← endpoint JSON simple (consommé par Flutter)
└── flutter/
    └── lib/
        ├── config.dart                ← URL de base de l'API
        ├── main.dart                  ← point d'entrée (version nettoyée, sans billing)
        └── screens/
            ├── assistant_screen.dart  ← écran de chat (version nettoyée, sans quota/premium)
            └── main_scaffold.dart     ← nav bar avec l'onglet « Assistant » ajouté
```

---

## Où placer chaque fichier dans TON projet

Remplace/ajoute en respectant exactement ces chemins (relatifs à la racine de ton repo) :

| Fichier de l'export | Destination dans ton projet | Action |
|---|---|---|
| `app/api/chat/route.ts` | `app/api/chat/route.ts` | Ajouter |
| `app/api/chat/plain/route.ts` | `app/api/chat/plain/route.ts` | Ajouter |
| `flutter/lib/config.dart` | `flutter/lib/config.dart` | Ajouter |
| `flutter/lib/main.dart` | `flutter/lib/main.dart` | Remplacer |
| `flutter/lib/screens/assistant_screen.dart` | `flutter/lib/screens/assistant_screen.dart` | Ajouter |
| `flutter/lib/screens/main_scaffold.dart` | `flutter/lib/screens/main_scaffold.dart` | Remplacer |

> Si ta structure Flutter diffère (ex. `lib/src/...`), adapte les chemins d'`import`
> en conséquence dans les 4 fichiers Dart.

---

## Dépendances à installer

**Backend Next.js** (à la racine du projet web) :
```bash
pnpm add ai @ai-sdk/react
```

**Flutter** — vérifie que `pubspec.yaml` contient bien, sous `dependencies:` :
```yaml
  http: ^1.2.0
  flutter_riverpod: ^2.5.0
```
puis `flutter pub get`.

---

## Configuration requise

### 1. Clé du service IA (backend)
Les deux routes utilisent le **Vercel AI Gateway** via l'AI SDK avec le modèle
`openai/gpt-4.1-mini`. En production Vercel, l'authentification est automatique.
En local, définis la variable d'environnement :
```
AI_GATEWAY_API_KEY=<ta_clé>
```
> Le compte AI Gateway doit avoir une carte enregistrée pour débloquer les crédits
> (exigence anti-fraude de Vercel). Rien n'est débité dans le quota gratuit.

### 2. URL de l'API (Flutter)
Ouvre `flutter/lib/config.dart` et remplace la valeur de `apiBaseUrl` par l'URL
de TON déploiement Vercel, par ex. :
```dart
static const String apiBaseUrl = 'https://mon-app.vercel.app';
```
> Pour tester en local sur un émulateur Android, l'hôte de la machine est
> `http://10.0.2.2:3000` (et non `localhost`).

---

## Ce que fait chaque fichier

### `app/api/chat/route.ts`  (streaming — aperçu web)
- Route POST qui reçoit `{ messages }` (format UI de l'AI SDK).
- Appelle `streamText` avec un *system prompt* d'« assistant d'étude général »
  (explique des cours, résume, crée des quiz, aide à planifier les révisions).
- Renvoie un flux via `result.toUIMessageStreamResponse()` — consommé par `useChat`
  dans l'aperçu web React/Next.js.

### `app/api/chat/plain/route.ts`  (JSON — Flutter)
- Route POST qui reçoit `{ messages: [{ role, content }] }`.
- Appelle `generateText` (non-streaming) avec le même system prompt.
- Renvoie `{ text }` en JSON simple — facile à consommer côté Flutter sans parser
  un flux SSE.

### `flutter/lib/config.dart`
- Contient `AppConfig.apiBaseUrl`, l'unique endroit où changer l'URL du backend.

### `flutter/lib/main.dart`  (nettoyé)
- Point d'entrée de l'app. **Version sans** l'initialisation de la facturation
  (`BillingService`) présente dans la version monétisée.

### `flutter/lib/screens/assistant_screen.dart`  (nettoyé)
- Écran de chat complet : bulles utilisateur/assistant, état vide avec suggestions,
  indicateur « écrit… », bannière d'erreur + bouton « Réessayer ».
- Envoie l'historique à `POST {apiBaseUrl}/api/chat/plain` et affiche la réponse.
- **Version sans** quota quotidien, compteur de messages, ni renvoi vers le paywall.

### `flutter/lib/screens/main_scaffold.dart`
- Barre de navigation de l'app avec l'onglet **« Assistant »** (icône `psychology`)
  ajouté, pointant vers `AssistantScreen`.

---

## Étapes pour l'assistant IA (à exécuter dans l'ordre)

1. Copier les 6 fichiers aux chemins indiqués dans le tableau ci-dessus.
2. Installer les dépendances backend (`pnpm add ai @ai-sdk/react`) et Flutter
   (`http`, `flutter_riverpod` si absents) puis `flutter pub get`.
3. Renseigner `AI_GATEWAY_API_KEY` côté backend et déployer le projet Next.js.
4. Mettre la vraie URL de déploiement dans `flutter/lib/config.dart`.
5. `flutter analyze` → corriger toute erreur d'import liée à la structure du projet
   (adapter les chemins relatifs si nécessaire), **sans** changer la logique.
6. `flutter run` → vérifier : l'onglet Assistant s'affiche, l'envoi d'un message
   renvoie une réponse de l'IA, la bannière d'erreur apparaît si le backend est
   injoignable.

## Vérifications importantes
- `assistant_screen.dart` et `main_scaffold.dart` référencent `../app_provider.dart`
  et `../themes.dart` (le provider Riverpod et le modèle de thème existants). Ces
  fichiers doivent déjà exister dans ton projet — ils ne sont PAS inclus ici car
  inchangés. Si leurs chemins diffèrent, corriger les imports.
- Ne pas committer `AI_GATEWAY_API_KEY` dans le dépôt.
