#!/bin/bash

USERFILE="data/users.txt"

if [ ! -f "$USERFILE" ]; then
    echo "Fichier $USERFILE introuvable."
    exit 1
fi

while IFS=: read -r prenom nom groupes sudo apps password
do
    [ -z "$prenom" ] || [ -z "$nom" ] && continue

    base_login=$(echo "${prenom:0:1}$nom" | tr '[:upper:]' '[:lower:]')

    for user in $(getent passwd | cut -d: -f1); do
        if [[ "$user" == "$base_login" || "$user" =~ ^${base_login}[0-9]+$ ]]; then
            pkill -u "$user" 2>/dev/null
            userdel -r "$user" 2>/dev/null && echo "Utilisateur $user supprimé."
        fi
    done

done < "$USERFILE"
