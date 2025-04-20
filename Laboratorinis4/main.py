#!/usr/bin/env python3

import os
import sys
import argparse
from datetime import datetime

# Windows specifinis importas bet kokiam klaviaturos paspaudimui
try:
    import msvcrt
except ImportError:
    msvcrt = None

LOG_FILE = "search.log"
DELIMITER = "------"

def get_owner(path):
    # Grazina failo savininka: pywin32 arba prisijungimo varda
    try:
        import win32security
        sd = win32security.GetFileSecurity(
            path, win32security.OWNER_SECURITY_INFORMATION
        )
        owner_sid = sd.GetSecurityDescriptorOwner()
        name, domain, _ = win32security.LookupAccountSid(None, owner_sid)
        return f"{domain}\\{name}"
    except Exception:
        try:
            return os.getlogin()
        except Exception:
            return "Unknown"

def get_creation_time(path):
    # Grazina sukurimo laika
    ts = os.stat(path).st_ctime
    return datetime.fromtimestamp(ts).strftime("%Y-%m-%d %H:%M:%S")

def log_search(term, output_lines):
    # Iraso paieskos rezultatus i log faila
    with open(LOG_FILE, "a", encoding="utf-8") as f:
        f.write(f"{DELIMITER}\n")
        f.write(f"Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write(f"Search term: {term}\n")
        for line in output_lines:
            f.write(line + "\n")
        f.write("\n")

def process_file(path, output):
    # Suformuoja info apie faila
    name = os.path.basename(path)
    owner = get_owner(path)
    created = get_creation_time(path)
    output.append(f"[FILE] {name}")
    output.append(f"  Path:    {path}")
    output.append(f"  Owner:   {owner}")
    output.append(f"  Created: {created}")
    output.append("")

def process_dir(path, output):
    # Suformuoja info apie direktorija + sone esanti turini
    name = os.path.basename(path)
    owner = get_owner(path)
    created = get_creation_time(path)
    output.append(f"[DIR]  {name}")
    output.append(f"  Path:    {path}")
    output.append(f"  Owner:   {owner}")
    output.append(f"  Created: {created}")
    output.append("  Contents:")
    try:
        for entry in os.listdir(path):
            output.append(f"    - {entry}")
    except PermissionError:
        output.append("    [Permission denied]")
    output.append("")

def main():
    parser = argparse.ArgumentParser(
        description="Search for files or directories by name (or partial name)."
    )
    parser.add_argument("term", help="File or directory name (or part of it) to search for")
    args = parser.parse_args()
    term = args.term.lower()

    output = []
    # Eina per visas subdirektorijas
    for root, dirs, files in os.walk("."):
        for d in dirs:
            if term in d.lower():
                process_dir(os.path.join(root, d), output)
        for f in files:
            if term in f.lower():
                process_file(os.path.join(root, f), output)

    if not output:
        output.append(f"No matches found for '{args.term}'.")

    # Isveda rezultatus i konsole
    for line in output:
        print(line)

    # Iraso i log faila
    log_search(args.term, output)

    # Laukia bet kokio klaviros paspaudimo
    print("\nPress any key to delete log file and exit...")
    if msvcrt:
        msvcrt.getch()
    else:
        input()

    # Istrina log faila
    try:
        os.remove(LOG_FILE)
        print("Log file deleted.")
    except Exception as e:
        print(f"Could not delete log file: {e}")

if __name__ == "__main__":
    main()
