#!/bin/bash

if test "$1" = "-u"
then
    echo "Recherche des fichiers SUID"
    find / -perm -4000 > data/nouvelle_liste.txt 2>/dev/null
elif test "$1" = "-g"
then
    echo "Recherche des fichiers SGID"
    find / -perm -2000 > data/nouvelle_liste.txt 2>/dev/null
else
    echo "Recherche des fichiers SUID et SGID"
    find / -perm -4000 -o -perm -2000 > data/nouvelle_liste.txt 2>/dev/null
fi

if test -f data/suid_list.txt
then
    echo "Comparaison avec l'ancienne liste..."
    if diff data/suid_list.txt data/nouvelle_liste.txt
    then
        echo "Aucune modification"
    else
        echo "ATTENTION : Modifications détectées"
        echo "Dates des fichiers modifiés :"
        ls -l $(diff data/suid_list.txt data/nouvelle_liste.txt | grep "^[<>]" | cut -d" " -f2)
    fi
fi

mv data/nouvelle_liste.txt data/suid_list.txt
