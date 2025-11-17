###############################
#  MASTERS SYSTEM M@☆
###############################
#!/data/data/com.termux/files/usr/bin/bash

shopt -s expand_aliases

############################################
# AUTO INSTALL DEPENDENCIES
############################################

required_pkgs=(ruby figlet cmatrix chafa python termux-api)

for pkg in "${required_pkgs[@]}"; do
    if ! command -v $pkg &>/dev/null; then
        echo "Installing missing package: $pkg..."
        pkg install -y $pkg
    fi
done

if ! command -v lolcat &>/dev/null; then
    echo "Installing lolcat gem..."
    gem install lolcat
fi

# Add gem binaries to PATH
for gem_path in "$HOME/.gem/ruby/"*/bin "$HOME/.local/share/gem/ruby/"*/bin; do
    [ -d "$gem_path" ] && PATH="$gem_path:$PATH"
done
export PATH

############################################
# MATRIX INTRO
############################################

MATRIX_SCRIPT="$HOME/matrix_tk.sh"
[ -f "$MATRIX_SCRIPT" ] && bash "$MATRIX_SCRIPT"

############################################
# CORE .mspy PROTECTION HELPERS
############################################

is_mspy() {
    [[ "$1" == *.mspy ]]
}

run_mspy() {
    # Usage: run_mspy "relative/path/to/file.mspy" "optional-section-dir"
    local file="$1"
    local alt_section_dir="$2"
    local dir="${alt_section_dir:-$SECTION_DIR}"
    local dec="$dir/.tmp_exec.py"

    if [ ! -f "$dir/$file" ]; then
        echo "File not found: $dir/$file"
        return 1
    fi

    echo "..☆.. $file..."
    if ! gpg --quiet --batch --yes --passphrase "@MASTERS" -o "$dec" "$dir/$file"; then
        echo "❌ Decrypt failed. Check passphrase or file."
        [ -f "$dec" ] && shred -u "$dec" 2>/dev/null
        return 1
    fi

    echo "Running securely..."
    (cd "$dir" && python ".tmp_exec.py")

    echo "Cleaning up..."
    shred -u "$dec" 2>/dev/null || rm -f "$dec"
    return 0
}

decrypt_edit_reencrypt() {
    # Decrypt to temp, open nano, then re-encrypt back to .mspy
    local file="$1"
    local dir="$SECTION_DIR"
    local dec="$dir/.tmp_edit.py"
    local bak="$dir/.tmp_edit.py.bak"
    local orig="$dir/$file"

    if [ ! -f "$orig" ]; then
        echo "File not found: $orig"
        return 1
    fi

    echo "Decrypting $file to temp..."
    if ! gpg --quiet --batch --yes --passphrase "@MASTERS" -o "$dec" "$orig"; then
        echo "❌ Decrypt failed."
        [ -f "$dec" ] && shred -u "$dec" 2>/dev/null
        return 1
    fi

    # Backup decrypted copy in case user aborts
    cp "$dec" "$bak" 2>/dev/null || true

    echo "Opening editor. Save and exit to re-encrypt."
    nano "$dec"

    echo "Re-encrypting and saving..."
    if gpg --symmetric --cipher-algo AES256 --batch --yes --passphrase "@MASTERS" -o "$orig" "$dec"; then
        echo "✅ Re-encrypted $file"
    else
        echo "❌ Re-encrypt failed. Restoring previous decrypted backup to $dec"
        cp "$bak" "$dec" 2>/dev/null || true
    fi

    # Cleanup
    shred -u "$dec" 2>/dev/null || rm -f "$dec"
    shred -u "$bak" 2>/dev/null || rm -f "$bak"
    return 0
}

############################################
# CINEMATIC BANNER — DYNAMIC
############################################

clear

# --- Display MASTERS SYSTEM text with random blue gradient ---
text="MASTERS SYSTEM M@☆┉┉⸙"
colors=(34 36 94 96 39)

