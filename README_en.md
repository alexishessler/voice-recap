# VoiceRecap

Turn any text into speech with a single keyboard shortcut. Built for developers who want to listen to summaries, documentation, or AI-generated content hands-free.

## What it does

- **Global keyboard shortcuts** that work in every app (VS Code, Chrome, Slack, etc.)
- **Two configurable voices** via ElevenLabs multilingual TTS
- **Automatic text cleanup** for TTS — technical jargon, code symbols, and markdown are converted to natural spoken language
- **Claude Code integration** — a `/recap` skill that summarizes your coding session and reads it aloud

## Quick Start

### 1. Get an ElevenLabs API key

Sign up at [elevenlabs.io](https://elevenlabs.io) and generate an API key in Settings > API Keys.

### 2. Install

```bash
# Install the hotkey daemon
brew install koekeishiya/formulae/skhd

# Create config directories
mkdir -p ~/.config/elevenlabs ~/.config/skhd ~/.local/bin ~/.cache/elevenlabs

# Save your API key
cat > ~/.config/elevenlabs/config << 'EOF'
ELEVENLABS_API_KEY=sk_your_api_key_here
EOF
chmod 600 ~/.config/elevenlabs/config
```

### 3. Find your voice IDs

```bash
curl -s "https://api.elevenlabs.io/v1/voices" \
  -H "xi-api-key: $(grep ELEVENLABS_API_KEY ~/.config/elevenlabs/config | cut -d= -f2)" \
  | python3 -c "
import json, sys
for v in json.load(sys.stdin).get('voices', []):
    labels = v.get('labels', {})
    print(f\"  {v['name']} → {v['voice_id']} | {labels.get('accent','?')} | {labels.get('language','?')}\")
"
```

Pick two voices and note their IDs.

### 4. Configure the scripts

Copy the three scripts to `~/.local/bin/`:

- **`speak`** — Main TTS script (reads clipboard, calls ElevenLabs API, plays audio)
- **`tts-clean`** — Text sanitizer (converts technical text to TTS-friendly language)
- **`speak-voice1`** / **`speak-voice2`** — Wrappers that call `speak` with the right voice

Edit `speak` and replace the voice IDs:

```bash
VOICE_1="your_voice_1_id_here"
VOICE_2="your_voice_2_id_here"
```

Make them executable:

```bash
chmod +x ~/.local/bin/speak ~/.local/bin/tts-clean
chmod +x ~/.local/bin/speak-voice1 ~/.local/bin/speak-voice2
```

### 5. Set up global keyboard shortcuts

```bash
# Create skhd config
cat > ~/.config/skhd/skhdrc << 'EOF'
# VoiceRecap — Global TTS hotkeys
cmd + alt - y : $HOME/.local/bin/speak-voice1 &
cmd + alt - x : $HOME/.local/bin/speak-voice2 &
EOF

# Start skhd (first time: macOS will ask for Accessibility permission — accept it)
skhd --start-service
```

> **Important**: Go to System Settings > Privacy & Security > Accessibility and enable `skhd`.

### 6. Test

1. Copy some text (`Cmd+C`)
2. Press `Cmd+Option+Y` — Voice 1 reads the clipboard
3. Press `Cmd+Option+X` — Voice 2 reads the clipboard

## Usage

### Keyboard shortcuts

| Shortcut | Action |
|---|---|
| `Cmd+Option+Y` | Read clipboard with Voice 1 |
| `Cmd+Option+X` | Read clipboard with Voice 2 |

### Command line

```bash
# Read clipboard with default voice
speak

# Read clipboard with a specific voice
speak --voice voice1
speak --voice voice2

# Read specific text
speak "Hello, this is a test"

# Clean text for TTS (pipe mode)
echo "~100ms latency — 28 FPS via API" | tts-clean
# Output: environ 100 milliseconds of latency, 28 frames per second via A P I
```

### Claude Code skill (`/recap`)

If you use [Claude Code](https://claude.com/claude-code), add the `/recap` skill for AI-powered session summaries:

```bash
cp recap.md ~/.claude/commands/recap.md
```

Then in Claude Code:

```
/recap 1        → Summarize last response, read with Voice 1
/recap 2        → Summarize last response, read with Voice 2
/recap 1 all    → Summarize entire session, read with Voice 1
/recap 2 all    → Summarize entire session, read with Voice 2
```

The skill generates a natural-language summary (no code, no jargon) and reads it aloud.

## How text cleanup works

The `tts-clean` script automatically converts technical text to spoken language:

| Before | After |
|---|---|
| `~100ms` | "environ 100 millisecondes" |
| `333 chars/sec` | "333 caractères par seconde" |
| `28 FPS` | "28 images par seconde" |
| `—` (em dash) | `,` (comma) |
| `API`, `SSE`, `LLM` | "A P I", "S S E", "L L M" |
| Code blocks, URLs, file paths | Removed |
| Markdown formatting | Stripped |

The cleanup happens in two layers:
1. **In the `/recap` skill**: Claude generates text that's already TTS-friendly
2. **In the `speak` script**: `tts-clean` runs as a safety net on any clipboard text

## Files

| File | Location | Role |
|---|---|---|
| `speak` | `~/.local/bin/speak` | Main TTS script |
| `tts-clean` | `~/.local/bin/tts-clean` | Text sanitizer for TTS |
| `speak-voice1` | `~/.local/bin/speak-voice1` | Voice 1 wrapper |
| `speak-voice2` | `~/.local/bin/speak-voice2` | Voice 2 wrapper |
| `config` | `~/.config/elevenlabs/config` | API key (chmod 600) |
| `skhdrc` | `~/.config/skhd/skhdrc` | Global hotkey config |
| `recap.md` | `~/.claude/commands/recap.md` | Claude Code skill (optional) |

## Requirements

- macOS (uses `afplay` for audio playback, `pbpaste` for clipboard)
- [Homebrew](https://brew.sh) (for installing skhd)
- [ElevenLabs](https://elevenlabs.io) account (free tier: 10,000 chars/month)
- Python 3 (pre-installed on macOS)
- `curl` (pre-installed on macOS)

## Customization

### Add more voices

Edit `~/.local/bin/speak` — add entries to the voice mapping:

```bash
voice3) VOICE_ID="new_voice_id"; VOICE_NAME="Voice3" ;;
```

Create a wrapper: `echo '#!/bin/bash' > ~/.local/bin/speak-voice3 && echo 'exec "$HOME/.local/bin/speak" --voice voice3 "$@"' >> ~/.local/bin/speak-voice3 && chmod +x ~/.local/bin/speak-voice3`

Add a hotkey in `~/.config/skhd/skhdrc`:

```
cmd + alt - z : $HOME/.local/bin/speak-voice3 &
```

Reload: `skhd --reload`

### Change the TTS model

Edit the `MODEL_ID` variable in `speak`:

```bash
MODEL_ID="eleven_multilingual_v2"     # Best quality, all languages
MODEL_ID="eleven_flash_v2_5"          # Faster, good quality
MODEL_ID="eleven_turbo_v2_5"          # Fastest, lower quality
```

### Add TTS cleanup rules

Edit `~/.local/bin/tts-clean` — add regex patterns to the `clean_for_tts()` function.

## Troubleshooting

**Shortcuts don't work?**
→ Check that `skhd` has Accessibility permission: System Settings > Privacy & Security > Accessibility

**No audio?**
→ Test manually: `echo "test" | pbcopy && speak`
→ Check your API key: `cat ~/.config/elevenlabs/config`

**Audio sounds robotic?**
→ Switch to `eleven_multilingual_v2` model (slower but higher quality)

**skhd not running?**
→ `skhd --start-service` or `brew services start skhd`

## License

MIT
