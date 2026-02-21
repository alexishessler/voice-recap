#!/bin/bash
# VoiceRecap — Uninstall script
set -euo pipefail

BIN="$HOME/.local/bin"
SKHD_DIR="$HOME/.config/skhd"
CLAUDE_DIR="$HOME/.claude/commands"

echo ""
echo "Uninstalling VoiceRecap..."

rm -f "$BIN/speak" "$BIN/tts-clean" "$BIN/speak-voice1" "$BIN/speak-voice2"
rm -f "$SKHD_DIR/skhdrc.voicerecap.example"
rm -f "$CLAUDE_DIR/recap.md"

echo "✓  Scripts removed"
echo ""
echo "Kept: ~/.config/elevenlabs/config (API key)"
echo "Kept: ~/.config/skhd/skhdrc (reload with: skhd --reload)"
echo ""
echo "To fully remove skhd: brew services stop skhd && brew uninstall skhd"
echo ""