for (( i=0; i<${#text}; i++ )); do
    color=${colors[$RANDOM % ${#colors[@]}]}
    printf "\e[${color}m${text:$i:1}\e[0m"
done
echo

# --- FIGLET Banner ---
cols=$(tput cols)
figlet -w "$cols" "MASTERS...." | lolcat

# --- Load current banner from encrypted config ---
TMP_FILE=$(mktemp)
if gpg --quiet --batch --yes --passphrase "@MASTERS" --decrypt ~/termux.gpg > "$TMP_FILE" 2>/dev/null; then
    BANNER_LINE=$(grep '^echo "' "$TMP_FILE" | head -n 1 | sed 's/^echo "//; s/"$//')
else
    BANNER_LINE=""
fi
rm -f "$TMP_FILE"

# Fallback default banner if empty
[ -z "$BANNER_LINE" ] && BANNER_LINE="ᴛᵏ ᴍᵃˢᵗᵉʳ @M🇦 🇸 🇹 🇪 🇷 🇸 🇹 🇪 🇨 🇭 🇸 🇴 🇱 🇺 🇹 🇮 🇴 🇳 🇸...——"

# --- Left-aligned cinematic lines ---
echo -e "\e[1;32mM@☆......."
echo "....................................................💙"
echo ".........."
echo "$BANNER_LINE"
echo -e "\e[0m"

############################################
# WORK DIR
############################################

WORK_DIR="/storage/emulated/0/MASTERS"
[ ! -d "$WORK_DIR" ] && mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

############################################
# ALIAS STORAGE
############################################

ALIAS_FILE="$HOME/.masters_aliases"
touch "$ALIAS_FILE"

if [ -f "$ALIAS_FILE" ]; then
    source "$ALIAS_FILE"
fi

############################################
# CUSTOM PROMPT
############################################

export PS1="\[\e[0;32m\]-\[\e[0;37m\]M\[\e[1;36m\]@\[\e[1;31m\]☆ \[\e[0;32m\]\$ \[\e[0m\]"

############################################
# FILE FUNCTION MAP (RUNMAP)
############################################

RUNMAP_FILE="$WORK_DIR/.runmap.txt"
declare -A FILE_FUNCTIONS

# Load previous mappings
if [ -f "$RUNMAP_FILE" ]; then
    while IFS='=' read -r key val; do
        FILE_FUNCTIONS["$key"]="$val"
    done < "$RUNMAP_FILE"
fi

# Defaults (only if missing)
[[ -z "${FILE_FUNCTIONS["WTk/wtk_sniper_system_v2.py"]}" ]] && FILE_FUNCTIONS["WTk/wtk_sniper_system_v2.py"]="WTkMasterFx"
[[ -z "${FILE_FUNCTIONS["WTk/wtk_masterfx.py"]}" ]] && FILE_FUNCTIONS["WTk/wtk_masterfx.py"]="WTkMasterFx01"
[[ -z "${FILE_FUNCTIONS["lets_vpn_go.png"]}" ]] && FILE_FUNCTIONS["lets_vpn_go.png"]="LetsUpdate_letsVPNgo"

############################################
# ALIAS ENGINE — CLEAN, SORT & RELOAD
############################################

SAVE_RUNMAP() {
    > "$RUNMAP_FILE"
    for key in "${!FILE_FUNCTIONS[@]}"; do
        echo "$key=${FILE_FUNCTIONS[$key]}" >> "$RUNMAP_FILE"
    done

    > "$ALIAS_FILE"
    for key in "${!FILE_FUNCTIONS[@]}"; do
        runname="${FILE_FUNCTIONS[$key]}"
        filepath="$WORK_DIR/$key"

        # Only add alias if it exists and runname is set
        if [ -n "$runname" ] && [ -f "$filepath" ]; then
            filename=$(basename "$filepath")
            # If it's a protected .mspy file, alias to run_mspy wrapper
            if is_mspy "$filename"; then
                echo "alias $runname='run_mspy \"$filename\" \"$WORK_DIR/$(dirname "$key")\"'" >> "$ALIAS_FILE"
            else
                # normal python alias
                echo "alias $runname='python \"$filepath\"'" >> "$ALIAS_FILE"
            fi
        fi
    done

    sort -o "$ALIAS_FILE" "$ALIAS_FILE"
    source "$ALIAS_FILE"
}

############################################
# MAIN MENU
############################################

MASTERS_menu() {
    while true; do
        shopt -s expand_aliases
        clear
        cols=$(tput cols)
        figlet -w "$cols" MASTERS.... | lolcat
        echo -e "\e[1;34mMASTERS menu\e[0m\n"
        echo "1) M@☆"
        echo "2) MASTERS Tech"
        echo "3) WTk"
        echo "4) MASTERS Secure"
        echo "0) Back"
        echo ""
        read -p "Enter choice: " choice

        case $choice in
            1) SECTION_DIR="$WORK_DIR/M-AT-STAR"; SECTION_menu ;;
            2) SECTION_DIR="$WORK_DIR/MASTERS_Tech"; SECTION_menu ;;
            3) SECTION_DIR="$WORK_DIR/WTk"; SECTION_menu ;;
            4) MASTERS_secure ;;
            0) break ;;   # <- just exit the menu loop instead of exiting Termux
            *) continue ;;
        esac
    done
}

