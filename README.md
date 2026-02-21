# VoiceRecap

Transforme n'importe quel texte en audio avec un simple raccourci clavier. Conçu pour les développeurs qui veulent écouter des résumés, de la documentation ou du contenu généré par IA en mode mains-libres.

> 🇬🇧 [English version](README_en.md)

## Ce que ça fait

- **Raccourcis clavier globaux** qui fonctionnent partout (VS Code, Chrome, Slack, terminal, etc.)
- **Deux voix configurables** via la synthèse vocale multilingue ElevenLabs
- **Nettoyage automatique du texte** pour la TTS — le jargon technique, les symboles de code et le markdown sont convertis en langage naturel parlé
- **Intégration Claude Code** — une compétence `/recap` qui résume ta session de code et la lit à voix haute

## Installation rapide

### 1. Obtenir une clé API ElevenLabs

Crée un compte sur [elevenlabs.io](https://elevenlabs.io) et génère une clé dans Paramètres > Clés API.

### 2. Installer

```bash
# Installer le daemon de raccourcis clavier
brew install koekeishiya/formulae/skhd

# Créer les répertoires de configuration
mkdir -p ~/.config/elevenlabs ~/.config/skhd ~/.local/bin ~/.cache/elevenlabs

# Enregistrer ta clé API
cat > ~/.config/elevenlabs/config << 'EOF'
ELEVENLABS_API_KEY=sk_ta_clé_api_ici
EOF
chmod 600 ~/.config/elevenlabs/config
```

### 3. Trouver tes IDs de voix

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

Choisis deux voix et note leurs IDs.

### 4. Configurer les scripts

Clone le repo et copie les scripts dans `~/.local/bin/` :

```bash
git clone https://github.com/alexishessler/voice-recap.git
cd voice-recap
chmod +x install.sh
./install.sh
```

Puis édite `~/.local/bin/speak` et remplace les IDs de voix :

```bash
VOICE_ADAM="ton_id_voix_1_ici"
VOICE_JEROME="ton_id_voix_2_ici"
VOICE_LAURENT="ton_id_voix_3_ici"
```

### 5. Configurer les raccourcis clavier globaux

```bash
# Le fichier skhdrc est déjà installé par install.sh
# Démarre skhd (au premier lancement, macOS demande la permission Accessibilité)
skhd --start-service
```

> **Important** : Aller dans Réglages Système > Confidentialité et sécurité > Accessibilité et activer `skhd`.

### 6. Tester

1. Copie du texte (`Cmd+C`)
2. Appuie sur `Cmd+Option+Y` — la Voix 1 lit le presse-papiers
3. Appuie sur `Cmd+Option+X` — la Voix 2 lit le presse-papiers

## Utilisation

### Raccourcis clavier

| Raccourci | Action |
|---|---|
| `Cmd+Option+Y` | Lire le presse-papiers avec la Voix 1 |
| `Cmd+Option+X` | Lire le presse-papiers avec la Voix 2 |

### Ligne de commande

```bash
# Lire le presse-papiers avec la voix par défaut
speak

# Lire le presse-papiers avec une voix spécifique
speak --voice jerome
speak --voice adam

# Lire un texte précis
speak "Bonjour, ceci est un test"

# Nettoyer du texte pour la TTS (mode pipe)
echo "~100ms de latence — 28 FPS via API" | tts-clean
# Résultat : environ 100 millisecondes de latence, 28 images par seconde via A P I
```

### Compétence Claude Code (`/recap`)

Si tu utilises [Claude Code](https://claude.com/claude-code), ajoute la compétence `/recap` pour des résumés de session générés par IA :

```bash
cp commands/recap.md ~/.claude/commands/recap.md
```

Ensuite dans Claude Code :

```
/recap 1        → Résume la dernière réponse, lu avec la Voix 1
/recap 2        → Résume la dernière réponse, lu avec la Voix 2
/recap 1 all    → Résume toute la session, lu avec la Voix 1
/recap 2 all    → Résume toute la session, lu avec la Voix 2
```

La compétence génère un résumé en langage naturel (sans code, sans jargon) et le lit à voix haute.

## Comment fonctionne le nettoyage du texte

Le script `tts-clean` convertit automatiquement le texte technique en langage parlé :

| Avant | Après |
|---|---|
| `~100ms` | "environ 100 millisecondes" |
| `333 chars/sec` | "333 caractères par seconde" |
| `28 FPS` | "28 images par seconde" |
| `—` (tiret em) | `,` (virgule) |
| `API`, `SSE`, `LLM` | "A P I", "S S E", "L L M" |
| Blocs de code, URLs, chemins de fichiers | Supprimés |
| Formatage Markdown | Nettoyé |

Le nettoyage se fait en deux couches :
1. **Dans la compétence `/recap`** : Claude génère un texte déjà adapté à la TTS
2. **Dans le script `speak`** : `tts-clean` tourne en filet de sécurité pour tout texte lu depuis le presse-papiers

## Fichiers

| Fichier | Emplacement | Rôle |
|---|---|---|
| `speak` | `~/.local/bin/speak` | Script TTS principal |
| `tts-clean` | `~/.local/bin/tts-clean` | Nettoyeur de texte pour la TTS |
| `speak-voice1` | `~/.local/bin/speak-voice1` | Wrapper Voix 1 |
| `speak-voice2` | `~/.local/bin/speak-voice2` | Wrapper Voix 2 |
| `config` | `~/.config/elevenlabs/config` | Clé API (chmod 600) |
| `skhdrc` | `~/.config/skhd/skhdrc` | Config raccourcis clavier globaux |
| `recap.md` | `~/.claude/commands/recap.md` | Compétence Claude Code (optionnel) |

## Prérequis

- macOS (utilise `afplay` pour la lecture audio, `pbpaste` pour le presse-papiers)
- [Homebrew](https://brew.sh) (pour installer skhd)
- Compte [ElevenLabs](https://elevenlabs.io) (offre gratuite : 10 000 caractères/mois)
- Python 3 (préinstallé sur macOS)
- `curl` (préinstallé sur macOS)

## Personnalisation

### Ajouter d'autres voix

Édite `~/.local/bin/speak` — ajoute des entrées dans le mapping des voix :

```bash
voice3) VOICE_ID="nouvel_id_voix"; VOICE_NAME="Voice3" ;;
```

Crée un wrapper :
```bash
echo '#!/bin/bash' > ~/.local/bin/speak-voice3
echo 'exec "$HOME/.local/bin/speak" --voice voice3 "$@"' >> ~/.local/bin/speak-voice3
chmod +x ~/.local/bin/speak-voice3
```

Ajoute un raccourci dans `~/.config/skhd/skhdrc` :

```
cmd + alt - z : $HOME/.local/bin/speak-voice3 &
```

Puis recharge : `skhd --reload`

### Changer le modèle TTS

Édite la variable `MODEL_ID` dans `speak` :

```bash
MODEL_ID="eleven_multilingual_v2"     # Meilleure qualité, toutes langues (recommandé)
MODEL_ID="eleven_flash_v2_5"          # Plus rapide, bonne qualité
MODEL_ID="eleven_turbo_v2_5"          # Le plus rapide, qualité réduite
```

### Ajouter des règles de nettoyage TTS

Édite `~/.local/bin/tts-clean` — ajoute des patterns regex dans la fonction `clean_for_tts()`.

## Résolution de problèmes

**Les raccourcis ne fonctionnent pas ?**
→ Vérifier que `skhd` a la permission Accessibilité : Réglages Système > Confidentialité et sécurité > Accessibilité

**Pas d'audio ?**
→ Tester manuellement : `echo "test" | speak`
→ Vérifier ta clé API : `cat ~/.config/elevenlabs/config`

**L'audio sonne robotique ?**
→ Passer au modèle `eleven_multilingual_v2` (plus lent mais meilleure qualité)

**skhd ne tourne pas ?**
→ `skhd --start-service` ou `brew services start skhd`

## Licence

MIT
