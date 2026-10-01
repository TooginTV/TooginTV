// config.js
const TOOGIN_CONFIG = {
    // Twitch API Developer Keys
    TWITCH_CLIENT_ID: 'gp762nuuoqcoxypju8c569th9wz7q5',
    TWITCH_ACCESS_TOKEN: 'fjft4g44hptrqde0ijl7tk8flqj29u',
    
    // Fallback VOD if API fails or no Thursday VOD exists
    FALLBACK_VOD_ID: '2883281258',
    // Google Calendar API Settings (For the dynamic countdown timer)
    // You can get a free API key from the Google Cloud Console (Calendar API v3)
    GOOGLE_CALENDAR_API_KEY: 'YOUR_GOOGLE_CALENDAR_API_KEY',
    // Find your Calendar ID in your Google Calendar Settings (e.g., your_address@group.calendar.google.com)
    GOOGLE_CALENDAR_ID: 'YOUR_CALENDAR_ID@group.calendar.google.com',
    
    // Karaoke Event Song Request Google Form URL
    KARAOKE_FORM_URL: 'https://forms.gle/nuqk7rW6bXGMXbZP7',
    // Approved domains for the Twitch Embed Player
    // Make sure your live website URL is in this list (e.g., 'toogintv.com', 'www.toogintv.com')
    TWITCH_PARENT_DOMAINS: ['localhost', '127.0.0.1', 'toogintv.com', 'www.toogintv.com']
};
