mkdir -p api css js

cat << 'EOF' > api/get-twitch-vod.js
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
EOF

cat << 'EOF' > api/get-next-broadcast.js
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
EOF

cat << 'EOF' > css/styles.css
:root {
    --primary-cyan: #4ce0e4; 
    --primary-pink: #eb74ab; 
    --pink-hover: #d15d92;
    
    /* Baseline Light Mode Defaults */
    --bg-color: var(--primary-cyan);
    --text-color: #222222;
    --card-bg: #ffffff;
    --card-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
    --border-color: rgba(0, 0, 0, 0.1);
}

body.dark-mode {
    --bg-color: #0d0d0d; 
    --text-color: #f5f5f5;
    --card-bg: #1a1a1a;
    --card-shadow: 0 10px 30px rgba(0, 0, 0, 0.6);
    --border-color: rgba(255, 255, 255, 0.1);
}

* { box-sizing: border-box; margin: 0; padding: 0; }

body {
    background-color: var(--bg-color);
    color: var(--text-color);
    font-family: 'Inter', sans-serif;
    transition: background-color 0.4s ease, color 0.4s ease;
    display: flex;
    flex-direction: column;
    align-items: center;
    min-height: 100vh;
    padding: 0 1.5rem 3rem 1.5rem;
    line-height: 1.6;
}

h1, h2, h3, .brand-font { font-family: 'Montserrat', sans-serif; }

header {
    display: flex;
    flex-direction: column;
    align-items: center;
    width: 100%;
    max-width: 1000px;
    padding: 2rem 0;
    margin-bottom: 2rem;
    gap: 1.5rem;
}

.logo-img {
    max-width: 250px;
    height: auto;
    border-radius: 8px;
    box-shadow: var(--card-shadow);
    transition: transform 0.3s ease;
}

.logo-img:hover { transform: translateY(-2px); }

.header-controls { 
    display: flex; 
    gap: 1rem; 
    align-items: center; 
    flex-wrap: wrap;
    justify-content: center;
}

.btn {
    background-color: var(--primary-pink);
    color: #ffffff;
    border: none;
    padding: 0.8rem 1.5rem;
    font-family: 'Montserrat', sans-serif;
    font-size: 0.9rem;
    font-weight: 700;
    cursor: pointer;
    border-radius: 50px;
    text-transform: uppercase;
    text-decoration: none;
    text-align: center;
    letter-spacing: 0.5px;
    transition: all 0.2s ease;
    box-shadow: 0 4px 10px rgba(235, 116, 171, 0.3);
}

.btn:hover {
    background-color: var(--pink-hover);
    transform: translateY(-2px);
    box-shadow: 0 6px 15px rgba(235, 116, 171, 0.4);
}

.btn-outline {
    background-color: var(--card-bg);
    border: 2px solid var(--primary-pink);
    color: var(--text-color);
    box-shadow: var(--card-shadow);
}

.btn-outline:hover { background-color: var(--primary-pink); color: #ffffff; }

main {
    width: 100%;
    max-width: 1000px;
    display: flex;
    flex-direction: column;
    gap: 2.5rem;
}

.card {
    background-color: var(--card-bg);
    background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noiseFilter'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.35' numOctaves='3' stitchTiles='stitch'/%3E%3CfeColorMatrix type='matrix' values='1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 12 -4' /%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noiseFilter)' opacity='0.35'/%3E%3C/svg%3E");
    padding: 2.5rem;
    border-radius: 16px;
    box-shadow: var(--card-shadow);
    border: 2px solid var(--border-color);
    transition: background-color 0.4s ease, border 0.4s ease;
}

.text-center { text-align: center; }
.card h2 { color: var(--primary-pink); margin-bottom: 1rem; font-size: 1.8rem; }
.card p { margin-bottom: 1rem; color: inherit; opacity: 0.9; }

