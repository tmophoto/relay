# TurboQuant Desktop

A minimal, single-file local chat UI for [LM Studio](https://lmstudio.ai). No build step, no dependencies — just open `index.html` in a browser.

## Features

- Streaming responses via LM Studio's OpenAI-compatible API
- Multi-model selector (Qwen 35B, Qwen 27B, Nemotron 30B, Qwen 3 Coder 30B, Llama 3.3 70B)
- Four modes with tailored system prompts: Coding, General Chat, Creative Writing, Research
- Adjustable temperature (Precise / Balanced / Creative presets) and max token slider
- Conversation history with sidebar — multiple chats, named from first message
- File attachment button (UI ready for future backend integration)

## Requirements

- [LM Studio](https://lmstudio.ai) running locally with **Local Server** enabled
- Default port: `1234` (configurable in LM Studio settings)
- Any modern browser (Chrome, Firefox, Safari, Edge)

## Usage

1. Open LM Studio and load your model of choice
2. Start the local server (`Local Server` tab → `Start Server`)
3. Open `index.html` in your browser
4. Select a model and mode in the right panel, then start chatting

> The UI connects to `http://localhost:1234/v1/chat/completions`. Make sure LM Studio's server is running before sending a message.

## Models

The model list in the UI is cosmetic — LM Studio always uses whichever model is currently loaded. The model names in the dropdown determine which **system prompt** is applied. Update them in `index.html` under `modelBasePrompts` to match your actual loaded models.

## Customising System Prompts

Edit the `modelBasePrompts` and `modeAppends` objects in the `<script>` block of `index.html`:

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
- The voice input button is UI-only and not yet wired up
- Built for personal local use — not intended for public deployment
