mkdir -p api css js

cat << 'EOF' > css/styles.css
:root {
    --primary-cyan: #4ce0e4; 
    --primary-pink: #eb74ab; 
    --pink-hover: #d15d92;
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
    display: flex; flex-direction: column; align-items: center;
    width: 100%; max-width: 1000px; padding: 2rem 0; margin-bottom: 2rem; gap: 1.5rem;
}

.logo-img { max-width: 250px; height: auto; border-radius: 8px; box-shadow: var(--card-shadow); transition: transform 0.3s ease; }
.logo-img:hover { transform: translateY(-2px); }

.header-controls { display: flex; gap: 1rem; align-items: center; flex-wrap: wrap; justify-content: center; }

.btn {
    background-color: var(--primary-pink); color: #ffffff; border: none; padding: 0.8rem 1.5rem;
    font-family: 'Montserrat', sans-serif; font-size: 0.9rem; font-weight: 700; cursor: pointer;
    border-radius: 50px; text-transform: uppercase; text-decoration: none; text-align: center;
    letter-spacing: 0.5px; transition: all 0.2s ease; box-shadow: 0 4px 10px rgba(235, 116, 171, 0.3);
}

.btn:hover { background-color: var(--pink-hover); transform: translateY(-2px); box-shadow: 0 6px 15px rgba(235, 116, 171, 0.4); }
.btn-outline { background-color: var(--card-bg); border: 2px solid var(--primary-pink); color: var(--text-color); box-shadow: var(--card-shadow); }
.btn-outline:hover { background-color: var(--primary-pink); color: #ffffff; }

main { width: 100%; max-width: 1000px; display: flex; flex-direction: column; gap: 2.5rem; }

.card {
    background-color: var(--card-bg);
    background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noiseFilter'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.35' numOctaves='3' stitchTiles='stitch'/%3E%3CfeColorMatrix type='matrix' values='1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 12 -4' /%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noiseFilter)' opacity='0.35'/%3E%3C/svg%3E");
    padding: 2.5rem; border-radius: 16px; box-shadow: var(--card-shadow); border: 2px solid var(--border-color);
    transition: background-color 0.4s ease, border 0.4s ease;
}

.text-center { text-align: center; }
.card h2 { color: var(--primary-pink); margin-bottom: 1rem; font-size: 1.8rem; }
.card p { margin-bottom: 1rem; color: inherit; opacity: 0.9; }

/* Media Tabs & Embeds */
.tabs-header { display: flex; gap: 1rem; margin-bottom: 1.5rem; justify-content: center; border-bottom: 2px solid var(--border-color); padding-bottom: 0.5rem; }
.tab-btn { background: transparent; border: none; color: var(--text-color); font-family: 'Montserrat', sans-serif; font-size: 1.3rem; font-weight: 700; cursor: pointer; padding: 0.5rem 1rem; opacity: 0.5; transition: opacity 0.2s ease, color 0.2s ease; }
.tab-btn:hover { opacity: 0.8; }
.tab-btn.active { opacity: 1; color: var(--primary-pink); border-bottom: 3px solid var(--primary-pink); }
.tab-content { display: none; width: 100%; border: 2px solid var(--primary-pink); border-radius: 8px; overflow: hidden; background: #000; }
.tab-content.active { display: block; }
.tiktok-wrapper { display: flex; justify-content: center; background: var(--bg-color); padding: 1rem; }
#twitch-embed-wrapper { position: relative; width: 100%; height: 600px; }

/* Popup Player (PiP) Styles */
.floating-pip {
    position: fixed !important;
    bottom: 20px;
    right: 20px;
    width: 380px !important;
    height: 214px !important;
    z-index: 9999;
    box-shadow: 0 15px 35px rgba(0,0,0,0.5);
    border: 3px solid var(--primary-cyan);
    border-radius: 12px;
    animation: slideUp 0.3s ease forwards;
}

.pip-close-btn {
    display: none; position: absolute; top: -12px; right: -12px;
    background: var(--primary-pink); color: white; border: none; border-radius: 50%;
    width: 28px; height: 28px; font-weight: bold; cursor: pointer; z-index: 10000;
    box-shadow: 0 2px 5px rgba(0,0,0,0.3);
}

.floating-pip .pip-close-btn { display: block; }
.pip-close-btn:hover { transform: scale(1.1); background: var(--pink-hover); }

@keyframes slideUp {
    from { transform: translateY(50px); opacity: 0; }
    to { transform: translateY(0); opacity: 1; }
}

@media (max-width: 768px) {
    #twitch-embed-wrapper { height: 400px; }
    .floating-pip { width: 300px !important; height: 169px !important; }
}
EOF

cat << 'EOF' > js/main.js
// --- Theme Toggle ---
const themeToggle = document.getElementById('themeToggle');
if (themeToggle) {
    if (localStorage.getItem('toogintv-theme') === 'dark') { document.body.classList.add('dark-mode'); }
    themeToggle.addEventListener('click', () => {
        document.body.classList.toggle('dark-mode');
        localStorage.setItem('toogintv-theme', document.body.classList.contains('dark-mode') ? 'dark' : 'light');
    });
}

// --- Corrected Media Tabs Logic ---
function switchTab(tabName, event) {
    document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
    document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));
    
    // Corrected to safely handle the event object
    if(event) { event.target.classList.add('active'); }
    document.getElementById(`tab-${tabName}`).classList.add('active');

    // Force TikTok re-render
    if (tabName === 'tiktok' && typeof tiktokEmbed !== 'undefined') {
        const script = document.createElement('script');
        script.src = "https://www.tiktok.com/embed.js";
        script.async = true;
        document.body.appendChild(script);
    }
}

