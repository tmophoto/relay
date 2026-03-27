# Relay

A minimal, single-file local chat UI for [LM Studio](https://lmstudio.ai). No build step, no server, no dependencies — open `index.html` in Chrome and start chatting.

> **Chrome only.** File System Access API (used for saving chats to disk) is not supported in Firefox or Safari.

---

## Features

- Streaming responses via LM Studio's OpenAI-compatible API
- Multi-model selector with per-model system prompts
- Four chat modes: Coding, General Chat, Creative Writing, Research
- Temperature control with Precise / Balanced / Creative presets
- Max tokens slider (256 – 8192)
- Multiple conversations with sidebar history, named from first message
- Dark / light theme toggle
- **Chat persistence** — conversations survive page reloads via `localStorage`, with optional sync to a folder on disk as individual JSON files
- Remote connection support: Direct (LAN IP) or Tailscale (100.x.x.x / MagicDNS)
- Connection test button to verify LM Studio is reachable before chatting
- All settings (host, theme, connection type) persisted across sessions

---

## Requirements

- **Chrome** (required for folder-based chat saving)
- [LM Studio](https://lmstudio.ai) running with **Local Server** enabled
- Default port: `1234` (configurable in LM Studio settings)
- **CORS must be enabled** in LM Studio server settings — required for any browser-based client

---

## Setup

1. Open LM Studio and load your model
2. Go to the **Local Server** tab → enable **Allow CORS** → click **Start Server**
3. Open `index.html` in Chrome
4. Set your connection in the sidebar (Direct or Tailscale) and hit **Test** to verify
5. Optionally set a save folder (see below)
6. Select a model and mode in the right panel, then start chatting

---

## Chat Storage

Relay uses two layers of storage:

### localStorage (automatic)
Conversations are saved to browser `localStorage` after every AI response. No setup needed. Chats survive page reloads and browser restarts but are tied to the browser profile.

### Folder sync (optional)
Save chats as JSON files to any folder on your machine — recommended: `Documents/relay_chats`.

1. In the sidebar, click **Set folder**
2. Chrome will open a folder picker — navigate to (or create) your `relay_chats` folder in Documents and select it
3. All current and future conversations are saved as `{id}.json` files in that folder
4. On next load, if permission is still active, chats are read back from the folder automatically

> On each new browser session, Chrome may prompt you to re-grant folder access. This is a browser security requirement and cannot be bypassed.

To stop syncing to a folder, click the **✕** button next to the folder name in the sidebar.

---

## Connecting Remotely

### LAN (Direct)
Enter the IP of the machine running LM Studio (e.g. `192.168.1.x`) and port `1234`. Both machines must be on the same network.

### Tailscale
Install [Tailscale](https://tailscale.com) on both machines. Enter the remote machine's Tailscale IP (`100.x.x.x`) or MagicDNS hostname (e.g. `your-desktop.tail12345.ts.net`). Works from any network.

> Both methods require **Allow CORS** enabled in LM Studio server settings.

---

## Models

The model names in the dropdown are display labels — LM Studio always uses whichever model is currently loaded. Each name maps to a base system prompt in `modelBasePrompts`. Update these to match your actual loaded models.

| Display Name      | Default use             |
|-------------------|-------------------------|
| Qwen 35B          | Reasoning + general     |
| Qwen 27B          | General (default)       |
| Nemotron 30B      | Reasoning / analysis    |
| Qwen 3 Coder 30B  | Code                    |
| Llama 3.3 70B     | General                 |

---

## Customising System Prompts

Edit `modelBasePrompts` and `modeAppends` in the `<script>` block of `index.html`:

```js
const modelBasePrompts = {
  'Qwen 35B': 'Your custom base prompt...',
};

const modeAppends = {
  'coding': 'Your custom mode instruction...',
};
```

The final system prompt sent to LM Studio is `basePrompt + "\n\n" + modeAppend`.

---

## Security

- No API keys, credentials, or personal data are stored or transmitted
- All requests go directly from your browser to your local LM Studio instance
- No external services, analytics, or network calls of any kind
- User input is HTML-escaped before rendering

---

## Notes

- Built for personal local use — not intended for public deployment
- Single `index.html` file — no build tools, npm, or runtime dependencies
- File attachment UI exists but files are not yet sent to the API (placeholder for future multimodal support)
