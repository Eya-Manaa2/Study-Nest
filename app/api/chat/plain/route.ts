export const runtime = 'nodejs';

export async function POST(req: Request) {
  try {
    const { messages } = await req.json();

    const response = await fetch('https://api.groq.com/openai/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${process.env.GROQ_API_KEY}`,
      },
      body: JSON.stringify({
        model: 'openai/gpt-oss-20b',
        messages: [
          {
            role: 'system',
            content: `Tu es NestIA, un assistant d'étude général pour les étudiants universitaires. 
Tu aides à expliquer des cours, résumer des documents, créer des quiz, et planifier les révisions.
Réponds toujours en français avec un ton encourageant et pédagogique.
Sois concis et va droit au point tout en étant complet.`
          },
          ...messages
        ],
      }),
    });

    if (!response.ok) {
      const error = await response.text();
      console.error('Groq API error:', error);
      throw new Error('Groq API error');
    }

    const data = await response.json();
    return Response.json({ text: data.choices[0]?.message?.content || 'Réponse non disponible' }, {
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
      },
    });
  } catch (error: any) {
    console.error('Error:', error);
    return Response.json({ error: error.message }, { status: 500 });
  }
}
