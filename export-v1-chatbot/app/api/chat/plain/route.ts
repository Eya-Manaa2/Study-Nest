import { generateText, type ModelMessage } from "ai"

// StudyNest — Assistant d'étude (endpoint JSON simple)
// Utilisé par l'app Flutter : reçoit { messages: [{role, content}] } et
// renvoie { text } en une seule réponse (pas de streaming), plus simple à
// consommer depuis un client mobile natif.
export const maxDuration = 30

const SYSTEM_PROMPT = `Tu es NestIA, l'assistant d'étude intégré à l'application StudyNest.

Ton rôle : aider les étudiants à mieux apprendre et s'organiser. Tu peux :
- expliquer des concepts de cours de façon claire et progressive ;
- résumer des textes ou des notions ;
- créer des fiches de révision, des plans et des quiz ;
- proposer des méthodes de travail et de planification.

Règles :
- Réponds toujours en français, sur un ton bienveillant, clair et encourageant.
- Structure tes réponses (titres courts, listes, étapes) quand c'est utile.
- Adapte le niveau de détail à la question ; reste concis par défaut.
- Si une question sort du champ scolaire/études, recentre poliment vers l'aide aux études.
- N'invente jamais de faits ; si tu n'es pas sûr, dis-le et propose comment vérifier.`

type IncomingMessage = { role: "user" | "assistant" | "system"; content: string }

export async function POST(req: Request) {
  try {
    const { messages }: { messages: IncomingMessage[] } = await req.json()

    if (!Array.isArray(messages) || messages.length === 0) {
      return Response.json({ error: "messages requis" }, { status: 400 })
    }

    const modelMessages: ModelMessage[] = messages
      .filter((m) => m.role === "user" || m.role === "assistant")
      .map((m) => ({ role: m.role, content: m.content }) as ModelMessage)

    const { text } = await generateText({
      model: "openai/gpt-4.1-mini",
      system: SYSTEM_PROMPT,
      messages: modelMessages,
    })

    return Response.json({ text })
  } catch (err) {
    console.error("[v0] /api/chat/plain error:", err)
    return Response.json({ error: "Erreur de génération" }, { status: 500 })
  }
}
