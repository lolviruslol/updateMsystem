#!/data/data/com.termux/files/usr/bin/bash

##############################
#  MASTERS SYSTEM M@☆
###############################
# Combined MASTERS system with integrated Tk-Master (hidden .wtk_menu.sh)
# - When you choose "Tk-Master" from the MASTERS menu it will ensure
#   the Tk-Master folder exists and the hidden .wtk_menu.sh is installed there,
#   then show the "Tk-Master BOT SYSTEM" menu which launches the hidden script.
#
# This file restores the full original MASTERS_update implementation and
# embeds the original wtk_menu.sh contents (exact) as a hidden file.
shopt -s expand_aliases

############################################
# AUTO INSTALL DEPENDENCIES
############################################

required_pkgs=(ruby figlet cmatrix chafa python termux-api jq curl gpg wget)
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

    # If the hidden script does not exist, write the bundled original wtk_menu.sh into place.
    if [ ! -f "$TK_SCRIPT" ]; then
        cat > "$TK_SCRIPT" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# Dynamic Termux menu: fetch /plugins and build prompts automatically.
# Saves returned plugin files to current working directory ($PWD) by default.
# To save to another path, set SAVE_DIR environment variable before running:
#   SAVE_DIR="/storage/emulated/0/MASTERS/Tk_Master" bash wtk_menu.sh
# Set AUTO_UPLOAD=1 to auto-upload the first local file match for *_file inputs.

FX_HOST="fx.tkmaster.qzz.io:8000"
TOKEN="123000"

# Determine default local save directory:
LOCAL_RESULTS_DIR="${SAVE_DIR:-$PWD}"
mkdir -p "$LOCAL_RESULTS_DIR" 2>/dev/null || true

# fetch plugins list
fetch_plugins() {
  curl -s -H "Authorization: Bearer $TOKEN" "http://$FX_HOST/plugins" | jq -r '.plugins'
}

# Safely add a key/value to JSON body using jq.
# It tries to detect integers, floats, and booleans and add them as proper JSON types.
add_kv_to_body() {
  local body_json="$1"; local key="$2"; local val="$3"
  # detect boolean
  local val_lc="${val,,}"
  if [[ "$val_lc" == "true" || "$val_lc" == "false" ]]; then
    echo "$body_json" | jq --arg k "$key" --argjson v "$val_lc" '. + {($k): $v}'
    return
  fi
  # detect integer
  if [[ "$val" =~ ^-?[0-9]+$ ]]; then
    echo "$body_json" | jq --arg k "$key" --argjson v "$val" '. + {($k): $v}'
    return
  fi
  # detect float
  if [[ "$val" =~ ^-?[0-9]*\.[0-9]+$ ]]; then
    echo "$body_json" | jq --arg k "$key" --argjson v "$val" '. + {($k): $v}'
    return
  fi
  # fallback to string
  echo "$body_json" | jq --arg k "$key" --arg v "$val" '. + {($k): $v}'
}

# Build body for plugin JSON using jq (no Python needed)
# After prompting for each input, auto-attach local file contents for any key that ends with "_file".
# Behavior:
# - Look in this order for a simple basename (e.g. "hosts.txt"):
#     1) $PWD (where you launched the menu)
#     2) $LOCAL_RESULTS_DIR (current save dir shown in menu)
#     3) literal path provided by user
# - If AUTO_UPLOAD=1 env var is set the script will upload the first found file without asking.
# - Otherwise it will ask confirmation before uploading a local file.
# - If a companion *_content key is already present in the body (because we auto-attached it),
#   we skip prompting for that input so we don't overwrite it.
build_body() {
  plugin_json="$1"
  body='{}'
  input_count=$(echo "$plugin_json" | jq '.inputs | length')
  for i in $(seq 0 $((input_count - 1))); do
    key=$(echo "$plugin_json" | jq -r ".inputs[$i].name")
    prompt=$(echo "$plugin_json" | jq -r ".inputs[$i].prompt")
    # skip save_client input here (we'll add it later if needed)
    if [ "$key" == "save_client" ]; then
      continue
    fi

    # If this key already exists in body (e.g. we previously attached hosts_content),
    # skip prompting to avoid overwriting it.
    has_key=$(echo "$body" | jq -r --arg k "$key" 'has($k)' 2>/dev/null || echo "false")
    if [ "$has_key" == "true" ]; then
      continue
    fi

    # Prompt the user
    read -p "$prompt " val

    # If this input key looks like a file (ends with _file) try to auto-resolve from local phone
    if [[ "$key" =~ _file$ ]]; then
      # if empty, attempt to extract default filename from prompt (e.g. 'default: hosts.txt')
      if [ -z "$val" ]; then
        default_guess=$(echo "$prompt" | sed -nE 's/.*[dD]efault: *([^)\]:]+).*/\1/p' | tr -d '[:space:]')
        if [ -z "$default_guess" ]; then
          default_guess="hosts.txt"
        fi
        val="$default_guess"
      fi

      # Candidate paths in preferred order: PWD first, then LOCAL_RESULTS_DIR, then literal
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
          # read content and attach as companion key
          # preserve newlines
          content=$(cat "$found_local")
          body=$(add_kv_to_body "$body" "$key" "$found_local")
          comp="${key%_file}_content"
          # only add companion content if not already present
          has_comp=$(echo "$body" | jq -r --arg k "$comp" 'has($k)' 2>/dev/null || echo "false")
          if [ "$has_comp" != "true" ]; then
            body=$(echo "$body" | jq --arg k "$comp" --arg v "$content" '. + {($k): $v}')
          fi
          # move to next input
          continue
        fi
        # user declined -> fall through and use what they typed (val)
      fi
      # if not found locally or user declined, continue to add value typed (maybe filename on server)
    fi

    # Add the provided value into the JSON body (with type detection)
    body=$(add_kv_to_body "$body" "$key" "$val")
  done

  echo "$body"
}

