#!/bin/bash

while read ligne
do
    prenom=$(echo "$ligne" | cut -d: -f1)
    nom=$(echo "$ligne" | cut -d: -f2)
    groupes=$(echo "$ligne" | cut -d: -f3)
    sudo=$(echo "$ligne" | cut -d: -f4)
    apps=$(echo "$ligne" | cut -d: -f5)
    pwd=$(echo "$ligne" | cut -d: -f6)

    if [ -z "$prenom" ] || [ -z "$nom" ]; then
        continue
    fi

    login=${prenom:0:1}$nom
    nb=1
    while id "$login" > /dev/null 2>&1; do
        login=${prenom:0:1}${nom}${nb}
        nb=$((nb + 1))
    done

    echo "Création de l'utilisateur $login"

    for grp in $(echo "$groupes" | tr ',' ' '); do
        echo "Ajout du groupe $grp"
        groupadd "$grp" 2>/dev/null
    done

    if [ -z "$groupes" ]; then
        groupe_primaire=$login
        groupadd "$groupe_primaire" 2>/dev/null
    else
        groupe_primaire=$(echo "$groupes" | cut -d, -f1)
    fi

    useradd -m -c "$prenom $nom" -g "$groupe_primaire" "$login" 2>/dev/null

    for grp in $(echo "$groupes" | tr ',' ' '); do
        usermod -aG "$grp" "$login" 2>/dev/null
    done

    if [ "$sudo" = "oui" ]; then
        echo "Ajout des droits sudo pour $login"
        usermod -aG sudo "$login"
    fi

    echo "Configuration du mot de passe pour $login"
    echo "$login:$pwd" | chpasswd
    chage -d 0 "$login"

    if [ -n "$apps" ]; then
        for app in $(echo "$apps" | tr '/' ' '); do
            if which "$app" > /dev/null 2>&1; then
                echo "$app est déjà installé"
            else
                apt-get install -y "$app" > /dev/null 2>&1
                if [ $? -eq 0 ]; then
                    echo "Installation de $app réussie"
                else
                    echo "Échec de l'installation de $app"
                fi
            fi
        done
    fi

    nbfiles=$((RANDOM % 6 + 5))
    for i in $(seq 1 $nbfiles); do
        size=$((RANDOM % 46 + 5))
        dd if=/dev/urandom of="/home/$login/file$i" bs=1M count=$size 2>/dev/null
    done

done < data/users.txt
