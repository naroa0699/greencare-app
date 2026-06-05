const express = require("express");
const cors = require("cors");
require("dotenv").config();
const { GoogleGenerativeAI } = require("@google/generative-ai");

const app = express();
app.use(cors());
app.use(express.json());

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

app.post("/api/chat", async (req, res) => {
  const { messages } = req.body;

  if (!messages || messages.length === 0) {
    return res.status(400).json({ error: "No messages provided" });
  }

  try {
    const model = genAI.getGenerativeModel({
      model: "gemini-2.5-flash",
      systemInstruction: `Eres GreenBot, un experto botanico amigable integrado en GreenCare.
      Tu unico rol es ayudar con el cuidado de plantas domesticas.
      Responde siempre en espanol, de forma clara, practica y cercana.
      Si te preguntan algo ajeno a plantas o jardineria, redirige
      amablemente la conversacion al cuidado de plantas.`,
    });

    const allButLast = messages.slice(0, -1).map((m) => ({
      role: m.role === "assistant" ? "model" : "user",
      parts: [{ text: m.content }],
    }));

    while (allButLast.length > 0 && allButLast[0].role === "model") {
      allButLast.shift();
    }

    const chat = model.startChat({ history: allButLast });
    const lastMessage = messages[messages.length - 1].content;
    const result = await chat.sendMessage(lastMessage);

    res.json({ reply: result.response.text() });
  } catch (error) {
    console.error("Gemini error:", error);
    res.status(500).json({ error: error.message });
  }
});

app.post("/api/plant-care", async (req, res) => {
  const { plantName } = req.body;

  try {
    const model = genAI.getGenerativeModel({
      model: "gemini-2.5-flash",
      systemInstruction: `Eres un experto botanico. Responde SOLO en formato JSON valido, sin texto adicional ni backticks.`,
    });

    const result = await model.generateContent(
      `Dame los datos de cuidado de la planta "${plantName}" en este formato JSON exacto:
      {
        "watering": "Frequent|Average|Minimum|None",
        "sunlight": "full sun|part shade|full shade",
        "cycle": "Annual|Biennial|Perennial|Biannual"
      }
      Solo responde con el JSON, nada mas.`,
    );

    const text = result.response.text().trim();
    const clean = text.replace(/```json|```/g, "").trim();
    const data = JSON.parse(clean);
    res.json(data);
  } catch (error) {
    console.error("Plant care error:", error);
    res.status(500).json({ error: error.message });
  }
});

app.post("/api/translate", async (req, res) => {
  const { text } = req.body;
  try {
    const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });
    const result = await model.generateContent(
      `Translate this plant name to English for a botanical API search. 
       Return ONLY the English translation, nothing else: "${text}"`,
    );
    const translation = result.response.text().trim();
    res.json({ translation });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// --- NUEVO: datos meteorologicos via Open-Meteo (gratis, sin API key) ---
// Se usa para ajustar la frecuencia de riego segun el tiempo en la
// ubicacion de cada planta. Requiere Node 18+ (fetch global).
app.post("/api/weather", async (req, res) => {
  const { lat, lon } = req.body;

  if (lat == null || lon == null) {
    return res.status(400).json({ error: "lat y lon son obligatorios" });
  }

  try {
    const url =
      `https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}` +
      `&current=temperature_2m,relative_humidity_2m` +
      `&daily=temperature_2m_max,temperature_2m_min,precipitation_sum` +
      `&timezone=auto&forecast_days=1`;

    const response = await fetch(url);
    if (!response.ok) {
      throw new Error(`Open-Meteo respondio ${response.status}`);
    }
    const data = await response.json();

    res.json({
      maxTemp: data.daily.temperature_2m_max[0],
      minTemp: data.daily.temperature_2m_min[0],
      humidity: data.current.relative_humidity_2m,
      precipitationMm: data.daily.precipitation_sum[0],
    });
  } catch (error) {
    console.error("Weather error:", error);
    res.status(500).json({ error: error.message });
  }
});

app.get("/health", (req, res) => res.json({ status: "ok" }));

app.listen(process.env.PORT, () => {
  console.log(`GreenCare backend corriendo en puerto ${process.env.PORT}`);
});
