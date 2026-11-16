export default async function handler(req, res) {
    const apiKey = process.env.GOOGLE_CALENDAR_API_KEY;
    const calendarId = process.env.GOOGLE_CALENDAR_ID;

    try {
        const nowIso = new Date().toISOString();
        const url = `https://www.googleapis.com/calendar/v3/calendars/${encodeURIComponent(calendarId)}/events?key=${apiKey}&timeMin=${nowIso}&orderBy=startTime&singleEvents=true&maxResults=1`;
        
        const calendarRes = await fetch(url);
        const data = await calendarRes.json();
        
        if (data.items && data.items.length > 0) {
            return res.status(200).json({
                title: data.items[0].summary,
                startTime: data.items[0].start.dateTime || data.items[0].start.date
            });
        } else {
            return res.status(404).json({ error: "No upcoming events" });
        }
    } catch (error) {
        return res.status(500).json({ error: "Calendar API Failure" });
    }
}
