# Relay — Mobile App Feature Specification

A local-first LM Studio chat client. All inference runs on a self-hosted machine; the mobile app is purely a UI that talks to the LM Studio HTTP server.

---

## Architecture Overview

- **No backend.** The app communicates directly with LM Studio's OpenAI-compatible REST API.
- **API base:** `http://<host>:<port>/v1`
- **Endpoints used:**
  - `POST /v1/chat/completions` — send messages, receive streaming responses
  - `GET /v1/models` — used only for connection testing
- **Auth:** None. LM Studio runs unauthenticated on the local network.
- **Streaming:** Server-Sent Events (SSE). Response body is a stream of `data: {...}` lines, terminated by `data: [DONE]`.

---

## Connection

Two connection modes, selectable by the user:

### Direct (LAN)
- User enters a host IP (e.g. `192.168.1.206`) and port (default `1234`).
- Used when phone and server are on the same Wi-Fi network.

### Tailscale (Remote)
- User enters a Tailscale IP (`100.x.x.x`) or MagicDNS hostname (e.g. `desktop.ts.net`) and port.
- Used when accessing the server remotely over Tailscale VPN.
- No special handling needed — it's just a different host address.

### Connection Test
- Tapping "Test" hits `GET /v1/models` with a 4-second timeout.
- Shows one of: `Connected · host:port` (green), `Error <status>` (red), `Timed out` (red), `Unreachable` (red).
- Status resets to "Not tested" whenever host/port fields change.

### Persistence
- Host, port, Tailscale host/port, and active connection type are all saved to persistent storage (localStorage on web, AsyncStorage/UserDefaults on mobile).

---

## Models

Five hardcoded models (can be extended):

| Display Name      | Meta                          |
|-------------------|-------------------------------|
| Qwen 35B          | Opus · reasoning + general    |
| Qwen 27B          | general · q4_k_m *(default)*  |
| Nemotron 30B      | reasoning distilled · q4_k_m  |
| Qwen 3 Coder 30B  | code specialist · q4_k_m      |
| Llama 3.3 70B     | general · q3_k_m              |

- Selected model is displayed in the top bar alongside the connection status.
- The model field sent to the API is always `"local-model"` — LM Studio ignores it and uses whatever model is loaded.

---

## System Prompt

Built at send time by concatenating two strings:

```
<model base prompt>

<mode append>
```

### Model base prompts

| Model             | Prompt |
|-------------------|--------|
| Qwen 35B          | You are a highly capable reasoning model running locally. Think step by step before answering. Be direct and avoid sycophantic openers. When uncertain, say so clearly. |
| Qwen 27B          | You are a capable and efficient general-purpose model. Be clear and concise. Think through problems methodically. Avoid unnecessary verbosity. |
| Nemotron 30B      | You are a reasoning-distilled model optimized for logical analysis. Show your reasoning process. Be concise and precise. Avoid unnecessary filler or flattery. |
| Qwen 3 Coder 30B  | You are a code-specialized model. Default to producing working, well-commented code. Explain your implementation decisions. Prefer practical solutions over theoretical ones. |
| Llama 3.3 70B     | You are a large general-purpose model. Be thorough and balanced. Draw on broad knowledge. Avoid being overly verbose — prioritize clarity over length. |

### Mode appends

| Mode             | Append |
|------------------|--------|
| Coding           | You are in coding mode — produce clean, working code with brief explanations. Use code blocks. Point out edge cases. |
| General chat     | You are in general chat mode — be conversational, warm, and concise. Match the tone of the user. *(default)* |
| Creative writing | You are in creative writing mode — use vivid, expressive language. Prioritize narrative flow and originality over correctness. |
| Research         | You are in research mode — provide thorough, well-structured responses with clear reasoning. Cite uncertainty where relevant. |

---

## Chat / Conversations

- Multiple conversations stored in memory (session only — not persisted across app restarts in the current desktop version; mobile could add persistence).
- Each conversation has: `id` (timestamp string), `title` (auto-set from first message, max 38 chars + ellipsis), `messages` array.
- Full message history is sent with every request (no summarisation or trimming).
- New conversation created automatically if none is active when a message is sent.

### Message format sent to API
```json
{
  "model": "local-model",
  "messages": [
    {"role": "system", "content": "<built system prompt>"},
    {"role": "user", "content": "..."},
    {"role": "assistant", "content": "..."},
    ...
  ],
  "temperature": 0.60,
  "max_tokens": 1024,
  "stream": true
}
```

### Streaming response handling
- Parse SSE stream line by line.
- Each line starting with `data: ` contains a JSON chunk.
- Extract `choices[0].delta.content` and append to the displayed bubble in real time.
- Skip `data: [DONE]`.