# Build body for plugin JSON using jq (no Python needed)
# After prompting for each input, auto-attach local file contents for any key that ends with "_file".
# Behavior:
# - Look in this order for a simple basename (e.g. "hosts.txt"):
#     1) $PWD (where you launched the menu)
#     2) $LOCAL_RESULTS_DIR (current save dir shown in menu)
#     3) literal path provided by user
# - If AUTO_UPLOAD=1 env var is set the script will upload the first found file without asking.
# - Otherwise it will ask confirmation before uploading a local file.
# - If a companion *_content key is already present in the body (because we auto-attached it),
#   we skip prompting for that input so we don't overwrite it.

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

  # Render menu
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

  # Build body for inputs (skips save_client)
  body=$(build_body "$plugin")

  # If plugin supports client save, ask the user if they want the file saved locally and set save_client flag
  if [ "$supports_client_save" == "true" ] || [ "$supports_client_save" == "True" ]; then
    read -p "Save file locally after server returns it? (y/N): " yn
    if [[ "$yn" =~ ^[Yy] ]]; then
      body=$(echo "$body" | jq '. + {"save_client": true}')
    fi
  fi

  # Call plugin
  echo
  echo "Running on server..."
  resp=$(curl -s -X POST "http://$FX_HOST/run/${plugin_id}" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d "${body}")

  # Print server text result
  echo
  echo "----- Result -----"
  echo "$resp" | jq -r '.text // empty'
  echo "------------------"

  # If server returned a file, save it locally to LOCAL_RESULTS_DIR
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
        echo "5) Tk-Master"
        echo "0) Back"
        echo ""
        read -p "Enter choice: " choice

        case $choice in
            1) SECTION_DIR="$WORK_DIR/M-AT-STAR"; SECTION_menu ;;
            2) SECTION_DIR="$WORK_DIR/MASTERS_Tech"; SECTION_menu ;;
            3) SECTION_DIR="$WORK_DIR/WTk"; SECTION_menu ;;
            4) MASTERS_secure ;;
            5) SECTION_DIR="$WORK_DIR/Tk-Master"; TK_menu ;;   # special Tk-Master handler
            0) break ;;   # <- just exit the menu loop instead of exiting Termux
            *) continue ;;
        esac
    done
}

############################################
# MASTERS UPDATE MENU (fully restored)
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
                # Decrypt existing termux.gpg into a temp file (if it exists)
                if ! gpg --quiet --batch --yes --passphrase "@MASTERS" --decrypt ~/termux.gpg > "$TMP_FILE" 2>/dev/null; then
                    # If decrypt failed, create a basic temp file so we can proceed
                    echo -e "# termux config\n" > "$TMP_FILE"
                fi

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

                # Store undo: set PREVIOUS_BANNER variable in the temp file (best-effort)
                if grep -q '^PREVIOUS_BANNER=' "$TMP_FILE" 2>/dev/null; then
                    sed -i "s/^PREVIOUS_BANNER=.*/PREVIOUS_BANNER=\"$CURRENT_BANNER\"/" "$TMP_FILE" 2>/dev/null
                else
                    echo "PREVIOUS_BANNER=\"$CURRENT_BANNER\"" >> "$TMP_FILE"
                fi

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
                if ! gpg --quiet --batch --yes --passphrase "@MASTERS" --decrypt ~/termux.gpg > "$TMP_FILE" 2>/dev/null; then
                    echo -e "\nNo termux.gpg found or decrypt failed."
                    read -p "Press Enter..." dummy
                    rm -f "$TMP_FILE"
                    continue
                fi

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
# MASTERS Secure, M@_update, SECTION_menu, FILE_ACTION_MENU (restored)
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

##########################################################
############################################
# SECTION MENU — WITH TYPE FILTER (FIXED)
############################################

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

            # ---------------- FILTER LOGIC ----------------
            case "$VIEW_MODE" in
                SCRIPTS)
                    [[ "$ext" =~ ^(py|sh|mspy)$ ]] || continue
                    ;;
                DOCS)
                    [[ "$ext" =~ ^(txt|pdf|json|yaml|yml|doc|docx|xls|xlsx|ppt|pptx)$ ]] || continue
                    ;;
                OTHERS)
                    # Exclude Scripts + Documents
                    [[ "$ext" =~ ^(py|sh|mspy|txt|pdf|json|yaml|yml|doc|docx|xls|xlsx|ppt|pptx)$ ]] && continue
                    ;;
                ALL)
                    : # no filter
                    ;;
            esac
            # ------------------------------------------------

            key="$(basename "$SECTION_DIR")/$file_name"
            func="${FILE_FUNCTIONS[$key]:-(no function)}"

            # ICON DETECTION
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

            # DISPLAY
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
            0) MASTERS_menu; return ;;
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
# Tk-Master special menu and integration (requested layout)
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
                # Overwrite script from bundle
                rm -f "$WORK_DIR/Tk-Master/.wtk_menu.sh"
                ensure_tk_master_installed
                echo "Refreshed"
                chmod +x "$WORK_DIR/Tk-Master/.wtk_menu.sh" 2>/dev/null || true
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

# ensure aliases reflect current runmap on shell start
SAVE_RUNMAP 2>/dev/null || true

echo -e "\e[90m-M@☆ \$ MASTERS_menu | MASTERS_update\e[0m"

# Auto-launch main menu if executed directly
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    MASTERS_menu
fi