############################################
# MASTERS UPDATE MENU
############################################

MASTERS_update() {
    while true; do
        clear
        cols=$(tput cols)
        figlet -w "$cols" "MASTERS Update" | lolcat
        echo -e "\e[1;34mMASTERS Update Menu\e[0m\n"
        echo "1) Update User Name"
        echo "2) Undo Last Change"
        echo "@) Update MASTERS SYSTEM M@☆"
        echo "0) Back"
        echo ""

        read -p "Enter choice: " choice

        case $choice in
            1)
                DEFAULT_BANNER="ᴛᵏ ᴍᵃˢᵗᵉʳ @M🇦 🇸 🇹 🇪 🇷 🇸 🇹 🇪 🇨 🇭 🇸 🇴 🇱 🇺 🇹 🇮 🇴 🇳 🇸...——"
                MAX_LEN=55

                TMP_FILE=$(mktemp)
                gpg --quiet --batch --yes --passphrase "@MASTERS" --decrypt ~/termux.gpg > "$TMP_FILE"

                # Extract current banner safely using marker
                CURRENT_BANNER=$(grep -A1 '^# BANNER_LINE' "$TMP_FILE" | tail -n1 | sed 's/^echo "//; s/"$//')
                [ -z "$CURRENT_BANNER" ] && CURRENT_BANNER="$DEFAULT_BANNER"

                echo -e "\nCurrent Banner:"
                echo "$CURRENT_BANNER"

                echo -e "\nEnter new banner (max $MAX_LEN chars)"
                echo "(Press ENTER to restore default)"
                read -r NEW_BANNER

                if [ -z "$NEW_BANNER" ]; then
                    NEW_BANNER="$DEFAULT_BANNER"
                    echo -e "\nRestoring default banner..."
                fi

                if [ ${#NEW_BANNER} -gt $MAX_LEN ]; then
                    NEW_BANNER="${NEW_BANNER:0:$MAX_LEN}"
                    echo -e "\nInput truncated to $MAX_LEN characters."
                fi

                echo -e "\n====== PREVIEW ======"
                echo -e "Current: $CURRENT_BANNER"
                echo -e "New:     $NEW_BANNER"
                echo "======================"
                read -p "Save this change? (y/n): " confirm
                if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
                    echo -e "\nCancelled. No changes saved."
                    read -p "Press Enter..." dummy
                    rm -f "$TMP_FILE"
                    continue
                fi

                # Store undo
                sed -i "s/^PREVIOUS_BANNER=.*/PREVIOUS_BANNER=\"$CURRENT_BANNER\"/" "$TMP_FILE" 2>/dev/null \
                    || echo "PREVIOUS_BANNER=\"$CURRENT_BANNER\"" >> "$TMP_FILE"

                # Remove old banner line after marker if exists
                sed -i '/^# BANNER_LINE$/,+1d' "$TMP_FILE" 2>/dev/null

                # Add updated banner with marker at the top
                {
                    echo "# BANNER_LINE"
                    echo "echo \"$NEW_BANNER\""
                    cat "$TMP_FILE"
                } > "${TMP_FILE}.tmp"
                mv "${TMP_FILE}.tmp" "$TMP_FILE"

                # Re-encrypt
                gpg --symmetric --cipher-algo AES256 --batch --yes --passphrase "@MASTERS" \
                    -o ~/termux.gpg "$TMP_FILE"

                rm -f "$TMP_FILE"

                echo -e "\nBanner updated!"
                read -p "Press Enter..." dummy
                ;;

            2)
                TMP_FILE=$(mktemp)
                gpg --quiet --batch --yes --passphrase "@MASTERS" --decrypt ~/termux.gpg > "$TMP_FILE"

                PREV=$(grep "^PREVIOUS_BANNER=" "$TMP_FILE" | cut -d'"' -f2)
                if [ -z "$PREV" ]; then
                    echo -e "\nNo previous banner stored."
                    read -p "Press Enter..." dummy
                    rm -f "$TMP_FILE"
                    continue
                fi

                echo -e "\nRestoring previous banner:"
                echo "$PREV"
                read -p "Confirm restore? (y/n): " confirm
                if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
                    echo -e "\nUndo cancelled."
                    read -p "Press Enter..." dummy
                    rm -f "$TMP_FILE"
                    continue
                fi

                # Remove old banner line
                sed -i '/^# BANNER_LINE$/,+1d' "$TMP_FILE" 2>/dev/null

                # Add previous banner with marker
                {
                    echo "# BANNER_LINE"
                    echo "echo \"$PREV\""
                    cat "$TMP_FILE"
                } > "${TMP_FILE}.tmp"
                mv "${TMP_FILE}.tmp" "$TMP_FILE"

                # Re-encrypt
                gpg --symmetric --cipher-algo AES256 --batch --yes --passphrase "@MASTERS" \
                    -o ~/termux.gpg "$TMP_FILE"

                rm -f "$TMP_FILE"
                echo -e "\nUndo complete."
                read -p "Press Enter..." dummy
                ;;

            @)
    echo -e "\n🔥 Updating MASTERS SYSTEM M@☆..."

    TMP_UPDATE="$HOME/termux_temp.sh"
    RAW_LINK="https://github.com/lolviruslol/updateMsystem/raw/main/termux_temp.sh"

    # Download the latest update quietly
    if wget -q -O "$TMP_UPDATE" "$RAW_LINK"; then
        echo "✅ Successful."
    else
        echo "❌ Failed. Check your internet connection."
        read -p "Press Enter to continue..." dummy
        continue
    fi

    # Don’t show file content publicly; just confirm
    echo "⚡ Ready to apply update."

    read -p "Confirm update? This will overwrite your current system (y/n): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Update cancelled."
        rm -f "$TMP_UPDATE"
        read -p "Press Enter..." dummy
        continue
    fi

    # Encrypt the new system
    if gpg --symmetric --cipher-algo AES256 --batch --yes --passphrase "@MASTERS" \
        -o "$HOME/termux.gpg" "$TMP_UPDATE"; then
        echo "✅ System updated and encrypted."
    else
        echo "❌ Encryption failed! Your system may be unsafe."
        rm -f "$TMP_UPDATE"
        read -p "Press Enter..." dummy
        continue
    fi

    # Clean up
    rm -f "$TMP_UPDATE"

    # Reload shell
    echo -e "\n♻ Reloading MASTERS SYSTEM..."
    source ~/.bashrc
    echo "✅ Update complete!"
    read -p "Press Enter to return to menu..." dummy
    ;;
            0) return ;;
        esac
    done
}

