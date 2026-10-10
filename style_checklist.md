# TooginTV Style Checklist & Changelog

## Core Brand Identity
* **Primary Palette**: 
  * Toogin Cyan (`#4ce0e4`)
  * Toogin Pink (`#eb74ab`)
  * Deep Black (`#000000`) for dark mode contrast.
* **Typography**: `'Courier New', Courier, monospace` (Maintains the raw, technical, terminal-like aesthetic).
* **Texture**: Heavy TV-Static SVG noise filter. Must remain prominent to mimic the distressed logo.
* **Logo Asset**: `pink and blue.png` (or `black and pink.png` depending on active theme).

## Design Principles & Security
1. **Preservation**: Never alter historical page copy or established Toogin-jamming descriptions unless explicitly requested.
2. **Security**: All text inputs (Karaoke form) must be sanitized. SQL injection/XSS vectors minimized by relying on Vercel backend APIs.
3. **API Keys**: Calendar and Twitch keys must strictly reside in Vercel environment variables, never in client-side JS.

## Changelog
* **2026-10-09**: Initialized checklist. Locked in Cyan/Pink grunge aesthetic. Diagnosed hidden-tab rendering bugs for Twitch and TikTok embeds. Implemented lazy-loading lifecycle patch.