### Error handling
- If fetch fails (network error): show message "Could not connect to LM Studio. Make sure it's running on port 1234 with server mode enabled."
- Other errors: show "Error: \<message\>".

---

## Parameters

### Temperature
- Range: 0.0 – 1.0, step 0.01
- Default: 0.60
- Three quick-select presets:
  - **Precise** → 0.1
  - **Balanced** → 0.6 *(default)*
  - **Creative** → 0.9

### Max Tokens
- Range: 256 – 8192, step 256
- Default: 1024

---

## UI Sections

### Top Bar
- Connection status pill (pulsing dot + "Ready" / "Thinking…" text, dot turns amber when busy)
- Active model name
- Theme toggle button (dark/light)
- Clear chat button

### Sidebar / Navigation
- LM Studio host config (connection type tabs + host/port inputs + test button)
- New conversation button
- Conversation history list (title + date, tap to switch)

### Chat Area
- Welcome screen with suggestion chips when no messages exist
- Message bubbles (user right-aligned, assistant left-aligned)
- Timestamps on each message
- Thinking indicator (three bouncing dots) while waiting for response

### Suggestion Chips (Welcome Screen)
- "Analyze a dataset"
- "Write some code"
- "Research a topic"
- "Draft a document"

### Composer
- Auto-expanding textarea (max height ~200px equivalent)
- Attach file button (opens file picker)
- Send button
- Keyboard hint: Enter to send, Shift+Enter for newline

### Right Panel / Settings Sheet
- Model selector (dropdown/picker)
- Temperature slider + preset tabs
- Max tokens slider
- Mode selector (Coding / General chat / Creative writing / Research)
- Attachments upload zone
- Active system prompt preview (read-only, shows current model + mode label and full prompt text)

---

## Theme

Two themes. Accent colour shifts slightly between modes.

### Dark (default)
| Token         | Value                        |
|---------------|------------------------------|
| bg            | `#111113`                    |
| bg2           | `#18181b`                    |
| bg3           | `#1c1c1f`                    |
| bg4           | `#242428`                    |
| bg5           | `#2a2a2f`                    |
| text1         | `#f5f5f7`                    |
| text2         | `rgba(245,245,247,0.55)`     |
| text3         | `rgba(245,245,247,0.28)`     |
| accent        | `#34d399`                    |
| accent-dim    | `rgba(52,211,153,0.12)`      |
| accent-dim2   | `rgba(52,211,153,0.07)`      |

### Light
| Token         | Value                        |
|---------------|------------------------------|
| bg            | `#f5f5f7`                    |
| bg2           | `#ffffff`                    |
| bg3           | `#f0f0f2`                    |
| bg4           | `#e8e8ec`                    |
| bg5           | `#dddde3`                    |
| text1         | `#111113`                    |
| text2         | `rgba(17,17,19,0.6)`         |
| text3         | `rgba(17,17,19,0.35)`        |
| accent        | `#059669`                    |
| accent-dim    | `rgba(5,150,105,0.1)`        |
| accent-dim2   | `rgba(5,150,105,0.06)`       |

Theme preference persisted to storage under key `relay-theme`.

---

## Storage Keys

| Key                | Value                          |
|--------------------|--------------------------------|
| `relay-host`       | Direct host IP                 |
| `relay-port`       | Direct port                    |
| `relay-ts-host`    | Tailscale host                 |
| `relay-ts-port`    | Tailscale port                 |
| `relay-conn-type`  | `"direct"` or `"tailscale"`   |
| `relay-theme`      | `"light"` or `"dark"`         |

---

## Security Notes

- No API keys, credentials, or personal data are stored or transmitted.
- All requests go directly to the local LM Studio server — nothing passes through any external service.
- Chat history is in-memory only (not written to disk in the current version).
- User input is HTML-escaped before rendering to prevent XSS.
- LM Studio requires **CORS enabled** in its server settings when connecting from a browser-based client (including WebView). Without it, all requests will be blocked silently.

---

## Known Limitations / Mobile Considerations

- **No chat persistence** — conversations are lost on app close. Mobile should add SQLite or AsyncStorage persistence.
- **No markdown rendering** — assistant responses are plain text with newlines converted to line breaks. Mobile could add a markdown renderer.
- **File attachments are UI-only** — the file picker exists but attached files are not currently sent to the API. Would need base64 encoding + multimodal model support to implement properly.
- **No conversation rename/delete** — only clear (wipes messages) exists. Mobile should add swipe-to-delete and tap-to-rename.
- **HTTP only** — LM Studio does not serve HTTPS. On iOS/Android, ensure App Transport Security / Network Security Config allows plain HTTP to local IPs and Tailscale ranges.
