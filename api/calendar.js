// api/calendar.js
// Vercel Serverless Function for Google Calendar Countdown
export default async function handler(req, res) {
  const apiKey = process.env.GOOGLE_CALENDAR_API_KEY;
  const calendarId = process.env.GOOGLE_CALENDAR_ID; // e.g., your_email@group.calendar.google.com

  if (!apiKey || !calendarId) {
    return res.status(500).json({ error: "Missing Google Calendar credentials." });
  }

  try {
    // Fetch upcoming events
    const url = `https://www.googleapis.com/calendar/v3/calendars/${encodeURIComponent(calendarId)}/events?key=${apiKey}&timeMin=${new Date().toISOString()}&maxResults=1&singleEvents=true&orderBy=startTime`;
    const response = await fetch(url);
    const data = await response.json();

    if (data.items && data.items.length > 0) {
      const nextEvent = data.items[0];
      res.status(200).json({
        nextBroadcast: nextEvent.summary,
        startTime: nextEvent.start.dateTime || nextEvent.start.date
      });
    } else {
      res.status(200).json({ message: "No upcoming broadcasts scheduled." });
    }
  } catch (error) {
    res.status(500).json({ error: "Failed to fetch calendar data", details: error.message });
  }
}
