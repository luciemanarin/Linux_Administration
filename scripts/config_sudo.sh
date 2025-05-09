#!/bin/bash

rm -f /etc/sudoers.d/custom

while read ligne
do
    login=$(echo $ligne | cut -d: -f1)
    machines=$(echo $ligne | cut -d: -f2)
    commandes=$(echo $ligne | cut -d: -f3)

    if ! groups $login | grep -q sudo
    then
        echo "$login n'est pas sudoer"
        continue
    fi

    echo "Configuration sudo pour $login..."

    for cmd in $(echo $commandes | tr "," " ")
    do
        if test "$machines" = "ALL"
        then
            echo "$login ALL = $cmd" >> /etc/sudoers.d/custom
        else
            for machine in $(echo $machines | tr "," " ")
            do
                echo "$login $machine = $cmd" >> /etc/sudoers.d/custom
            done
        fi
    done
done < data/sudo_rules.txt

chmod 440 /etc/sudoers.d/custom