.schedule-section { text-align: center; display: flex; flex-direction: column; align-items: center; gap: 1.5rem; }
.event-title { color: var(--primary-cyan); font-size: 1.5rem; font-family: 'Montserrat', sans-serif; text-transform: uppercase; display: block; margin-bottom: 0.5rem; }
.local-time { color: #ffffff; background: #222; padding: 0.3rem 0.8rem; border-radius: 6px; font-weight: 700; display: inline-block; }
.countdown { display: flex; gap: 1.5rem; justify-content: center; margin-top: 1rem; }
.time-box { display: flex; flex-direction: column; align-items: center; background-color: var(--bg-color); padding: 1.2rem; border-radius: 12px; min-width: 90px; border: 2px solid rgba(235, 116, 171, 0.3); box-shadow: inset 0 2px 5px rgba(0,0,0,0.2); }
.time-box span { font-family: 'Montserrat', sans-serif; font-size: 2.5rem; font-weight: 800; color: var(--primary-pink); line-height: 1; }
.time-box small { font-weight: 500; text-transform: uppercase; font-size: 0.8rem; margin-top: 0.5rem; opacity: 0.9; }

.tabs-header { display: flex; gap: 1rem; margin-bottom: 1.5rem; justify-content: center; border-bottom: 2px solid var(--border-color); padding-bottom: 0.5rem; }
.tab-btn { background: transparent; border: none; color: var(--text-color); font-family: 'Montserrat', sans-serif; font-size: 1.3rem; font-weight: 700; cursor: pointer; padding: 0.5rem 1rem; opacity: 0.5; transition: opacity 0.2s ease, color 0.2s ease; }
.tab-btn:hover { opacity: 0.8; }
.tab-btn.active { opacity: 1; color: var(--primary-pink); border-bottom: 3px solid var(--primary-pink); }
.tab-content { display: none; width: 100%; border: 2px solid var(--primary-pink); border-radius: 8px; overflow: hidden; background: #000; }
.tab-content.active { display: block; }
#twitch-embed { width: 100%; height: 600px; }
.tiktok-wrapper { display: flex; justify-content: center; background: var(--bg-color); padding: 1rem; }

@media (max-width: 768px) {
    .countdown { gap: 0.8rem; }
    .time-box { min-width: 70px; padding: 0.8rem; }
    .time-box span { font-size: 1.8rem; }
    #twitch-embed { height: 400px; }
}
EOF

cat << 'EOF' > js/config.js
const TOOGIN_CONFIG = {
    FALLBACK_VOD_ID: '2883281258',
    KARAOKE_FORM_URL: 'https://forms.gle/nuqk7rW6bXGMXbZP7',
    TWITCH_PARENT_DOMAINS: ['localhost', '127.0.0.1', 'toogintv.com', 'www.toogintv.com']
};
EOF

cat << 'EOF' > js/main.js
// --- Theme Toggle ---
const themeToggle = document.getElementById('themeToggle');
if (themeToggle) {
    if (localStorage.getItem('toogintv-theme') === 'dark') {
        document.body.classList.add('dark-mode');
    }
    
    themeToggle.addEventListener('click', () => {
        document.body.classList.toggle('dark-mode');
        const isDark = document.body.classList.contains('dark-mode');
        localStorage.setItem('toogintv-theme', isDark ? 'dark' : 'light');
    });
}

// --- Media Tabs Logic & TikTok Fix ---
function switchTab(tabName) {
    document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
    document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));
    
    event.target.classList.add('active');
    document.getElementById(`tab-${tabName}`).classList.add('active');

    if (tabName === 'tiktok' && typeof tiktokEmbed !== 'undefined') {
        const script = document.createElement('script');
        script.src = "https://www.tiktok.com/embed.js";
        script.async = true;
        document.body.appendChild(script);
    }
}

// --- Twitch Embed Logic (Index Page Only) ---
if (document.getElementById('twitch-embed')) {
    const layoutMode = window.innerWidth >= 900 ? "video-with-chat" : "video";
    const embed = new Twitch.Embed("twitch-embed", {
        width: "100%", height: "100%", channel: "toogintv", layout: layoutMode,
        parent: TOOGIN_CONFIG.TWITCH_PARENT_DOMAINS, autoplay: true, muted: false
    });

    embed.addEventListener(Twitch.Embed.VIDEO_READY, () => {
        const player = embed.getPlayer();
        player.addEventListener(Twitch.Player.OFFLINE, async () => {
            try {
                const res = await fetch('/api/get-twitch-vod');
                if (res.ok) {
                    const data = await res.json();
                    if (data.videoId) { player.setVideo(data.videoId); return; }
                }
                throw new Error("No VOD found");
            } catch (error) {
                player.setVideo(TOOGIN_CONFIG.FALLBACK_VOD_ID);
            }
        });
    });
}

