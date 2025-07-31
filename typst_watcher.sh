#!/bin/bash

declare -A watched

mkdir -p /typstfiles 
mkdir -p /pdf
mkdir -p /typsterrors

while true; do
	declare -A new_watched

	while read -r id; do
		if [[ "$id" = "" ]]; then
			continue
		fi
		filepath="/typstfiles/$id.typ"
		echo "running $id, filepath = $filepath"
		sqlite3 -cmd ".timeout 5000" /sqldata/db.sqlite <<< "select text from document where id = '$id';" > "$filepath"
		if [[ "${watched[$id]}" = "" ]]; then
			typst watch "$filepath" "/pdf/$id.pdf" 2>"/typsterrors/$id.txt" &
			new_watched[$id]=$!
		else
			new_watched[$id]="${watched[$id]}"
		fi
	done <<< $(sqlite3 -cmd ".timeout 5000" /sqldata/db.sqlite <<< "select id from document;")
	for key in "${!watched[@]}"; do
		if [[ ${new_watched[$key]} = "" ]]; then
			kill ${watched[$key]}
			rm "/pdf/$key.pdf"
		fi
	done
	unset watched
	declare -A watched
	for key in "${!new_watched[@]}"; do
		watched[$key]=${new_watched[$key]}
	done
	sleep 1
done