// --- Twitch Player Generation & API Logic ---
function createTwitchPlayer(containerId, isPip = false) {
    const layoutMode = (window.innerWidth >= 900 && !isPip) ? "video-with-chat" : "video";
    const embed = new Twitch.Embed(containerId, {
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
    return embed;
}

// --- Picture-in-Picture (PiP) Observer & Global State ---
let userClosedPip = false;

function closePip() {
    userClosedPip = true;
    sessionStorage.setItem('pipActive', 'false');
    const wrapper = document.getElementById('twitch-embed-wrapper');
    if (wrapper) wrapper.classList.remove('floating-pip');
    
    // If we closed the globally injected PiP on a sub-page, completely remove it
    if (!document.getElementById('video-section')) {
        wrapper.remove();
    }
}

document.addEventListener("DOMContentLoaded", () => {
    const videoSection = document.getElementById('video-section');
    const twitchWrapper = document.getElementById('twitch-embed-wrapper');

    // SCROLL PiP Logic (Only runs on the Index Page)
    if (videoSection && twitchWrapper) {
        createTwitchPlayer('twitch-embed', false);

        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                const isTwitchActive = document.getElementById('tab-twitch').classList.contains('active');
                if (!entry.isIntersecting && isTwitchActive && !userClosedPip) {
                    twitchWrapper.classList.add('floating-pip');
                    sessionStorage.setItem('pipActive', 'true');
                } else {
                    twitchWrapper.classList.remove('floating-pip');
                    if(isTwitchActive) sessionStorage.setItem('pipActive', 'true'); // Keep true for cross-page intent
                }
            });
        }, { threshold: 0.1 });
        observer.observe(videoSection);
    }

    // CROSS-PAGE PiP Logic (Runs on Sub-pages like Schedule, Guests, etc.)
    if (!videoSection && sessionStorage.getItem('pipActive') === 'true') {
        const globalPip = document.createElement('div');
        globalPip.id = "twitch-embed-wrapper";
        globalPip.className = "floating-pip";
        globalPip.innerHTML = `
            <button class="pip-close-btn" onclick="closePip()">X</button>
            <div id="twitch-embed" style="width: 100%; height: 100%;"></div>
        `;
        document.body.appendChild(globalPip);
        createTwitchPlayer('twitch-embed', true);
    }
});

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
        <!-- 1. Countdown Section -->
        <section class="card schedule-section text-center">
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

        <!-- 2. Video Player Section -->
        <section class="card media-tabs-wrapper text-center" id="video-section">
            <div class="tabs-header">
                <button class="tab-btn active" onclick="switchTab('twitch', event)">Live & VODs</button>
                <button class="tab-btn" onclick="switchTab('tiktok', event)">TikTok Shorts</button>
            </div>
            
            <div id="tab-twitch" class="tab-content active">
                <div id="twitch-embed-wrapper">
                    <button class="pip-close-btn" onclick="closePip()">X</button>
                    <div id="twitch-embed" style="width: 100%; height: 100%;"></div>
                </div>
            </div>
            
            <div id="tab-tiktok" class="tab-content">
                <div class="tiktok-wrapper">
                    <blockquote class="tiktok-embed" cite="https://www.tiktok.com/@toogintvofficial" data-unique-id="toogintvofficial" data-embed-type="creator" style="max-width: 780px; min-width: 288px;" >
                        <section><a target="_blank" href="https://www.tiktok.com/@toogintvofficial?refer=creator_embed">@toogintvofficial</a></section>
                    </blockquote>
                </div>
            </div>
        </section>

        <!-- 3. What is TooginTV Section (Moved Below Video) -->
        <section class="card text-center">
            <h2>What is TooginTV?</h2>
            <p><strong>TooginTV is a music-related variety show that has been broadcasting live on Twitch every Thursday night for 4 years.</strong></p>
            <p>Driven by the ancient streaming art of "Toogin-style" jamming, it's a weekly session where talented musicians spontaneously gather to play whatever songs they feel like live to the internet!</p>
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
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500&family=Montserrat:wght@700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/styles.css">
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
        <section class="card text-center">
            <h1 style="color: var(--primary-pink); font-size: 2.8rem; text-transform: uppercase;">Live Band Karaoke Event</h1>
            <p style="font-size: 1.2rem;">Get ready to take the stage with a real, live band backing you up on <strong>December 13th</strong>!</p>
        </section>
        <section class="card text-center" style="display:flex; flex-direction:column; align-items:center;">
            <h2 style="color: var(--primary-cyan); font-size: 2rem;">What do you want to sing?</h2>
            <div style="background: rgba(235,116,171,0.1); border: 2px dashed var(--primary-pink); padding: 1rem; border-radius: 8px; margin: 1rem 0;">
                When filling out the form below, please be sure to enter your requested songs in the exact format: <br>
                <strong>"Song title" - "Artist"</strong>
            </div>
            <a href="#" id="karaokeFormBtn" target="_blank" class="btn" style="padding: 1.2rem 2.5rem; font-size: 1.1rem;">Open Song Request Form</a>
        </section>
    </main>
    <script src="js/config.js"></script>
    <script src="https://embed.twitch.tv/embed/v1.js"></script>
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
        </section>
    </main>
    <script src="js/config.js"></script>
    <script src="https://embed.twitch.tv/embed/v1.js"></script>
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
        </section>
    </main>
    <script src="js/config.js"></script>
    <script src="https://embed.twitch.tv/embed/v1.js"></script>
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
            <p>Join our growing family of <strong>376 followers</strong> on Twitch!</p>
        </section>
    </main>
    <script src="js/config.js"></script>
    <script src="https://embed.twitch.tv/embed/v1.js"></script>
    <script src="js/main.js"></script>
</body>
</html>
EOF

echo "TooginTV Update Complete! Floating PiP logic injected."