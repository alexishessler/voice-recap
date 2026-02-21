#!/bin/bash
# VoiceRecap — Install script
set -euo pipefail

BIN="$HOME/.local/bin"
SKHD_DIR="$HOME/.config/skhd"
CLAUDE_DIR="$HOME/.claude/commands"
EL_DIR="$HOME/.config/elevenlabs"
CACHE_DIR="/tmp/elevenlabs-tts-cache"

echo ""
echo "╔═══════════════════════════════════╗"
echo "║       VoiceRecap  Install         ║"
echo "╚═══════════════════════════════════╝"
echo ""

# --- Create directories ---
mkdir -p "$BIN" "$SKHD_DIR" "$CLAUDE_DIR" "$EL_DIR" "$CACHE_DIR"

# --- Check ElevenLabs API key ---
if [ ! -f "$EL_DIR/config" ] || ! grep -q "ELEVENLABS_API_KEY=" "$EL_DIR/config"; then
    echo "⚠  ElevenLabs API key not found."
    read -rp "   Paste your ElevenLabs API key: " API_KEY
    echo "ELEVENLABS_API_KEY=$API_KEY" > "$EL_DIR/config"
    chmod 600 "$EL_DIR/config"
    echo "   → Saved to $EL_DIR/config"
else
    echo "✓  ElevenLabs API key found"
fi

# --- Install scripts ---
cp speak "$BIN/speak"
cp tts-clean "$BIN/tts-clean"
cp speak-voice1 "$BIN/speak-voice1"
cp speak-voice2 "$BIN/speak-voice2"
chmod +x "$BIN/speak" "$BIN/tts-clean" "$BIN/speak-voice1" "$BIN/speak-voice2"
echo "✓  Scripts installed to $BIN/"

# --- Install skhd config ---
if [ -f "$SKHD_DIR/skhdrc" ]; then
    echo "⚠  $SKHD_DIR/skhdrc already exists — skipping (add manually from skhdrc.example)"
    cp skhdrc "$SKHD_DIR/skhdrc.voicerecap.example"
else
    cp skhdrc "$SKHD_DIR/skhdrc"
    echo "✓  skhd config installed"
fi

# --- Install Claude Code skill (optional) ---
if [ -f "$CLAUDE_DIR/recap.md" ]; then
    echo "⚠  $CLAUDE_DIR/recap.md already exists — skipping"
else
    cp commands/recap.md "$CLAUDE_DIR/recap.md"
    echo "✓  Claude Code /recap skill installed"
fi

# --- Configure voice IDs ---
echo ""
echo "━━━  Configure your voices  ━━━"
echo ""
echo "   Run this to list available voices:"
echo ""
echo '   curl -s "https://api.elevenlabs.io/v1/voices" \'
echo '     -H "xi-api-key: $(grep ELEVENLABS_API_KEY ~/.config/elevenlabs/config | cut -d= -f2)" \'
echo '     | python3 -c "import json,sys; [print(v[\"name\"],\"→\",v[\"voice_id\"]) for v in json.load(sys.stdin)[\"voices\"]]"'
echo ""
echo "   Then edit $BIN/speak and replace:"
echo "     VOICE_ADAM=\"YOUR_VOICE_1_ID\""
echo "     VOICE_JEROME=\"YOUR_VOICE_2_ID\""
echo "     VOICE_LAURENT=\"YOUR_VOICE_3_ID\""
echo ""

# --- Start skhd ---
if command -v skhd &>/dev/null; then
    if skhd --start-service 2>/dev/null; then
        echo "✓  skhd started"
    else
        echo "⚠  skhd already running — reload with: skhd --reload"
    fi
    echo ""
    echo "   ⚠  Grant Accessibility permission if prompted:"
    echo "      System Settings > Privacy & Security > Accessibility > skhd"
else
    echo "⚠  skhd not found. Install with:"
    echo "      brew install koekeishiya/formulae/skhd"
    echo "   Then run: skhd --start-service"
fi

echo ""
echo "╔═══════════════════════════════════╗"
echo "║   Done! Test: copy text, then    ║"
echo "║   press Cmd+Option+Y             ║"
echo "╚═══════════════════════════════════╝"
echo ""
