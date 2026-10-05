import { streamText, generateText, tool } from 'ai';
import { openai } from '@ai-sdk/openai';
import { groq } from '@ai-sdk/groq';
import { z } from 'zod';

export const runtime = 'nodejs';

// Define tools for agentic AI
const searchDocumentsTool = tool({
  description: 'Rechercher des documents dans la base de données de l\'utilisateur',
  parameters: z.object({
    query: z.string().describe('La requête de recherche'),
    subject: z.string().optional().describe('La matière spécifique (optionnel)'),
  }),
  // @ts-ignore - Tool execute type mismatch in AI SDK
  execute: async ({ query, subject }: { query: string; subject?: string }) => {
    // This would connect to your document database
    // For now, return a mock response
    return {
      results: [
        { title: 'Cours d\'introduction', subject: subject || 'Général', type: 'Cours' },
        { title: 'Exercices pratiques', subject: subject || 'Général', type: 'TD' },
      ],
      total: 2,
    };
  },
});

const createQuizTool = tool({
  description: 'Créer un quiz basé sur un sujet ou des documents',
  parameters: z.object({
    topic: z.string().describe('Le sujet du quiz'),
    questionCount: z.number().default(5).describe('Nombre de questions'),
  }),
  // @ts-ignore - Tool execute type mismatch in AI SDK
  execute: async ({ topic, questionCount }: { topic: string; questionCount: number }) => {
    // This would call the quiz generation endpoint
    return {
      success: true,
      message: `Quiz de ${questionCount} questions sur "${topic}" créé avec succès`,
    };
  },
});

export async function POST(req: Request) {
  const { messages } = await req.json();

  const result = streamText({
    model: groq('openai/gpt-oss-20b'),
    system: `Tu es NestIA, un assistant d'étude général pour les étudiants universitaires. 
Tu aides à expliquer des cours, résumer des documents, créer des quiz, et planifier les révisions.
Réponds toujours en français avec un ton encourageant et pédagogique.

Tu as accès à des outils pour:
- Rechercher des documents dans la base de données
- Créer des quiz automatiquement

Utilise ces outils quand c'est pertinent pour aider l'utilisateur.

IMPORTANT: Pour les tableaux, utilise le format Markdown avec des pipes (|). Exemple:
|| Concept | Définition | Exemple |
||---------|------------|---------|
|| Terme 1 | Définition 1 | Exemple 1 |
|| Terme 2 | Définition 2 | Exemple 2 |

Utilise le Markdown pour:
- Les tableaux (format standard avec |)
- Le texte en gras (**texte**)
- Les listes (puces ou numérotées)
- Les blocs de code (\`\`\`)
- Les titres (##, ###)

Sois concis et va droit au point tout en étant complet.`,
    messages,
    tools: {
      searchDocuments: searchDocumentsTool,
      createQuiz: createQuizTool,
    },
  });

  return result.toUIMessageStreamResponse();
}

export async function GET(req: Request) {
  const { searchParams } = new URL(req.url);
  const topic = searchParams.get('_topic');
  const action = searchParams.get('action');
  const questionCount = parseInt(searchParams.get('count') || '5');

  if (action === 'quiz' && topic) {
    const result = await generateText({
      model: groq('openai/gpt-oss-20b'),
      prompt: `Génère un quiz de ${questionCount} questions à choix multiples sur le sujet: "${topic}".
      
      Réponds UNIQUEMENT en format JSON valide avec cette structure exacte:
      {
        "title": "Titre du quiz",
        "subject": "${topic}",
        "questions": [
          {
            "question": "Question 1",
            "options": ["Option A", "Option B", "Option C", "Option D"],
            "correctIndex": 0,
            "explanation": "Explication de pourquoi cette réponse est correcte"
          }
        ]
      }
      
      Assure-toi que:
      - correctIndex est entre 0 et 3 (index de la bonne réponse)
      - Les questions sont pertinentes et éducatives
      - Les explications sont claires et utiles
      - Le JSON est valide et complet`,
    });

    try {
      const quizData = JSON.parse(result.text);
      return Response.json(quizData);
    } catch (error) {
      return new Response('Failed to parse quiz JSON', { status: 500 });
    }
  }

  if (action === 'summarize' && topic) {
    const result = await generateText({
      model: groq('openai/gpt-oss-20b'),
      prompt: `Résume le texte suivant de manière structurée et éducative: "${topic}"
      
      Réponds UNIQUEMENT en format JSON valide avec cette structure exacte:
      {
        "title": "Titre du résumé",
        "mainPoints": [
          "Point clé 1",
          "Point clé 2",
          "Point clé 3"
        ],
        "keyConcepts": [
          {
            "concept": "Nom du concept",
            "definition": "Définition concise",
            "example": "Exemple pratique"
          }
        ],
        "summary": "Résumé en 2-3 phrases"
      }
      
      Assure-toi que:
      - Les points sont clairs et concis
      - Les concepts sont bien définis
      - Le JSON est valide et complet`,
    });

    try {
      const summaryData = JSON.parse(result.text);
      return Response.json(summaryData);
    } catch (error) {
      return new Response('Failed to parse summary JSON', { status: 500 });
    }
  }

  if (action === 'plan' && topic) {
    const result = await generateText({
      model: groq('openai/gpt-oss-20b'),
      prompt: `Crée un plan de révision structuré pour le sujet: "${topic}"
      
      Réponds UNIQUEMENT en format JSON valide avec cette structure exacte:
      {
        "title": "Titre du plan de révision",
        "totalWeeks": 4,
        "milestones": [
          {
            "week": 1,
            "title": "Semaine 1 - Fondamentaux",
            "topics": ["Sujet 1", "Sujet 2", "Sujet 3"],
            "tasks": ["Tâche 1", "Tâche 2"],
            "estimatedHours": 5
          }
        ],
        "dailySchedule": {
          "monday": "2h - Lecture et notes",
          "tuesday": "1h - Exercices",
          "wednesday": "2h - Révision",
          "thursday": "1h - Quiz",
          "friday": "2h - Synthèse",
          "saturday": "1h - Récapitulatif",
          "sunday": "Repos"
        },
        "tips": ["Conseil 1", "Conseil 2"]
      }
      
      Assure-toi que:
      - Le plan est réaliste et progressif
      - Les estimations de temps sont raisonnables
      - Les conseils sont pratiques
      - Le JSON est valide et complet`,
    });

    try {
      const planData = JSON.parse(result.text);
      return Response.json(planData);
    } catch (error) {
      return new Response('Failed to plan JSON', { status: 500 });
    }
  }

  return new Response('Invalid action or missing topic', { status: 400 });
}
