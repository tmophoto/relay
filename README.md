# Relay

A minimal, single-file local chat UI for [LM Studio](https://lmstudio.ai). No build step, no dependencies — just open `index.html` in a browser.

## Features

- Streaming responses via LM Studio's OpenAI-compatible API
- Multi-model selector (Qwen 35B, Qwen 27B, Nemotron 30B, Qwen 3 Coder 30B, Llama 3.3 70B)
- Four modes with tailored system prompts: Coding, General Chat, Creative Writing, Research
- Adjustable temperature (Precise / Balanced / Creative presets) and max token slider
- Conversation history with sidebar — multiple chats, named from first message
- Dark / light theme toggle
- Remote connection support: Direct (LAN IP) or Tailscale (100.x.x.x / MagicDNS)
- Connection test button to verify LM Studio is reachable before chatting
- Host and theme settings persisted in `localStorage`

## Requirements

- [LM Studio](https://lmstudio.ai) running with **Local Server** enabled
- Default port: `1234` (configurable in LM Studio settings)
- **CORS must be enabled** in LM Studio server settings when connecting from a remote machine (LAN or Tailscale)
- Any modern browser (Chrome, Firefox, Safari, Edge)

## Usage

1. Open LM Studio and load your model
2. Start the local server (`Local Server` tab → `Start Server`)
3. Open `index.html` in your browser
4. Set your connection in the top-left panel (Direct or Tailscale), hit **Test** to verify
5. Select a model and mode in the right panel, then start chatting

## Connecting Remotely

### LAN (Direct)
Enter the IP address of the machine running LM Studio (e.g. `192.168.1.206`) and port `1234`. Both machines must be on the same network.

### Tailscale
Install [Tailscale](https://tailscale.com) on both machines. Enter the remote machine's Tailscale IP (`100.x.x.x`) or MagicDNS hostname (`your-desktop.tail12345.ts.net`). Works across different networks.

> Either way, LM Studio must have **Allow CORS** enabled in its server settings.

## Models

The model dropdown is cosmetic — LM Studio always uses whichever model is currently loaded. The names in the dropdown determine which **base system prompt** is applied. Update `modelBasePrompts` in `index.html` to match your loaded models.

## Customising System Prompts

Edit `modelBasePrompts` and `modeAppends` in the `<script>` block of `index.html`:

```js
const modelBasePrompts = {
  'Qwen 35B': 'Your custom base prompt here...',
  ...
};

const modeAppends = {
  'coding': 'Your custom mode instruction here...',
  ...
};
```

## Notes

- Conversations are stored in memory only — refreshing the page clears history
- Built for personal local use — not intended for public deployment
