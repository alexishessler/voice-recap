Résume la conversation en cours et lit le résumé à voix haute via ElevenLabs TTS.

Instructions STRICTES :

1. Parse les arguments : $ARGUMENTS
   - Format : `/recap [voix] [portée]`
   - `voix` : `1` = Voix 1 (Jerome), `2` = Voix 2 (Adam). Défaut : `1`
   - `portée` : `all` = toute la conversation. Absent = dernière réponse uniquement.
   - Exemples : `/recap 1` → dernière réponse, voix 1. `/recap 2 all` → toute la session, voix 2.

2. Génère un résumé en respectant ces règles ABSOLUES :
   - Écris comme un collègue qui explique à un autre collègue, à l'oral.
   - JAMAIS de code, de noms de fichiers, de chemins, de commandes.
   - JAMAIS de symboles techniques (~, —, →, `, *, #, |, [], {}).
   - JAMAIS de sigles non épelés. Dire "A P I" pas "API".
   - JAMAIS de listes à puces. Que des phrases complètes et fluides.
   - Les chiffres techniques doivent être traduits en langage naturel (ex : "environ 100 millisecondes" pas "~100ms").
   - Le ton doit être naturel, ni trop formel ni trop familier.
   - Longueur : 3 à 8 phrases selon la complexité. Ni trop court ni trop long.
   - Le résumé doit être autonome : quelqu'un qui n'a pas suivi la conversation doit comprendre l'essentiel.

3. Affiche le résumé à l'utilisateur sous un header "Résumé audio :" (pour qu'il puisse le lire aussi).

4. Ensuite, exécute cette commande Bash (dangerouslyDisableSandbox: true, run_in_background: true) :
   - Si voix = 1 : `printf '%s' 'LE_RÉSUMÉ_GÉNÉRÉ' | /Users/alexishessler/.local/bin/speak --voice jerome --raw`
   - Si voix = 2 : `printf '%s' 'LE_RÉSUMÉ_GÉNÉRÉ' | /Users/alexishessler/.local/bin/speak --voice adam --raw`
   Important : remplace LE_RÉSUMÉ_GÉNÉRÉ par le texte exact du résumé que tu as écrit à l'étape 2. Échappe correctement les guillemets simples dans le texte (remplace ' par '"'"').

5. N'affiche rien d'autre après le lancement de la commande.

RÈGLES :
- Le résumé est en FRANÇAIS.
- NE PAS demander confirmation. Générer et lire immédiatement.
- NE PAS ajouter d'introduction ("Voici le résumé..."). Juste le header puis le texte.
