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
    if (tabName === 'tiktok' && !tiktokLoaded) {
        const script = document.createElement('script');
        script.src = "https://www.tiktok.com/embed.js";
        script.async = true;
        document.body.appendChild(script);
        tiktokLoaded = true;
    }

    // 4. Lazy Load Twitch only when visible to prevent autoplay visibility violations
    if (tabName === 'twitch' && !twitchLoaded) {
        initTwitchPlayer();
        twitchLoaded = true;
    }
}

// --- Twitch Embed Logic (Vercel Backend Integration) ---
function initTwitchPlayer() {
    const container = document.getElementById('twitch-embed');
    if (!container) return;

    // Standard live channel initialization
    const embed = new Twitch.Embed("twitch-embed", {
        width: "100%", 
        height: "100%", 
        channel: "toogintv", 
        layout: window.innerWidth >= 900 ? "video-with-chat" : "video",
        parent: TOOGIN_CONFIG.TWITCH_PARENT_DOMAINS, 
        autoplay: true, 
        muted: false
    });

    let apiFired = false;

    // Securely attach to embed, NOT player object to prevent MaxListeners error
    embed.addEventListener(Twitch.Embed.VIDEO_READY, () => {
        const player = embed.getPlayer();
        if (!player) return;

        embed.addEventListener(Twitch.Player.OFFLINE, async () => {
            if (apiFired) return;
            apiFired = true;
            console.log("Stream offline. Securely fetching Thursday VOD via Vercel...");
            
            try {
                const res = await fetch('/api/get-twitch-vod');
                if (!res.ok) throw new Error("Backend proxy returned error");
                
                const data = await res.json();
                if (data.videoId) { 
                    player.setVideo(data.videoId); 
                } else {
                    throw new Error("No Thursday VOD ID found in response");
                }
            } catch (error) {
                console.warn("VOD fetch failed, falling back to manual config ID:", error);
                // Sanitize and validate fallback string before injection
                const safeFallback = String(TOOGIN_CONFIG.FALLBACK_VOD_ID).replace(/[^0-9]/g, '');
                player.setVideo(safeFallback);
            }
        });
    });
}

// --- Initialize default tab on DOM Load ---
document.addEventListener("DOMContentLoaded", () => {
    // If the twitch tab is visible on page load, trigger it.
    const twitchTab = document.getElementById('tab-twitch');
    if (twitchTab && twitchTab.classList.contains('active')) {
        initTwitchPlayer();
        twitchLoaded = true;
    }
});
