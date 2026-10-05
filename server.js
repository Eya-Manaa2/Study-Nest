const express = require('express');
const cors = require('cors');
const fetch = require('node-fetch');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// Route pour l'assistant IA
app.post('/api/chat/plain', async (req, res) => {
  try {
    const { messages } = req.body;
    
    const response = await fetch('https://api.groq.com/openai/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${process.env.GROQ_API_KEY}`,
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: JSON.stringify({
        model: 'llama-3.1-8b-instant',
        messages: messages,
      }),
    });

    const data = await response.json();
    
    if (data.choices && data.choices[0]) {
      res.json({ text: data.choices[0].message.content });
    } else {
      res.status(500).json({ error: 'No response from AI' });
    }
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});
