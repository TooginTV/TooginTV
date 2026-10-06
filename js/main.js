// --- Tab Switching Logic ---
function switchTab(tabId) {
    document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
    document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));
    
    document.querySelector(`button[onclick="switchTab('${tabId}')"]`).classList.add('active');
    document.getElementById(`${tabId}-tab`).classList.add('active');
}

// --- Countdown Timer Logic ---
function initCountdown() {
    const timerElement = document.getElementById('countdown-timer');
    if (!timerElement) return;

    // Default fallback to Next Thursday at 8 PM local time
    function getNextThursday() {
        const now = new Date();
        const nextThursday = new Date();
        nextThursday.setDate(now.getDate() + ((4 - 1 - now.getDay() + 7) % 7 + 1));
        nextThursday.setHours(20, 0, 0, 0); 
        return nextThursday;
    }

    const targetDate = getNextThursday().getTime();

    setInterval(() => {
        const now = new Date().getTime();
        const distance = targetDate - now;

        if (distance < 0) {
            timerElement.innerHTML = "WE ARE LIVE!";
            return;
        }

        const days = Math.floor(distance / (1000 * 60 * 60 * 24));
        const hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
        const minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
        const seconds = Math.floor((distance % (1000 * 60)) / 1000);

        timerElement.innerHTML = `${days}d ${hours}h ${minutes}m ${seconds}s`;
    }, 1000);
}

// --- Twitch Embed Logic ---
async function loadTwitchPlayer() {
    const container = document.getElementById('twitch-player-container');
    if (!container) return;

    try {
        // Ping your Vercel serverless function
        const response = await fetch('/api/get-twitch-vod');
        const data = await response.json();

        if (data.videoId) {
            // Embed the specific Thursday VOD
            container.innerHTML = `<iframe 
                src="https://player.twitch.tv/?video=${data.videoId}&parent=www.toogintv.com&parent=toogintv.com" 
                height="400" 
                width="100%" 
                allowfullscreen>
            </iframe>`;
        } else {
            // Fallback to live channel if no VOD is found
            container.innerHTML = `<iframe 
                src="https://player.twitch.tv/?channel=TooginTV&parent=www.toogintv.com&parent=toogintv.com" 
                height="400" 
                width="100%" 
                allowfullscreen>
            </iframe>`;
        }
    } catch (error) {
        console.error("Error loading VOD from API:", error);
    }
}
}

// --- Karaoke Form Submission Logic ---
function initKaraokeForm() {
    const form = document.getElementById('karaoke-form');
    const statusDiv = document.getElementById('form-status');

    if (form) {
        form.addEventListener('submit', async (e) => {
            e.preventDefault();
            statusDiv.innerHTML = "Submitting request...";
            statusDiv.style.color = "white";

            const payload = {
                submitterName: document.getElementById('submitterName').value,
                artistName: document.getElementById('artistName').value,
                songTitle: document.getElementById('songTitle').value
            };

            try {
                // 'no-cors' mode bypasses browser preflight blocks for Apps Script
                await fetch(CONFIG.KARAOKE_APPS_SCRIPT_URL, {
                    method: 'POST',
                    mode: 'no-cors', 
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(payload)
                });
                
                statusDiv.innerHTML = "Song added to the queue!";
                statusDiv.style.color = "#00ff00";
                form.reset();
            } catch (error) {
                console.error("Error submitting form:", error);
                statusDiv.innerHTML = "Error submitting request. Please try again.";
                statusDiv.style.color = "red";
            }
        });
    }
}

// Initialize scripts
document.addEventListener('DOMContentLoaded', () => {
    initCountdown();
    loadTwitchPlayer();
    initKaraokeForm();
});
