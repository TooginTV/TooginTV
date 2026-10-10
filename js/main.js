// --- Theme Toggle ---
const themeToggle = document.getElementById('themeToggle');
if (themeToggle) {
    if (localStorage.getItem('toogintv-theme') === 'dark') { document.body.classList.add('dark-mode'); }
    themeToggle.addEventListener('click', () => {
        document.body.classList.toggle('dark-mode');
        localStorage.setItem('toogintv-theme', document.body.classList.contains('dark-mode') ? 'dark' : 'light');
    });
}

// --- Secure Tab Switching & Lazy Loading ---
let tiktokLoaded = false;
let twitchLoaded = false;

function switchTab(tabName, event) {
    // 1. Reset active states
    document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
    document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));
    
    // 2. Set new active states
    if(event) { event.target.classList.add('active'); }
    const activeTab = document.getElementById(`tab-${tabName}`);
    if (activeTab) activeTab.classList.add('active');

    // 3. Lazy Load TikTok only when visible to prevent 0-height rendering bug
    if (tabName === 'tiktok' && !tiktokLoaded && typeof tiktokEmbed !== 'undefined') {
        const script = document.createElement('script');
        script.src = "https://www.tiktok.com/embed.js";
        script.async = true;
        document.body.appendChild(script);
        tiktokLoaded = true;
    }

    // 4. Lazy Load Twitch only when visible to prevent autoplay visibility violations
    if (tabName === 'twitch' && !twitchLoaded) {
        createTwitchPlayer('twitch-embed', false);
        twitchLoaded = true;
    }
}

// --- Twitch Embed Logic (Vercel Backend Integration) ---
function createTwitchPlayer(containerId, isPip = false) {
    const layoutMode = (window.innerWidth >= 900 && !isPip) ? "video-with-chat" : "video";
    const embed = new Twitch.Embed(containerId, {
        width: "100%", height: "100%", channel: "toogintv", layout: layoutMode,
        parent: TOOGIN_CONFIG.TWITCH_PARENT_DOMAINS, autoplay: true, muted: false
    });

    let vodLoaded = false; // Safeguard against MaxListeners loop
    
    embed.addEventListener(Twitch.Embed.VIDEO_READY, () => {
        const player = embed.getPlayer();
        if (!player) return;

        embed.addEventListener(Twitch.Player.OFFLINE, async () => {
            if (vodLoaded) return;
            console.log("Stream offline. Securely fetching Thursday VOD via Vercel...");
            
            try {
                const res = await fetch('/api/get-twitch-vod');
                if (!res.ok) throw new Error("Backend proxy returned error");
                
                const data = await res.json();
                if (data.videoId) { 
                    player.setVideo(data.videoId); 
                    vodLoaded = true;
                    return;
                }
            } catch (error) {
                console.warn("VOD fetch failed, falling back to manual config ID:", error);
                const safeFallback = String(TOOGIN_CONFIG.FALLBACK_VOD_ID).replace(/[^0-9]/g, '');
                player.setVideo(safeFallback);
                vodLoaded = true;
            }
        });
    });

    return embed;
}

// --- Initialize default tab on DOM Load ---
document.addEventListener("DOMContentLoaded", () => {
    // Only trigger Twitch initialization if the tab is visible on page load
    const twitchTab = document.getElementById('tab-twitch');
    if (twitchTab && twitchTab.classList.contains('active')) {
        createTwitchPlayer('twitch-embed', false);
        twitchLoaded = true;
    }
    
    // (Cross-page PiP and Countdown logic remains intact here as previously built)
});