# Alias for convenience
alias MASTERS-update='MASTERS_update'


# ---------------------------------------------------------
# MASTERS Secure System — ONE-WAY SECURE
############################################
# MASTERS SECURE
############################################
# MASTERS SECURE — Folder Selection
############################################

MASTERS_secure() {
    BASE_DIR="$WORK_DIR"  # /storage/emulated/0/MASTERS
    while true; do
        clear
        echo "──────── MASTERS Secure Center ────────"
        echo "Select a folder to view files:"
        echo "0) Back to MASTERS menu"
        echo "────────────────────────────────────────"

        # List folders
        i=1
        declare -A IDX_TO_DIR
        for d in "$BASE_DIR"/*/; do
            [[ -d "$d" ]] || continue
            echo "$i) $(basename "$d")"
            IDX_TO_DIR[$i]="$d"
            ((i++))
        done

        echo "────────────────────────────────────────"
        read -p "Choose folder: " choice

        if [[ "$choice" == "0" ]]; then
            return  # back to MASTERS_menu
        elif [[ -n "${IDX_TO_DIR[$choice]}" ]]; then
            FOLDER="${IDX_TO_DIR[$choice]}"
        else
            continue
        fi

        # Folder chosen, list files
        while true; do
            clear
            echo "Folder: $FOLDER"
            echo "──────── Files ─────────"
            echo "0) Back to folder selection"
            i=1
            declare -A IDX_TO_FILE
            for f in "$FOLDER"*; do
                [[ -f "$f" ]] || continue
                echo "$i) $(basename "$f")"
                IDX_TO_FILE[$i]="$f"
                ((i++))
            done
            echo "──────────────────────"
            read -p "Select file to secure: " file_choice

            if [[ "$file_choice" == "0" ]]; then
                break  # back to folder selection
            elif [[ -n "${IDX_TO_FILE[$file_choice]}" ]]; then
                FILEPATH="${IDX_TO_FILE[$file_choice]}"
            else
                continue
            fi

            # Secure selected file
            filename=$(basename "$FILEPATH")
            ext="${filename##*.}"
            name="${filename%.*}"

            if [[ "$ext" == "py" ]]; then
                new_ext="mspy"
            else
                new_ext="mstxt"
            fi

            SECURED_FILE="$FOLDER/$name.$new_ext"

            echo "Encrypting..."
            if gpg --symmetric --cipher-algo AES256 --batch --yes --passphrase "@MASTERS" -o "$SECURED_FILE" "$FILEPATH"; then
                echo "✅ Saved as: $SECURED_FILE"
            else
                echo "❌ Encryption failed!"
            fi
            read -p "Press Enter..."
        done
    done
}

############################################
# M@☆ UPDATE — FETCH 3 FILES
############################################

M@_update() {
    WORK_DIR="/storage/emulated/0/MASTERS/M-AT-STAR"
    mkdir -p "$WORK_DIR"

    echo -e "\n🔥 Fetching latest M@☆ files..."

    # File URLs
    declare -A FILES
    FILES["hosts.txt"]="https://raw.githubusercontent.com/M-AT-STAR/SAVE/main/hosts.txt"
    FILES["hosts100.txt"]="https://raw.githubusercontent.com/M-AT-STAR/SAVE/main/hosts100.txt"
    FILES["M@_zero_rated_scan.mspy"]="https://raw.githubusercontent.com/M-AT-STAR/SAVE/main/M%40_zero_rated_scan.mspy"

    for file in "${!FILES[@]}"; do
        url="${FILES[$file]}"
        echo "Downloading $file..."
        curl -L "$url" -o "$WORK_DIR/$file"
        if [ $? -eq 0 ]; then
            echo "✅ $file saved to $WORK_DIR"
        else
            echo "❌ Failed to download $file"
        fi
    done

    echo -e "\n♻ Reloading MASTERS SYSTEM aliases..."
    source ~/.bashrc
    echo "✅ Update complete!"
    read -p "Press Enter to continue..." dummy
}

############################################################################
# SECTION MENU — DYNAMIC SCALE
############################################

SECTION_menu() {
    while true; do
        clear
        cols=$(tput cols)
        echo -e "\e[1;32mDirectory: $(basename "$SECTION_DIR")\e[0m"
        echo "─"$(printf '─%.0s' $(seq 1 $((cols-1))))"─"

        i=1
        declare -A INDEX_TO_FILE

        # LIST FILES SORTED BY DATE (NEWEST FIRST) WITH ICONS
        while IFS= read -r file_name; do
            key="$(basename "$SECTION_DIR")/$file_name"
            func="${FILE_FUNCTIONS[$key]:-(no function)}"

            # Detect file extension
            ext="${file_name##*.}"
            icon="📦"  # default

            case "$ext" in
                py)   icon="🐍" ;;
                txt)  icon="📄" ;;
                pdf)  icon="📜" ;;
                png|jpg|jpeg|gif|webp) icon="🖼️" ;;
                sh)   icon="🔧" ;;
                json|yaml|yml) icon="💾" ;;
                zip|rar|7z|tar|gz) icon="📦" ;;
                mspy) icon="🔒" ;;
                *)
                    if [ -d "$SECTION_DIR/$file_name" ]; then
                        icon="📁"
                    else
                        icon="⚙️"
                    fi
                ;;
            esac

            # show special label if protected
            if is_mspy "$file_name"; then
                echo -e "\e[33m$((i))). $icon  $file_name \e[91m[M-SPY]\e[0m"
            else
                echo -e "\e[33m$((i))). $icon  $file_name\e[0m"
            fi

            echo -e "      \e[90mrun: $func\e[0m"
            echo
            INDEX_TO_FILE[$i]="$file_name"
            ((i++))
        done < <(ls -1t "$SECTION_DIR")

        echo "─"$(printf '─%.0s' $(seq 1 $((cols-1))))"─"
        echo "0) Go Back | 00) Add New File | @) M@☆update"
        echo "─"$(printf '─%.0s' $(seq 1 $((cols-1))))"─"
        read -p "Enter choice: " pick

        case "$pick" in
            0)
                MASTERS_menu
                return
                ;;
            00)
                read -p "Enter new file name: " new_file
                # If user creates .mspy, create empty encrypted stub
                if is_mspy "$new_file"; then
                    tmpstub=$(mktemp)
                    echo "# Encrypted mspy stub" > "$tmpstub"
                    gpg --symmetric --cipher-algo AES256 --batch --yes --passphrase "@MASTERS" -o "$SECTION_DIR/$new_file" "$tmpstub"
                    rm -f "$tmpstub"
                    echo "Created encrypted stub $new_file"
                else
                    touch "$SECTION_DIR/$new_file"
                fi
                read -p "Press Enter..." ;;
            @)
                M@_update
                ;;
            *)
                selected="${INDEX_TO_FILE[$pick]}"
                [[ -n "$selected" ]] && FILE_ACTION_MENU "$selected"
                ;;
        esac
    done
}

############################################
############################################
# FILE ACTION MENU — Full MSPY + PY Support
############################################

FILE_ACTION_MENU() {
    local file="$1"
    key="$(basename "$SECTION_DIR")/$file"
    func="${FILE_FUNCTIONS[$key]:-(no function)}"

    while true; do
        clear
        cols=$(tput cols)
        echo "Selected File: $file"
        echo "─"$(printf '─%.0s' $(seq 1 $((cols-1))))"─"
        echo "1) Run: $func"
        echo "2) Edit run name (shortcut)"
        echo "3) Edit file (nano)"
        echo "4) Delete run name"
        echo "0) Go Back"
        echo "─"$(printf '─%.0s' $(seq 1 $((cols-1))))"─"

        read -p "Enter action: " action

        case $action in
            1)
                echo "Executing $file..."

                ###################################################
                # MSPY SYSTEM — decrypt, run, shred
                ###################################################
                if is_mspy "$file"; then
                    run_mspy "$file"
                    read -p "Press Enter..." dummy
                    continue
                fi

                ###################################################
                # Normal Python script
                ###################################################
                if [[ "$file" == *.py ]]; then
                    (cd "$SECTION_DIR" && python "$file")
                    read -p "Press Enter..." dummy
                    continue
                fi

                ###################################################
                # Shell scripts
                ###################################################
                if [[ "$file" == *.sh ]]; then
                    (cd "$SECTION_DIR" && bash "$file")
                    read -p "Press Enter..." dummy
                    continue
                fi

                ###################################################
                # Fallback — try python then shell
                ###################################################
                (
                    cd "$SECTION_DIR" &&
                    python "$file" 2>/dev/null || bash "$file"
                )
                read -p "Press Enter..." dummy
                ;;

            2)
                echo "Current shortcut: $func"
                read -p "Enter new shortcut: " new_func
                FILE_FUNCTIONS[$key]="$new_func"
                SAVE_RUNMAP
                read -p "Updated. Press Enter..." dummy
                ;;

            3)
    if is_mspy "$file"; then
        echo "This file is protected and cannot be viewed or edited."
        read -p "Press Enter..."
        return
    fi

    nano "$SECTION_DIR/$file"
    return
    ;;

            4)
                echo "Deleting shortcut: $func"
                unset FILE_FUNCTIONS[$key]
                SAVE_RUNMAP
                read -p "Removed. Press Enter..." dummy
                ;;

            0)
                return
                ;;
        esac
    done
}

############################################
alias runm='source ~/.bashrc'
############
# START
############################################

# ensure aliases reflect current runmap on shell start
SAVE_RUNMAP 2>/dev/null || true

echo -e "\e[90m-M@☆ \$ MASTERS_menu | MASTERS_update\e[0m"
