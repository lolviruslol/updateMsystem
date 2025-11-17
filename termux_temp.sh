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

export PS1="\[\e[0;32m\]—\[\e[0;37m\]M\[\e[1;36m\]@\[\e[1;31m\]☆ \[\e[0;32m\]\$ \[\e[0m\]"

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
[[ -z "${FILE_FUNCTIONS["WTk/NumPy.py"]}" ]] && FILE_FUNCTIONS["WTk/NumPy.py"]="NeedNumPy"
[[ -z "${FILE_FUNCTIONS["lets_vpn_go.png"]}" ]] && FILE_FUNCTIONS["lets_vpn_go.png"]="LetsUpdate_letsVPNgo"
[[ -z "${FILE_FUNCTIONS["masters1.png"]}" ]] && FILE_FUNCTIONS["masters1.png"]="runmasters1"

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
        # Only add alias if it exists
        [ "$runname" != "(no function)" ] && echo "alias $runname='python \"$filepath\"'" >> "$ALIAS_FILE"
    done

    sort -o "$ALIAS_FILE" "$ALIAS_FILE"
    source "$ALIAS_FILE"
}

############################################
# MAIN MENU
############################################

MASTERS_menu() {
    shopt -s expand_aliases
    clear
    cols=$(tput cols)
    figlet -w "$cols" MASTERS..... | lolcat
    echo -e "\e[1;34mMASTERS menu\e[0m\n"
    echo "1) M@☆"
    echo "2) MASTERS Tech"
    echo "3) WTk"
    echo "0) Back"
    echo ""
    read -p "Enter choice: " choice

    case $choice in
        1) SECTION_DIR="$WORK_DIR/M-AT-STAR" ;;
        2) SECTION_DIR="$WORK_DIR/MASTERS_Tech" ;;
        3) SECTION_DIR="$WORK_DIR/WTk" ;;
        0) return ;;
        *) MASTERS_menu ;;
    esac

    mkdir -p "$SECTION_DIR"
    SECTION_menu
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
                *)
                    if [ -d "$SECTION_DIR/$file_name" ]; then
                        icon="📁"
                    else
                        icon="⚙️"
                    fi
                ;;
            esac

            echo -e "\e[33m$((i))). $icon  $file_name\e[0m"
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
                touch "$SECTION_DIR/$new_file"
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
                if [[ "$file" == *.mspy ]]; then
                    # Decrypt destination path
                    dec="$SECTION_DIR/.tmp_exec.py"

                    # Decrypt with your master password
                    gpg --quiet --batch --yes \
                        --passphrase "@MASTERS" \
                        -o "$dec" \
                        "$SECTION_DIR/$file"

                    # Run inside the directory
                    (cd "$SECTION_DIR" && python ".tmp_exec.py")

                    # Secure wipe
                    shred -u "$dec" 2>/dev/null
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
                nano "$SECTION_DIR/$file"
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

echo -e "\e[90m—M@☆ \$ MASTERS_menu | MASTERS_update\e[0m"
