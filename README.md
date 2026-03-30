# Relay

A single-file local chat UI for [vLLM](https://github.com/vllm-project/vllm). No build step, no server, no npm — open `index.html` in Chrome and start chatting.

> **Chrome recommended.** The File System Access API (used for saving chats to disk) requires Chrome. The rest of the UI works in any modern browser.

---

## Features

- **Streaming responses** via vLLM's OpenAI-compatible API (`/v1/chat/completions`)
- **Live model detection** — reads the active model from `/v1/models` on load and every 30 seconds
- **Markdown rendering** with syntax-highlighted code blocks (marked.js + Prism.js, loaded from CDN)
- **Four chat modes** — General Chat, Coding, Creative Writing, Research (each tunes the system prompt)
- **Temperature control** with Precise / Balanced / Creative presets and a fine-grain slider
- **Max tokens slider** (256 – 8 192)
- **File attachments** — attach images for vision models, or paste in code/text files as context
- **Stop generation** — cancel a response mid-stream
- **Copy buttons** on every message (yours and the AI's)
- **Edit & resend** — click the pencil on any of your messages to edit it and re-run from that point
- **Token stats** on every response: total tokens, tokens/sec, elapsed time
- **Context ring** — circular arc indicator in the composer showing how much of the 32 768-token context window is used; hover for a detailed breakdown
- **Session token counter** in the topbar (persisted across reloads)
- **Conversation history** in the sidebar — named from your first message, with per-chat delete
- **Conversation rename** — double-click any title in the sidebar to rename it inline
- **Chat persistence** — `localStorage` by default; optionally sync to a folder on disk as JSON files
- **Dark / light theme** toggle
- **Mobile / PWA ready** — responsive layout with safe-area support for iPhone notch/home bar; add to Home Screen for a native feel
- **Remote access** — works over LAN or Tailscale

---

## Requirements

- **Chrome** (recommended; required for folder-based chat saving)
- [vLLM](https://github.com/vllm-project/vllm) running and serving a model on `localhost:8000`
- Internet connection for CDN assets (marked.js, Prism.js) on first load — or serve the file locally

---

## Quick start

### Windows (startup.bat)

A `startup.bat` is included to launch vLLM and a local file server together:

```bat
startup.bat
```

This opens two WSL terminals — one running vLLM, one running a Python HTTP server on port 3000. Then open `http://localhost:3000` in Chrome.

### Manual

1. Start vLLM:
   ```bash
   vllm serve /path/to/your/model --port 8000
   ```
2. Serve `index.html` with any static file server, e.g.:
   ```bash
   python3 -m http.server 3000
   ```
3. Open `http://localhost:3000` in Chrome
4. Enter your host/port in the right panel → **Test** to verify the connection
5. Start chatting

---

## Chat modes

Relay ships with four modes selectable from the right panel. Each appends a short instruction to the system prompt:

| Mode             | Tuned for                                      |
|------------------|------------------------------------------------|
| General Chat     | Conversational, balanced responses             |
| Coding           | Code output, minimal prose, technical accuracy |
| Creative Writing | Vivid, expressive, narrative-focused           |
| Research         | Structured, cited-style, analytical            |

To add or edit modes, update `modeAppends` in the `<script>` block of `index.html`.

---

## File attachments

Click the paperclip icon (or drag and drop onto the chat area) to attach files.

- **Images** (jpg, png, gif, webp, etc.) — sent in vision format; requires a multimodal model
- **Text / code files** (`.txt`, `.md`, `.py`, `.js`, `.ts`, `.json`, `.yaml`, and more) — pasted as context before your message

---

## Context ring

After each response, a small circular arc appears in the composer toolbar showing the percentage of the 32 768-token context window consumed. Hover it for a breakdown:

- Current conversation tokens
- Total context window size
- % used / % remaining

The arc turns **amber** above 70% and **red** above 90%.

---

## Chat storage

### localStorage (automatic)
Conversations are saved to browser `localStorage` after every response. No setup needed.

### Folder sync (optional)
Save chats as JSON files to any local folder:

1. Click **Set folder** at the bottom of the sidebar
2. Pick or create a folder (e.g. `Documents/relay_chats`)
3. All conversations are saved as `{id}.json` files and reloaded automatically on next visit

> Chrome may prompt you to re-grant folder access on each new browser session — this is a browser security requirement.

Click **✕** next to the folder name to stop syncing.

---

## Remote access

### LAN
Enter the LAN IP of the machine running vLLM (e.g. `192.168.1.x`) and port `8000`.

### Tailscale
Install [Tailscale](https://tailscale.com) on both machines. Enter the Tailscale IP (`100.x.x.x`) or MagicDNS hostname. Works from any network, including mobile.

---

## Security

- No API keys, credentials, or analytics — ever
- All requests go directly from your browser to your local vLLM instance
- No external network calls except CDN assets (marked.js, Prism.js) on load
- User input is HTML-escaped before rendering

---

## Notes

- Single `index.html` file — no build tools, no npm, no runtime dependencies
- Built for personal local use; not intended for public deployment
- Default model ID is hardcoded as `qwen3.5-27b` in `sendMessage` — change this to match whatever model you're serving
