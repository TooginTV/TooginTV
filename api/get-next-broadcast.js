export default async function handler(req, res) {
    const apiKey = process.env.CALENDAR_API_KEY;
    const calendarId = process.env.CALENDAR_ID;

    // Validate environment variables are present
    if (!apiKey || !calendarId) {
        return res.status(500).json({ error: "Calendar configuration missing on server" });
    }

    try {
        const nowIso = new Date().toISOString();
        
        // Google Calendar API v3 endpoint
        // Parameters: singleEvents=true and orderBy=startTime ensure we get the next immediate chronological event
        const calendarUrl = `https://www.googleapis.com/calendar/v3/calendars/${encodeURIComponent(calendarId)}/events?key=${apiKey}&timeMin=${nowIso}&singleEvents=true&orderBy=startTime&maxResults=1`;

        const response = await fetch(calendarUrl);
        const data = await response.json();

        if (data.items && data.items.length > 0) {
            const nextEvent = data.items[0];
            // Google Calendar provides either dateTime (for specific times) or date (for all-day events)
            const eventStart = nextEvent.start.dateTime || nextEvent.start.date;
            
            return res.status(200).json({ 
                title: nextEvent.summary,
                startTime: eventStart 
            });
        } else {
            return res.status(404).json({ error: "No upcoming broadcasts found" });
        }
    } catch (error) {
        console.error("Calendar API Error:", error);
        return res.status(500).json({ error: "Failed to fetch calendar data" });
    }
}
