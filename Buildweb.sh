#!/bin/bash

echo "Creating style_checklist.md..."
cat << 'EOF' > style_checklist.md
# TooginTV Style Checklist & Changelog

## Core Brand Identity
*   **Primary Background:** Deep Black (`#0a0a0c`)
*   **Toogin Pink:** `#ff2a85` (Used for active states, primary buttons, and warnings)
*   **Toogin Cyan:** `#00f0ff` (Used for headers, passive links, and borders)
*   **Typography:** `'Courier New', Courier, monospace` (Maintains the raw, technical, terminal-like aesthetic)
*   **Texture:** TV-Static overlay (`opacity: 0.15`) via SVG or transparent stardust pattern to mimic the distressed logo.
*   **Logo Asset:** `black and pink.png`

## Design Principles
1.  **Preservation:** Never alter historical page copy unless explicitly requested.
2.  **Contrast:** Ensure neon pink/cyan elements pass WCAG contrast ratios against the black background.
3.  **Responsiveness:** All media cards (Twitch/TikTok) must flex to 100% width on mobile viewports (max-width 768px).

## Changelog
*   **2026-10-09:** Initialized checklist. Standardized Pink/Cyan hex codes. Diagnosed hidden-tab rendering bugs for media embeds.
EOF

echo "Patching js/main.js for lazy-loading and secure Vercel API fetching..."
cat << 'EOF' > js/main.js
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
EOF

echo "Build complete. Files overwritten securely."