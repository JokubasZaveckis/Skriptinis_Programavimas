#!/usr/bin/env bash

# Nustatomas useris
if [ -n "$1" ]; then
    target_user="$1"
    only_one_user=true
else
    target_user="$(whoami)"
    only_one_user=false
fi

# Sukuriamas folderis
timestamp_dir="$(date +%Y%m%d-%H%M%S)"
dir="process-logs-$timestamp_dir"
mkdir -p "$dir"

# Sukuriamas useriu sarasas
if [ "$only_one_user" = true ]; then
    users=("$target_user")
else
    mapfile -t users < <(ps -eo user= | sort -u)
fi

total_lines=0
declare -a log_files

# Failu formatai pagal data ir laika
date_str="$(date +%Y%m%d)"
time_str="$(date +%H%M%S)"

# Iteruojama per kiekviena naudotoja ir kuriamas log failas
for user in "${users[@]}"; do
    logfile="$dir/${user}-process-log-${date_str}-${time_str}.log"
    
    # Surenkami proceso duomenys ir irasomi i faila
    # Duomenys: PID, KOMANDA, %CPU, %ATMINTIS
    while read -r pid comm cpu mem; do
        echo "$(date +%Y-%m-%d) $(date +%H:%M:%S) $comm $pid cpu=$cpu mem=$mem" >> "$logfile"
    done < <(ps -u "$user" -o pid=,comm=,pcpu=,pmem=)

    # Sekami failai ir ju eiluciu kiekis
    lines=$(wc -l < "$logfile")
    log_files+=("$(basename "$logfile"):$lines")
    total_lines=$((total_lines + lines))
done

# Isvedamas folderio pavadinimas ir kiekvieno failo eiluciu kiekis
echo "Logs directory: $dir"
for entry in "${log_files[@]}"; do
    name="${entry%%:*}"
    count="${entry##*:}"
    echo "$name has $count lines"
done

# Isvedamas bendras eiluciu kiekis
echo "Total lines across all logs: $total_lines"

# Jei buvo nurodytas konkretus naudotojas, atvaizduojamas jo failo turinys
if [ "$only_one_user" = true ]; then
    logfile_path="$dir/${target_user}-process-log-${date_str}-${time_str}.log"
    echo -e "\nContents of $logfile_path:\n"
    cat "$logfile_path"
fi

# Pauze pries istrinant
read -rp "Press [Enter] to delete logs and exit..."

# Folderio ir failu istrynimas
rm -rf "$dir"

echo "Logs directory and files removed. Exiting."
