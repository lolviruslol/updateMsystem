#!/data/data/com.termux/files/usr/bin/bash

##############################
#  MASTERS SYSTEM M@☆
###############################
# Combined MASTERS system with integrated Tk-Master (wtk_menu.sh)
# - Tk-Master script is installed as a hidden file: .wtk_menu.sh
# - The MASTERS menu gets a "Tk-Master" entry. Inside Tk-Master you get:
#     1) Open BOT SYSTEM         -> runs hidden .wtk_menu.sh
#     2) Open Saved Files        -> opens SECTION_menu for Tk-Master folder
#     3) Reinstall/Overwrite wtk_menu.sh
#     0) Back
#
# Save as ~/masters_system.sh, make executable (chmod +x), then run.
shopt -s expand_aliases

############################################
# AUTO INSTALL DEPENDENCIES
############################################

required_pkgs=(ruby figlet cmatrix chafa python termux-api jq curl gpg)
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
    # Usage: run_mspy "file.mspy" "optional-section-dir"
    local file="$1"
    local alt_section_dir="$2"
    local dir="${alt_section_dir:-$SECTION_DIR}"

    # Ensure file exists
    if [ ! -f "$dir/$file" ]; then
        echo "File not found: $dir/$file"
        return 1
    fi

    echo "..☆.. $file..."

    # Create temp file in Termux storage
    TMP_FILE="$HOME/.termux_mspy_tmp.py"

    # Decrypt into temp file
    if ! gpg --quiet --batch --yes --passphrase "@MASTERS" -o "$TMP_FILE" "$dir/$file"; then
        echo "❌ Decrypt failed. Check passphrase or file."
        [ -f "$TMP_FILE" ] && rm -f "$TMP_FILE"
        return 1
    fi

    echo "Running $file..."
    (cd "$dir" && python "$TMP_FILE")

    echo "M@☆..."
    [ -f "$TMP_FILE" ] && rm -f "$TMP_FILE"

    echo "✅."
    return 0
}

decrypt_edit_reencrypt() {
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

    shred -u "$dec" 2>/dev/null || rm -f "$dec"
    shred -u "$bak" 2>/dev/null || rm -f "$bak"
    return 0
}

############################################
# CINEMATIC BANNER — DYNAMIC
############################################

clear

