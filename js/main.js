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
