// api/twitch.js
// Vercel Serverless Function to fetch Twitch data securely
export default async function handler(req, res) {
  // Use environment variables from Vercel to keep secrets safe
  const clientId = process.env.TWITCH_CLIENT_ID;
  const clientSecret = process.env.TWITCH_CLIENT_SECRET;

  if (!clientId || !clientSecret) {
    return res.status(500).json({ error: "Missing Twitch API Credentials in Vercel." });
  }

  try {
    // 1. Get OAuth Token
    const tokenResponse = await fetch(`https://id.twitch.tv/oauth2/token?client_id=${clientId}&client_secret=${clientSecret}&grant_type=client_credentials`, { method: 'POST' });
    const tokenData = await tokenResponse.json();
    const accessToken = tokenData.access_token;

    // 2. Fetch TooginTV stream/VOD data using the token
    // (Replace 'YOUR_TWITCH_USER_ID' with the actual TooginTV Twitch ID)
    const streamResponse = await fetch(`https://api.twitch.tv/helix/streams?user_id=YOUR_TWITCH_USER_ID`, {
      headers: {
        'Client-ID': clientId,
        'Authorization': `Bearer ${accessToken}`
      }
    });
    
    const streamData = await streamResponse.json();
    res.status(200).json(streamData);
    
  } catch (error) {
    res.status(500).json({ error: "Failed to fetch Twitch data", details: error.message });
  }
}