// --- Vercel Countdown Logic (Index Page Only) ---
if (document.getElementById('countdown')) {
    function getFallbackDate() {
        const now = new Date();
        let startSearch = new Date(now.getFullYear(), now.getMonth(), now.getDate(), now.getHours());
        for (let i = 0; i < 14 * 24; i++) {
            let tempDate = new Date(startSearch.getTime() + i * 3600000);
            let parts = new Intl.DateTimeFormat('en-US', { timeZone: 'America/Edmonton', weekday: 'short', hour: 'numeric', hour12: true }).formatToParts(tempDate);
            let weekday = parts.find(p => p.type === 'weekday').value;
            let hour = parts.find(p => p.type === 'hour').value;
            let ampmVal = parts.find(p => p.type === 'dayPeriod' || p.type === 'ampm')?.value.toUpperCase() || '';
            if (weekday === 'Thu' && ((hour === '8' && ampmVal.includes('PM')) || hour === '20')) {
                if (tempDate > now) return tempDate;
            }
        }
        return now; 
    }

    async function initCountdown() {
        let targetDate = getFallbackDate();
        let targetTitle = "Toogin Thursday Jam";

        try {
            const res = await fetch('/api/get-next-broadcast');
            if (res.ok) {
                const data = await res.json();
                if (data.startTime) {
                    targetTitle = data.title || targetTitle;
                    targetDate = new Date(data.startTime);
                }
            }
        } catch(e) { console.error("API failed. Using fallback schedule."); }

        document.getElementById('eventTitleDisplay').textContent = targetTitle;
        document.getElementById('localTimeDisplay').textContent = targetDate.toLocaleTimeString([], { hour: 'numeric', minute: '2-digit', timeZoneName: 'short' });

        function updateTimer() {
            const distance = targetDate.getTime() - new Date().getTime();
            if (distance < 0) {
                document.getElementById("countdown").innerHTML = "<h3 class='brand-font' style='color: var(--primary-pink); font-size: 2rem; margin-top: 1rem;'>WE ARE LIVE!</h3>";
                return;
            }
            document.getElementById("days").innerText = String(Math.floor(distance / (1000 * 60 * 60 * 24))).padStart(2, '0');
            document.getElementById("hours").innerText = String(Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60))).padStart(2, '0');
            document.getElementById("mins").innerText = String(Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60))).padStart(2, '0');
            document.getElementById("secs").innerText = String(Math.floor((distance % (1000 * 60)) / 1000)).padStart(2, '0');
        }
        setInterval(updateTimer, 1000);
        updateTimer();
    }
    initCountdown();
}
EOF

cat << 'EOF' > index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TooginTV - Live Stream & Jam Sessions</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500&family=Montserrat:wght@700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/styles.css">
</head>
<body class="">
    <header>
        <img src="black and pink.png" alt="TooginTV Logo" class="logo-img">
        <nav class="header-controls">
            <a href="index.html" class="btn">Home</a>
            <a href="karaoke.html" class="btn btn-outline">Karaoke Event</a>
            <a href="schedule.html" class="btn btn-outline">Schedule</a>
            <a href="guests.html" class="btn btn-outline">Guests</a>
            <a href="community.html" class="btn btn-outline">Community</a>
            <button class="btn btn-outline" id="themeToggle">🌓 Theme</button>
        </nav>
    </header>

    <main>
        <section class="card text-center">
            <h2>What is TooginTV?</h2>
            <p><strong>TooginTV is a music-related variety show that has been broadcasting live on Twitch every Thursday night for 4 years.</strong></p>
            <p>Driven by the ancient streaming art of "Toogin-style" jamming, it's a weekly session where talented musicians spontaneously gather to play whatever songs they feel like live to the internet!</p>
        </section>

        <section class="card schedule-section">
            <h2>Next Live Stream</h2>
            <div class="schedule-text">
                <span class="event-title" id="eventTitleDisplay">Fetching Schedule...</span>
                @ <span id="localTimeDisplay" class="local-time">...</span>
            </div>
            <div class="countdown" id="countdown">
                <div class="time-box"><span id="days">00</span><small>Days</small></div>
                <div class="time-box"><span id="hours">00</span><small>Hours</small></div>
                <div class="time-box"><span id="mins">00</span><small>Mins</small></div>
                <div class="time-box"><span id="secs">00</span><small>Secs</small></div>
            </div>
        </section>

        <section class="card media-tabs-wrapper">
            <div class="tabs-header">
                <button class="tab-btn active" onclick="switchTab('twitch')">Live & VODs</button>
                <button class="tab-btn" onclick="switchTab('tiktok')">TikTok Shorts</button>
            </div>
            
            <div id="tab-twitch" class="tab-content active">
                <div id="twitch-embed"></div>
            </div>
            
            <div id="tab-tiktok" class="tab-content">
                <div class="tiktok-wrapper">
                    <blockquote class="tiktok-embed" cite="https://www.tiktok.com/@toogintvofficial" data-unique-id="toogintvofficial" data-embed-type="creator" style="max-width: 780px; min-width: 288px;" >
                        <section><a target="_blank" href="https://www.tiktok.com/@toogintvofficial?refer=creator_embed">@toogintvofficial</a></section>
                    </blockquote>
                </div>
            </div>
        </section>
    </main>

    <script src="js/config.js"></script>
    <script src="https://embed.twitch.tv/embed/v1.js"></script>
    <script src="js/main.js"></script>