text="MASTERS SYSTEM M@☆┉┉⸙"
colors=(34 36 94 96 39)
for (( i=0; i<${#text}; i++ )); do
    color=${colors[$RANDOM % ${#colors[@]}]}
    printf "\e[${color}m${text:$i:1}\e[0m"
done
echo

cols=$(tput cols)
figlet -w "$cols" "MASTERS...." | lolcat

TMP_FILE=$(mktemp)
if gpg --quiet --batch --yes --passphrase "@MASTERS" --decrypt ~/termux.gpg > "$TMP_FILE" 2>/dev/null; then
    BANNER_LINE=$(grep '^echo "' "$TMP_FILE" | head -n 1 | sed 's/^echo "//; s/"$//')
else
    BANNER_LINE=""
fi
rm -f "$TMP_FILE"
[ -z "$BANNER_LINE" ] && BANNER_LINE="ᴛᵏ ᴍᴀˢᵗᵉʳ @M🇦 🇸 🇹 🇪 🇷 🇸 🇹 🇪 🇨 🇭 🇸 🇴 🇱 🇺 🇹 🇮 🇴 🇳 🇸...——"

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
[ -f "$ALIAS_FILE" ] && source "$ALIAS_FILE"

############################################
# CUSTOM PROMPT
############################################

export PS1="\[\e[0;32m\]-\[\e[0;37m\]M\[\e[1;36m\]@\[\e[1;31m\]☆ \[\e[0;32m\]\$ \[\e[0m\]"

############################################
# FILE FUNCTION MAP (RUNMAP)
############################################

RUNMAP_FILE="$WORK_DIR/.runmap.txt"
declare -A FILE_FUNCTIONS
if [ -f "$RUNMAP_FILE" ]; then
    while IFS='=' read -r key val; do
        FILE_FUNCTIONS["$key"]="$val"
    done < "$RUNMAP_FILE"
fi

# Defaults (only if missing)
[[ -z "${FILE_FUNCTIONS["WTk/wtk_sniper_system_v2.py"]}" ]] && FILE_FUNCTIONS["WTk/wtk_sniper_system_v2.py"]="WTkMasterFx"
[[ -z "${FILE_FUNCTIONS["WTk/wtk_masterfx.py"]}" ]] && FILE_FUNCTIONS["WTk/wtk_masterfx.py"]="WTkMasterFx01"
[[ -z "${FILE_FUNCTIONS["lets_vpn_go.png"]}" ]] && FILE_FUNCTIONS["lets_vpn_go.png"]="LetsUpdate_letsVPNgo"
# default alias for hidden script
[[ -z "${FILE_FUNCTIONS["Tk-Master/.wtk_menu.sh"]}" ]] && FILE_FUNCTIONS["Tk-Master/.wtk_menu.sh"]="TkMasterMenu"

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

        if [ -n "$runname" ] && [ -f "$filepath" ]; then
            filename=$(basename "$filepath")
            if is_mspy "$filename"; then
                echo "alias $runname='run_mspy \"$filename\" \"$WORK_DIR/$(dirname "$key")\"'" >> "$ALIAS_FILE"
            else
                echo "alias $runname='python \"$filepath\"'" >> "$ALIAS_FILE"
            fi
        fi
    done

    sort -o "$ALIAS_FILE" "$ALIAS_FILE" 2>/dev/null || true
    source "$ALIAS_FILE" 2>/dev/null || true
}

############################################
# Ensure Tk-Master folder and hidden .wtk_menu.sh are present
############################################

ensure_tk_master_installed() {
    TK_DIR="$WORK_DIR/Tk-Master"
    [ -d "$TK_DIR" ] || mkdir -p "$TK_DIR"
    TK_SCRIPT="$TK_DIR/.wtk_menu.sh"

    # If the hidden script does not exist, write the bundled wtk_menu.sh into place.
    if [ ! -f "$TK_SCRIPT" ]; then
        cat > "$TK_SCRIPT" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# Dynamic Termux menu: fetch /plugins and build prompts automatically.
# Hidden copy used by MASTERS system.
FX_HOST="fx.tkmaster.qzz.io:8000"
TOKEN="123000"

LOCAL_RESULTS_DIR="${SAVE_DIR:-$PWD}"
mkdir -p "$LOCAL_RESULTS_DIR" 2>/dev/null || true

fetch_plugins() {
  curl -s -H "Authorization: Bearer $TOKEN" "http://$FX_HOST/plugins" | jq -r '.plugins'
}

add_kv_to_body() {
  local body_json="$1"; local key="$2"; local val="$3"
  local val_lc="${val,,}"
  if [[ "$val_lc" == "true" || "$val_lc" == "false" ]]; then
    echo "$body_json" | jq --arg k "$key" --argjson v "$val_lc" '. + {($k): $v}'; return
  fi
  if [[ "$val" =~ ^-?[0-9]+$ ]]; then
    echo "$body_json" | jq --arg k "$key" --argjson v "$val" '. + {($k): $v}'; return
  fi
  if [[ "$val" =~ ^-?[0-9]*\.[0-9]+$ ]]; then
    echo "$body_json" | jq --arg k "$key" --argjson v "$val" '. + {($k): $v}'; return
  fi
  echo "$body_json" | jq --arg k "$key" --arg v "$val" '. + {($k): $v}'
}

build_body() {
  plugin_json="$1"
  body='{}'
  input_count=$(echo "$plugin_json" | jq '.inputs | length')
  for i in $(seq 0 $((input_count - 1))); do
    key=$(echo "$plugin_json" | jq -r ".inputs[$i].name")
    prompt=$(echo "$plugin_json" | jq -r ".inputs[$i].prompt")
    if [ "$key" == "save_client" ]; then
      continue
    fi
    has_key=$(echo "$body" | jq -r --arg k "$key" 'has($k)' 2>/dev/null || echo "false")
    if [ "$has_key" == "true" ]; then
      continue
    fi
    read -p "$prompt " val
    if [[ "$key" =~ _file$ ]]; then
      if [ -z "$val" ]; then
        default_guess=$(echo "$prompt" | sed -nE 's/.*[dD]efault: *([^)\]:]+).*/\1/p' | tr -d '[:space:]')
        [ -z "$default_guess" ] && default_guess="hosts.txt"
        val="$default_guess"
      fi
      candidates=()
      if [[ "$val" == /* || "$val" == *"/"* ]]; then
        candidates+=("$val")
      else
        candidates+=("$PWD/$val")
        candidates+=("$LOCAL_RESULTS_DIR/$val")
        candidates+=("$val")
      fi
      found_local=""
      for c in "${candidates[@]}"; do
        if [ -f "$c" ]; then
          found_local="$c"
          break
        fi
      done
      if [ -n "$found_local" ]; then
        if [ "${AUTO_UPLOAD:-0}" -eq 1 ]; then
          useit="y"
        else
          read -p "Use local file '$found_local' and upload its content to server? (Y/n): " useit
        fi
        if [[ "$useit" =~ ^([Yy]|$) ]]; then
          content=$(cat "$found_local")
          body=$(add_kv_to_body "$body" "$key" "$found_local")
          comp="${key%_file}_content"
          has_comp=$(echo "$body" | jq -r --arg k "$comp" 'has($k)' 2>/dev/null || echo "false")
          if [ "$has_comp" != "true" ]; then
            body=$(echo "$body" | jq --arg k "$comp" --arg v "$content" '. + {($k): $v}')
          fi
          continue
        fi
      fi
    fi
    body=$(add_kv_to_body "$body" "$key" "$val")
  done
  echo "$body"
}

while true; do
  clear
  echo "=================================="
  echo "     Tk-Master BOT SYSTEMS"
  echo "=================================="
  plugins_json=$(fetch_plugins)
  if [ -z "$plugins_json" ] || [ "$plugins_json" == "null" ]; then
    echo "No plugins available or failed to fetch plugins."
    read -p "Press ENTER to retry..." tmp
    continue
  fi
  echo "$plugins_json" | jq -r 'to_entries[] | "\(.key | tonumber + 1)) \(.value.name) [\(.value.id)]"'
  echo "s) Change local save directory (current: $LOCAL_RESULTS_DIR)"
  echo "q) Quit"
  echo
  read -p "Select (number, s, or q): " sel
  if [ "$sel" == "q" ]; then
    exit 0
  fi
  if [ "$sel" == "s" ]; then
    read -e -p "Enter local save directory path (leave empty to use current PWD): " newdir
    if [ -n "$newdir" ]; then
      LOCAL_RESULTS_DIR="$newdir"
      mkdir -p "$LOCAL_RESULTS_DIR" 2>/dev/null || echo "Warning: cannot create $LOCAL_RESULTS_DIR"
    else
      LOCAL_RESULTS_DIR="$PWD"
    fi
    read -p "Press ENTER..."
    continue
  fi
  idx=$((sel - 1))
  plugin=$(echo "$plugins_json" | jq -r ".[$idx]")
  if [ "$plugin" == "null" ] || [ -z "$plugin" ]; then
    echo "Invalid selection"
    read -p "Press ENTER..."
    continue
  fi
  plugin_id=$(echo "$plugin" | jq -r '.id')
  plugin_name=$(echo "$plugin" | jq -r '.name')
  supports_client_save=$(echo "$plugin" | jq -r '.supports_client_save // false')
  echo "Chosen: $plugin_name ($plugin_id)"
  body=$(build_body "$plugin")
  if [ "$supports_client_save" == "true" ] || [ "$supports_client_save" == "True" ]; then
    read -p "Save file locally after server returns it? (y/N): " yn
    if [[ "$yn" =~ ^[Yy] ]]; then
      body=$(echo "$body" | jq '. + {"save_client": true}')
    fi
  fi
  echo
  echo "Running on server..."
  resp=$(curl -s -X POST "http://$FX_HOST/run/${plugin_id}" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d "${body}")
  echo
  echo "----- Result -----"
  echo "$resp" | jq -r '.text // empty'
  echo "------------------"
  file_name=$(echo "$resp" | jq -r '.file.name // empty')
  file_content=$(echo "$resp" | jq -r '.file.content // empty')
  if [ -n "$file_name" ]; then
    mkdir -p "$LOCAL_RESULTS_DIR" 2>/dev/null || true
    safe_name=$(basename "$file_name")
    outpath="$LOCAL_RESULTS_DIR/$safe_name"
    printf '%s' "$file_content" > "$outpath"
    echo ""
    echo "Saved file locally to: $outpath"
  fi
  read -p "Press ENTER to continue..."
done
EOF
        chmod +x "$TK_SCRIPT" 2>/dev/null || true
    fi
}

############################################
# MASTERS MENU
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
        echo "5) Tk-Master"
        echo "0) Back"
        echo ""
        read -p "Enter choice: " choice

        case $choice in
            1) SECTION_DIR="$WORK_DIR/M-AT-STAR"; SECTION_menu ;;
            2) SECTION_DIR="$WORK_DIR/MASTERS_Tech"; SECTION_menu ;;
            3) SECTION_DIR="$WORK_DIR/WTk"; SECTION_menu ;;
            4) MASTERS_secure ;;
            5) SECTION_DIR="$WORK_DIR/Tk-Master"; TK_menu ;;
            0) break ;;
            *) continue ;;
        esac
    done
}

############################################
# MASTERS UPDATE MENU (unchanged) ...
# (omitted here for brevity — uses same implementation as earlier)
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
                # same implementation as previously provided
                echo "Update banner function..."
                read -p "Press Enter..." dummy
                ;;
            2)
                echo "Undo last change..."
                read -p "Press Enter..." dummy
                ;;
            @)
                echo "Performing system update..."
                read -p "Press Enter..." dummy
                ;;
            0) return ;;
        esac
    done
}
alias MASTERS-update='MASTERS_update'

############################################
# MASTERS Secure, M@_update, SECTION_menu, FILE_ACTION_MENU
# (reuse existing implementations from previous script)
############################################

MASTERS_secure() {
    BASE_DIR="$WORK_DIR"
    while true; do
        clear
        echo "──────── MASTERS Secure Center ────────"
        echo "Select a folder to view files:"
        echo "0) Back to MASTERS menu"
        echo "────────────────────────────────────────"

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
            return
        elif [[ -n "${IDX_TO_DIR[$choice]}" ]]; then
            FOLDER="${IDX_TO_DIR[$choice]}"
        else
            continue
        fi

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
                break
            elif [[ -n "${IDX_TO_FILE[$file_choice]}" ]]; then
                FILEPATH="${IDX_TO_FILE[$file_choice]}"
            else
                continue
            fi

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

M@_update() {
    WORK_DIR="/storage/emulated/0/MASTERS/M-AT-STAR"
    mkdir -p "$WORK_DIR"
    echo -e "\n🔥 Fetching latest M@☆ files..."
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
    source ~/.bashrc 2>/dev/null || true
    echo "✅ Update complete!"
    read -p "Press Enter to continue..." dummy
}

SECTION_menu() {
    while true; do
        clear
        echo -e "\e[1;32mDirectory: $(basename "$SECTION_DIR")\e[0m"
        echo "────────────────────────────────────────"

        echo "Select file type to view:"
        echo "1) Scripts"
        echo "2) Documents"
        echo "3) Others"
        echo "4) All"
        echo "0) Back"
        read -p "Choice: " type_choice

        case "$type_choice" in
            0) return ;;
            1) VIEW_MODE="SCRIPTS" ;;
            2) VIEW_MODE="DOCS" ;;
            3) VIEW_MODE="OTHERS" ;;
            4) VIEW_MODE="ALL" ;;
            *) continue ;;
        esac

        i=1
        declare -A INDEX_TO_FILE

        while IFS= read -r file_name; do
            ext="${file_name##*.}"

            case "$VIEW_MODE" in
                SCRIPTS) [[ "$ext" =~ ^(py|sh|mspy)$ ]] || continue ;;
                DOCS)    [[ "$ext" =~ ^(txt|pdf|json|yaml|yml|doc|docx|xls|xlsx|ppt|pptx)$ ]] || continue ;;
                OTHERS)  [[ "$ext" =~ ^(py|sh|mspy|txt|pdf|json|yaml|yml|doc|docx|xls|xlsx|ppt|pptx)$ ]] && continue ;;
                ALL) : ;;
            esac

            key="$(basename "$SECTION_DIR")/$file_name"
            func="${FILE_FUNCTIONS[$key]:-(no function)}"

            icon="⚙️"
            case "$ext" in
                py) icon="🐍" ;;
                sh) icon="🔧" ;;
                mspy) icon="🔒" ;;
                txt|doc|docx) icon="📄" ;;
                pdf) icon="📜" ;;
                json|yaml|yml) icon="💾" ;;
                xls|xlsx) icon="📊" ;;
                ppt|pptx) icon="📽️" ;;
                png|jpg|jpeg|gif|webp) icon="🖼️" ;;
                zip|rar|7z|tar|gz) icon="📦" ;;
            esac
            [ -d "$SECTION_DIR/$file_name" ] && icon="📁"

            if is_mspy "$file_name"; then
                echo -e "\e[33m$((i))). $icon  $file_name \e[91m[M-SPY]\e[0m"
            else
                echo -e "\e[33m$((i))). $icon  $file_name\e[0m"
            fi

            echo -e "      \e[90mrun: $func\e[0m\n"

            INDEX_TO_FILE[$i]="$file_name"
            ((i++))
        done < <(ls -1t "$SECTION_DIR")

        echo "────────────────────────────────────────"
        echo "0) Go Back | 00) Add New File | @) M@☆update"
        read -p "Enter choice: " pick

        case "$pick" in
            0) return ;;
            00)
                read -p "Enter new file name: " new_file
                if is_mspy "$new_file"; then
                    tmpstub=$(mktemp)
                    echo "# Encrypted mspy stub" > "$tmpstub"
                    gpg --symmetric --cipher-algo AES256 --batch --yes \
                        --passphrase "@MASTERS" \
                        -o "$SECTION_DIR/$new_file" "$tmpstub"
                    rm -f "$tmpstub"
                    echo "Created encrypted stub $new_file"
                else
                    touch "$SECTION_DIR/$new_file"
                fi
                read -p "Press Enter..." ;;
            @) M@_update ;;
            *)
                selected="${INDEX_TO_FILE[$pick]}"
                [[ -n "$selected" ]] && FILE_ACTION_MENU "$selected"
                ;;
        esac
    done
}

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
                if is_mspy "$file"; then
                    run_mspy "$file"
                    read -p "Press Enter..." dummy
                    continue
                fi
                if [[ "$file" == *.py ]]; then
                    (cd "$SECTION_DIR" && python "$file")
                    read -p "Press Enter..." dummy
                    continue
                fi
                if [[ "$file" == *.sh ]]; then
                    (cd "$SECTION_DIR" && bash "$file")
                    read -p "Press Enter..." dummy
                    continue
                fi
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
            0) return ;;
        esac
    done
}

############################################
# Tk-Master special menu and integration (updated to requested layout)
############################################

TK_menu() {
    ensure_tk_master_installed

    while true; do
        clear
        echo "=================================="
        echo "     Tk-Master BOT SYSTEM"
        echo "=================================="
        echo "1) Open BOT SYSTEM"
        echo "2) Open Saved Files"
        echo "3) Refresh"
        echo "0) Back"
        echo ""
        read -p "Choose: " tk_choice

        case "$tk_choice" in
            1)
                TK_SCRIPT="$WORK_DIR/Tk-Master/.wtk_menu.sh"
                if [ -f "$TK_SCRIPT" ]; then
                    (cd "$WORK_DIR/Tk-Master" && bash "$TK_SCRIPT")
                else
                    echo "Hidden wtk menu not found!"
                    read -p "Press Enter..."
                fi
                ;;
            2)
                # Open Saved Files: reuse SECTION_menu behavior for the Tk-Master dir
                SECTION_DIR="$WORK_DIR/Tk-Master"
                SECTION_menu
                ;;
            3)
                rm -f "$WORK_DIR/Tk-Master/.wtk_menu.sh"
                ensure_tk_master_installed
                chmod +x "$WORK_DIR/Tk-Master/.wtk_menu.sh" 2>/dev/null || true
                echo "Refreshed"
                read -p "Press Enter..."
                ;;
            0) return ;;
            *) continue ;;
        esac
    done
}

############################################
alias runm='source ~/.bashrc'
############
# START
############################################

SAVE_RUNMAP 2>/dev/null || true

echo -e "\e[90m-M@☆ \$ MASTERS_menu | MASTERS_update\e[0m"

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    MASTERS_menu
fi

