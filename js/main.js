// --- Theme Toggle ---
const themeToggle = document.getElementById('themeToggle');
if (themeToggle) {
    if (localStorage.getItem('toogintv-theme') === 'dark') { document.body.classList.add('dark-mode'); }
    themeToggle.addEventListener('click', () => {
        document.body.classList.toggle('dark-mode');
        localStorage.setItem('toogintv-theme', document.body.classList.contains('dark-mode') ? 'dark' : 'light');
    });
}

// --- Media Tabs Logic & TikTok Fix ---
function switchTab(tabName, event) {
    document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
    document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));
    
    if(event) { event.target.classList.add('active'); }
    document.getElementById(`tab-${tabName}`).classList.add('active');

    if (tabName === 'tiktok' && typeof tiktokEmbed !== 'undefined') {
        const script = document.createElement('script');
        script.src = "https://www.tiktok.com/embed.js";
        script.async = true;
        document.body.appendChild(script);
    }
}

// --- Twitch Player Generation & API Logic ---
let twitchPlayerInstance = null;
let vodLoaded = false;

function createTwitchPlayer(containerId, isPip = false) {
    if (twitchPlayerInstance) return twitchPlayerInstance;

    const layoutMode = (window.innerWidth >= 900 && !isPip) ? "video-with-chat" : "video";
    
    twitchPlayerInstance = new Twitch.Embed(containerId, {
        width: "100%", height: "100%", channel: "toogintv", layout: layoutMode,
        parent: TOOGIN_CONFIG.TWITCH_PARENT_DOMAINS, autoplay: true, muted: isPip
    });

    twitchPlayerInstance.addEventListener(Twitch.Embed.VIDEO_READY, () => {
        const player = twitchPlayerInstance.getPlayer();
        
        player.addEventListener(Twitch.Player.OFFLINE, async () => {
            if (vodLoaded) return; 
            vodLoaded = true;
            console.log("Channel is Offline. Fetching VOD via Vercel...");

            try {
                const res = await fetch('/api/get-twitch-vod');
                if (res.ok) {
                    const data = await res.json();
                    if (data.videoId) { 
                        player.setVideo(data.videoId); 
                        return; 
                    }
                }
                throw new Error("No VOD found via API");
            } catch (error) {
                console.error("VOD fetch failed, using fallback:", error);
                player.setVideo(TOOGIN_CONFIG.FALLBACK_VOD_ID);
            }
        });
    });

    return twitchPlayerInstance;
}

// --- Picture-in-Picture (PiP) Observer & Global State ---
let userClosedPip = false;

function closePip() {
    userClosedPip = true;
    sessionStorage.setItem('pipActive', 'false');
    const wrapper = document.getElementById('twitch-embed-wrapper');
    if (wrapper) wrapper.classList.remove('floating-pip');
    
    if (!document.getElementById('video-section')) {
        wrapper.remove();
    }
}

document.addEventListener("DOMContentLoaded", () => {
    const videoSection = document.getElementById('video-section');
    const twitchWrapper = document.getElementById('twitch-embed-wrapper');

    if (videoSection && twitchWrapper) {
        const wasFloating = sessionStorage.getItem('pipActive') === 'true';
        if (wasFloating && !userClosedPip) {
            twitchWrapper.classList.add('floating-pip');
        }

        createTwitchPlayer('twitch-embed', false);

        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                const isTwitchActive = document.getElementById('tab-twitch').classList.contains('active');
                if (!entry.isIntersecting && isTwitchActive && !userClosedPip) {
                    twitchWrapper.classList.add('floating-pip');
                    sessionStorage.setItem('pipActive', 'true');
                } else {
                    twitchWrapper.classList.remove('floating-pip');
                    if(isTwitchActive) sessionStorage.setItem('pipActive', 'true'); 
                }
            });
        }, { threshold: 0.1 });
        observer.observe(videoSection);
    }

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