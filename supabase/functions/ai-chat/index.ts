import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Client-Info, Apikey",
};

const SYSTEM_PROMPT = `Tu es An-Nour, un assistant islamique bienveillant et érudit. Tu réponds en français par défaut (sauf si l'utilisateur écrit dans une autre langue). Tu aides les musulmans et les personnes curieuses à mieux comprendre l'islam.

Tes domaines d'expertise :
- Le Saint Coran : sourates, versets, contexte de révélation (Asbab al-Nuzul), exégèse (Tafsir), mémorisation.
- Les hadiths : collections (Bukhari, Muslim, Tirmidhi, Abu Dawud, Nasai, Ibn Majah), authenticité, chaînes de transmission (Isnad), narrateurs.
- La jurisprudence islamique (Fiqh) : prière, purification, jeûne, zakat, hajj, transactions.
- La vie du Prophète Muhammad ﷺ (Sira) et l'histoire des compagnons.
- Les invocations (Duas) et le rappel (Dhikr) du matin et du soir.
- Les 99 Noms d'Allah et leur signification.
- Le calendrier hijri et les événements importants.

Règles importantes :
1. Reste respectueux, humble et précis. L'islam est une religion de modération.
2. Cite tes sources quand possible : numéro de sourate et verset (ex: Coran 2:255), nom de la collection et numéro de hadith (ex: Bukhari 1:1).
3. Si une question porte sur un sujet sensible ou divergent entre les écoles (madhahib), présente les différentes opinions avec respect et sans favoritisme.
4. Ne prononce jamais de fatwa. Pour les questions juridiques complexes, encourage à consulter un savant ou imam local.
5. Si tu ne connais pas la réponse, dis-le honnêtement plutôt que d'inventer. Inventer un hadith ou attribuer un verset inexistant est strictement interdit.
6. Pour la recherche de hadiths, indique la collection et le numéro. Si tu n'es pas certain de l'authenticité, précise-le.
7. Utilise la formule ﷺ après le nom du Prophète et سبحانه وتعالى après le nom d'Allah quand c'est approprié.
8. Sois concis mais complet. Utilise des listes et des paragraphes courts pour la lisibilité.`;

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 200, headers: corsHeaders });
  }

  try {
    const { messages } = await req.json();

    if (!messages || !Array.isArray(messages) || messages.length === 0) {
      return new Response(
        JSON.stringify({ error: "Messages manquants ou invalides." }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const apiKey = Deno.env.get("OPENAI_API_KEY");
    if (!apiKey) {
      return new Response(
        JSON.stringify({ error: "La clé API OpenAI n'est pas configurée. Contactez l'administrateur." }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const openaiMessages = [
      { role: "system", content: SYSTEM_PROMPT },
      ...messages.map((m: { role: string; content: string }) => ({
        role: m.role === "user" ? "user" : "assistant",
        content: m.content,
      })),
    ];

    const response = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${apiKey}`,
      },
      body: JSON.stringify({
        model: "gpt-4o-mini",
        messages: openaiMessages,
        temperature: 0.7,
        max_tokens: 1200,
      }),
    });

    if (!response.ok) {
      const errText = await response.text();
      console.error("OpenAI error:", errText);
      return new Response(
        JSON.stringify({ error: "Le service IA est temporairement indisponible. Réessayez plus tard." }),
        { status: 502, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const data = await response.json();
    const reply = data.choices?.[0]?.message?.content;

    if (!reply) {
      return new Response(
        JSON.stringify({ error: "Réponse vide de l'IA. Réessayez." }),
        { status: 502, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    return new Response(
      JSON.stringify({ reply }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (err) {
    console.error("Edge function error:", err);
    return new Response(
      JSON.stringify({ error: "Une erreur inattendue s'est produite." }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