</body>
</html>
EOF

cat << 'EOF' > karaoke.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TooginTV - Live Karaoke Event</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500&family=Montserrat:wght@700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/styles.css">
    <style>
        .hero-section h1 { color: var(--primary-pink); margin-bottom: 1rem; font-size: 2.8rem; text-transform: uppercase; letter-spacing: 1px; line-height: 1.2; }
        .hero-section p { font-size: 1.2rem; margin-bottom: 1.5rem; opacity: 0.9; }
        .hero-section strong { color: var(--primary-cyan); font-size: 1.3rem; }
        body:not(.dark-mode) .hero-section strong { color: #d15d92; }
        .request-card { display: flex; flex-direction: column; align-items: center; gap: 1rem; }
        .request-card h2 { font-size: 2rem; margin-bottom: 0.5rem; color: var(--primary-cyan); }
        .highlight-box { background-color: rgba(235, 116, 171, 0.1); border: 2px dashed var(--primary-pink); padding: 1rem; border-radius: 8px; margin: 1rem 0; font-weight: 500; }
    </style>
</head>
<body class=""> 
    <header>
        <img src="black and pink.png" alt="TooginTV Logo" class="logo-img">
        <nav class="header-controls">
            <a href="index.html" class="btn btn-outline">Home</a>
            <a href="karaoke.html" class="btn">Karaoke Event</a>
            <a href="schedule.html" class="btn btn-outline">Schedule</a>
            <a href="guests.html" class="btn btn-outline">Guests</a>
            <a href="community.html" class="btn btn-outline">Community</a>
            <button class="btn btn-outline" id="themeToggle">🌓 Theme</button>
        </nav>
    </header>

    <main>
        <section class="card hero-section text-center">
            <h1>Live Band Karaoke Event</h1>
            <p>Get ready to take the stage with a real, live band backing you up on <strong>December 13th</strong>!</p>
            <p>Because we're planning ahead, the floodgates are wide open—we are currently accepting any song request you can dream up.</p>
        </section>

        <section class="card request-card text-center">
            <h2>What do you want to sing?</h2>
            <p>Don't wait to submit your track: as we get closer to the big night, limits will kick in and song choices will be strictly capped.</p>
            <div class="highlight-box">
                When filling out the form below, please be sure to enter your requested songs in the exact format: <br>
                <strong>"Song title" - "Artist"</strong>
            </div>
            <a href="#" id="karaokeFormBtn" target="_blank" class="btn" style="padding: 1.2rem 2.5rem; font-size: 1.1rem;">Open Song Request Form</a>
        </section>
    </main>

    <script src="js/config.js"></script>
    <script src="js/main.js"></script>
    <script>document.getElementById('karaokeFormBtn').href = TOOGIN_CONFIG.KARAOKE_FORM_URL;</script>
</body>
</html>
EOF

cat << 'EOF' > schedule.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Schedule | TooginTV</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500&family=Montserrat:wght@700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/styles.css">
</head>
<body class="">
    <header>
        <img src="black and pink.png" alt="TooginTV Logo" class="logo-img">
        <nav class="header-controls">
            <a href="index.html" class="btn btn-outline">Home</a>
            <a href="karaoke.html" class="btn btn-outline">Karaoke</a>
            <a href="schedule.html" class="btn">Schedule</a>
            <a href="guests.html" class="btn btn-outline">Guests</a>
            <a href="community.html" class="btn btn-outline">Community</a>
            <button class="btn btn-outline" id="themeToggle">🌓 Theme</button>
        </nav>
    </header>
    <main>
        <section class="card text-center">
            <h2>Broadcast Schedule</h2>
            <p>Catch us live twice a week across platforms.</p>
            <hr style="border-color: var(--border-color); margin: 20px 0;">
            <h3>Toogin Thursdays</h3>
            <p><strong>Thursdays - Evening (MST) on Twitch</strong></p>
            <p>The main event. A full musical variety stream featuring a comprehensive setlist, cover songs, guest performances, and live audio engineering.</p>
            <hr style="border-color: var(--border-color); margin: 20px 0;">
            <h3>TikTok Toogin Tuesday</h3>
            <p><strong>Tuesdays - Evening (MST) on TikTok</strong></p>
            <p>Interactive short-form variety streams, Q&A, and quick teasers setting up the rest of the week's content direct from Jay's studio.</p>
        </section>
    </main>
    <script src="js/main.js"></script>
</body>
</html>
EOF

cat << 'EOF' > guests.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Guest Archive | TooginTV</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500&family=Montserrat:wght@700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/styles.css">
    <style>
        .artist-list { display: flex; flex-direction: column; gap: 1.5rem; text-align: left; margin-top: 2rem; }
        .artist-card { display: flex; align-items: center; background: rgba(0,0,0,0.05); padding: 1.5rem; border-radius: 8px; border: 1px solid var(--border-color); }
        body.dark-mode .artist-card { background: rgba(255,255,255,0.05); }
    </style>
</head>
<body class="">
    <header>
        <img src="black and pink.png" alt="TooginTV Logo" class="logo-img">
        <nav class="header-controls">
            <a href="index.html" class="btn btn-outline">Home</a>
            <a href="karaoke.html" class="btn btn-outline">Karaoke</a>
            <a href="schedule.html" class="btn btn-outline">Schedule</a>
            <a href="guests.html" class="btn">Guests</a>
            <a href="community.html" class="btn btn-outline">Community</a>
            <button class="btn btn-outline" id="themeToggle">🌓 Theme</button>
        </nav>
    </header>
    <main>
        <section class="card text-center">
            <h2>Artist Archive</h2>
            <p>Featuring guest interviews and appearances from our regular collaborators and local performers.</p>
            <div class="artist-list">
                <div class="artist-card">
                    <div>
                        <h3>Johnny Blaze</h3>
                        <p>Vocalist for Enduring the Fall and Quietest. Known for bringing intense heavy metal energy and dynamic vocal performances directly to the broadcast.</p>
                    </div>
                </div>
                <div class="artist-card">
                    <div>
                        <h3>Ben (Facejaw)</h3>
                        <p>Frequent collaborator and performer, adding unique instrumental layers, rock vibes, and stage presence to the live setlists.</p>
                    </div>
                </div>
                <div class="artist-card">
                    <div>
                        <h3>Jay</h3>
                        <p>Co-host and musical talent bringing the energy of J's Fitness & Training into the studio, bridging the gap between musical performance and physical wellness.</p>
                    </div>
                </div>
            </div>
        </section>
    </main>
    <script src="js/main.js"></script>
</body>
</html>
EOF

cat << 'EOF' > community.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Community | TooginTV</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500&family=Montserrat:wght@700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/styles.css">
</head>
<body class="">
    <header>
        <img src="black and pink.png" alt="TooginTV Logo" class="logo-img">
        <nav class="header-controls">
            <a href="index.html" class="btn btn-outline">Home</a>
            <a href="karaoke.html" class="btn btn-outline">Karaoke</a>
            <a href="schedule.html" class="btn btn-outline">Schedule</a>
            <a href="guests.html" class="btn btn-outline">Guests</a>
            <a href="community.html" class="btn">Community</a>
            <button class="btn btn-outline" id="themeToggle">🌓 Theme</button>
        </nav>
    </header>
    <main>
        <section class="card text-center">
            <h2>Community Hub</h2>
            <p>Join our growing family of <strong>376 followers</strong> on Twitch! Don't forget to follow us on TikTok for short dramas, event updates, and recent clips.</p>
            <div class="header-controls" style="margin-top: 2rem;">
                <a href="https://www.tiktok.com/@toogintvofficial" target="_blank" class="btn">@toogintvofficial</a>
                <a href="https://www.twitch.tv/TooginTV" target="_blank" class="btn">Twitch</a>
            </div>
            <hr style="border-color: var(--border-color); margin: 30px 0;">
            <h3>Toddd's Corner</h3>
            <p>Solve the latest rhyming riddle teasers from Toddd, our resident AI persona, and listen to the newest 8-bit chiptune audio tracks generated for the stream.</p>
        </section>
    </main>
    <script src="js/main.js"></script>
</body>
</html>
EOF

echo "TooginTV site files successfully created!"