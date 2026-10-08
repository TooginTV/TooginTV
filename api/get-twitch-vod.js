export default async function handler(req, res) {
    const clientId = process.env.TWITCH_CLIENT_ID;
    const clientSecret = process.env.TWITCH_CLIENT_SECRET;
    const broadcasterId = process.env.TWITCH_BROADCASTER_ID || '12345678'; 

    try {
        const tokenRes = await fetch(`https://id.twitch.tv/oauth2/token?client_id=${clientId}&client_secret=${clientSecret}&grant_type=client_credentials`, { method: 'POST' });
        const tokenData = await tokenRes.json();
        const accessToken = tokenData.access_token;

        const videoRes = await fetch(`https://api.twitch.tv/helix/videos?user_id=${broadcasterId}&type=archive&first=20`, {
            headers: {
                'Client-ID': clientId,
                'Authorization': `Bearer ${accessToken}`
            }
        });
        const videoData = await videoRes.json();

        let thursdayVodId = null;
        if (videoData.data) {
            for (const video of videoData.data) {
                const date = new Date(video.created_at);
                const weekday = new Intl.DateTimeFormat('en-US', { timeZone: 'America/Edmonton', weekday: 'short' }).format(date);
                if (weekday === 'Thu') { thursdayVodId = video.id; break; }
            }
        }

        if (thursdayVodId) {
            return res.status(200).json({ videoId: thursdayVodId });
        } else {
            return res.status(404).json({ error: "No Thursday VODs found" });
        }
    } catch (error) {
        return res.status(500).json({ error: "API Failure" });
    }
}
