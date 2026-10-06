export default async function handler(req, res) {
    const clientId = process.env.TWITCH_CLIENT_ID;
    const clientSecret = process.env.TWITCH_CLIENT_SECRET;
    const broadcasterId = process.env.TWITCH_BROADCASTER_ID; 

    try {
        // Step 1: Securely generate an OAuth App Access Token
        const tokenResponse = await fetch(`https://id.twitch.tv/oauth2/token?client_id=${clientId}&client_secret=${clientSecret}&grant_type=client_credentials`, {
            method: 'POST'
        });
        const tokenData = await tokenResponse.json();
        const accessToken = tokenData.access_token;

        // Step 2: Request the latest archived broadcast (VOD)
        const vodResponse = await fetch(`https://api.twitch.tv/helix/videos?user_id=${broadcasterId}&type=archive&first=1`, {
            headers: {
                'Client-ID': clientId,
                'Authorization': `Bearer ${accessToken}`
            }
        });
        const vodData = await vodResponse.json();

        // Step 3: Return only the VOD ID to your website frontend
        if (vodData.data && vodData.data.length > 0) {
            return res.status(200).json({ videoId: vodData.data[0].id });
        } else {
            return res.status(404).json({ error: 'No archived VODs found' });
        }
    } catch (error) {
        return res.status(500).json({ error: "Failed to fetch VOD data" });
    }
}
