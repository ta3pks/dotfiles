#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# bootstrap.sh — Single-command dotfiles environment setup
# =============================================================================
# Creates symlinks for selected tool configurations with interactive TUI
# or non-interactive CLI flags.
#
# Usage: ./bootstrap.sh [--dry-run] [--undo] [--all] [--essential] [--conflict=MODE] [--help]

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
PREREQ_FILE="${SCRIPT_DIR}/prerequisites.json"
MANIFEST_FILE="${SCRIPT_DIR}/.bootstrap-manifest"

# ---------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------
DRY_RUN=0
UNDO=0
MODE=""
CONFLICT_STRATEGY=""
HELP=0

# Counters
COUNT_LINKED=0
COUNT_SKIPPED=0
COUNT_BACKED_UP=0
COUNT_ERRORED=0

# ---------------------------------------------------------------------------
# Color helpers (respect NO_COLOR)
# ---------------------------------------------------------------------------
if [[ -z "${NO_COLOR:-}" ]] && [[ -t 1 ]]; then
    _RED='\033[0;31m'
    _GREEN='\033[0;32m'
    _YELLOW='\033[0;33m'
    _BLUE='\033[0;34m'
    _BOLD='\033[1m'
    _RESET='\033[0m'
else
    _RED='' _GREEN='' _YELLOW='' _BLUE='' _BOLD='' _RESET=''
fi

log_info()  { printf "${_GREEN}[INFO]${_RESET}  %s\n" "$*"; }
log_warn()  { printf "${_YELLOW}[WARN]${_RESET}  %s\n" "$*"; }
log_error() { printf "${_RED}[ERROR]${_RESET} %s\n" "$*" >&2; }
log_dry()   { printf "${_BLUE}[DRY]${_RESET}   %s\n" "$*"; }

# ---------------------------------------------------------------------------
# Usage
# ---------------------------------------------------------------------------
usage() {
    cat <<USAGE
${_BOLD}bootstrap.sh${_RESET} — Dotfiles environment setup

${_BOLD}USAGE:${_RESET}
    ./bootstrap.sh [OPTIONS]

${_BOLD}OPTIONS:${_RESET}
    --dry-run               Preview changes without creating symlinks
    --undo                  Remove symlinks and restore backups (stub)
    --all                   Select all tools (non-interactive)
    --essential             Select essential tools only (non-interactive)
    --conflict=MODE         Conflict strategy: overwrite, backup, skip
    --help                  Show this help message

${_BOLD}EXIT CODES:${_RESET}
    0   Success
    1   General error (missing tool prerequisites)
    2   Missing core prerequisites (jq, whiptail)

${_BOLD}EXAMPLES:${_RESET}
    ./bootstrap.sh                              Interactive mode with whiptail
    ./bootstrap.sh --essential --conflict=skip  Non-interactive essential setup
    ./bootstrap.sh --all --conflict=backup      Non-interactive full setup
    ./bootstrap.sh --dry-run --all              Preview all symlinks
USAGE
}

# ---------------------------------------------------------------------------
# Flag parsing
# ---------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        --undo)
            UNDO=1
            shift
            ;;
        --all)
            MODE="all"
            shift
            ;;
        --essential)
            MODE="essential"
            shift
            ;;
        --conflict=*)
            CONFLICT_STRATEGY="${1#--conflict=}"
            if [[ ! "$CONFLICT_STRATEGY" =~ ^(overwrite|backup|skip)$ ]]; then
                log_error "Invalid conflict strategy: $CONFLICT_STRATEGY"
                log_error "Valid options: overwrite, backup, skip"
                exit 1
            fi
            shift
            ;;
        --help|-h)
            HELP=1
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

if [[ "$HELP" -eq 1 ]]; then
    usage
    exit 0
fi

# ---------------------------------------------------------------------------
# Undo stub (implemented in Plan 02)
# ---------------------------------------------------------------------------
if [[ "$UNDO" -eq 1 ]]; then
    log_warn "Undo functionality will be implemented in a future update."
    log_warn "To manually undo, remove symlinks listed in: $MANIFEST_FILE"
    exit 0
fi

# ---------------------------------------------------------------------------
# Core prerequisite check
# ---------------------------------------------------------------------------
check_core_prerequisites() {
    if [[ ! -f "$PREREQ_FILE" ]]; then
        log_error "Prerequisites file not found: $PREREQ_FILE"
        exit 2
    fi

    local missing=()
    local core_tools
    core_tools=$(jq -r '.core | keys[]' "$PREREQ_FILE")

    while IFS= read -r tool; do
        local check_cmd
        check_cmd=$(jq -r ".core.\"$tool\".check" "$PREREQ_FILE")
        if ! eval "$check_cmd" &>/dev/null; then
            local desc
            desc=$(jq -r ".core.\"$tool\".description" "$PREREQ_FILE")
            missing+=("  - $tool: $desc")
        fi
    done <<< "$core_tools"

    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing core prerequisites (cannot continue):"
        for m in "${missing[@]}"; do
            printf "%s\n" "$m" >&2
        done
        exit 2
    fi
}

check_core_prerequisites

# ---------------------------------------------------------------------------
# Load tool list from prerequisites.json
# ---------------------------------------------------------------------------
get_all_tools() {
    jq -r '.tools | keys[]' "$PREREQ_FILE"
}

get_essential_tools() {
    jq -r '.tools | to_entries[] | select(.value.category == "essential") | .key' "$PREREQ_FILE"
}

get_tool_description() {
    jq -r ".tools.\"$1\".description // \"$1\"" "$PREREQ_FILE"
}

get_tool_category() {
    jq -r ".tools.\"$1\".category // \"optional\"" "$PREREQ_FILE"
}

get_tool_check() {
    jq -r ".tools.\"$1\".check // \"true\"" "$PREREQ_FILE"
}

# ---------------------------------------------------------------------------
# Tool selection
# ---------------------------------------------------------------------------
select_tools() {
    local selected_tools=()

    if [[ "$MODE" == "all" ]]; then
        while IFS= read -r tool; do
            selected_tools+=("$tool")
        done < <(get_all_tools)
    elif [[ "$MODE" == "essential" ]]; then
        while IFS= read -r tool; do
            selected_tools+=("$tool")
        done < <(get_essential_tools)
    else
        # Interactive whiptail checklist
        if ! command -v whiptail &>/dev/null; then
            log_error "whiptail not found. Use --all or --essential for non-interactive mode."
            exit 2
        fi

        local checklist_args=()
        local tool_order=()

        # Essential tools first (sorted), then optional (sorted)
        while IFS= read -r tool; do
            tool_order+=("$tool")
        done < <(jq -r '.tools | to_entries[] | select(.value.category == "essential") | .key' "$PREREQ_FILE" | sort)

        while IFS= read -r tool; do
            tool_order+=("$tool")
        done < <(jq -r '.tools | to_entries[] | select(.value.category == "optional") | .key' "$PREREQ_FILE" | sort)

        for tool in "${tool_order[@]}"; do
            local desc
            desc=$(get_tool_description "$tool")
            local state="OFF"
            if [[ "$(get_tool_category "$tool")" == "essential" ]]; then
                state="ON"
            fi
            checklist_args+=("$tool" "$desc" "$state")
        done

        local terminal_height
        terminal_height=$(tput lines 2>/dev/null || echo 24)
        local list_height=$(( terminal_height - 10 ))
        if [[ $list_height -lt 10 ]]; then list_height=10; fi
        if [[ $list_height -gt 30 ]]; then list_height=30; fi

        local result
        result=$(whiptail --title "Dotfiles Bootstrap" \
            --checklist "Select tools to configure.\nEssential tools are pre-selected." \
            "$terminal_height" 70 "$list_height" \
            "${checklist_args[@]}" \
            3>&1 1>&2 2>&3) || {
            log_warn "Selection cancelled."
            exit 0
        }

        # Parse whiptail output (space-separated, quoted)
        for tool in $result; do
            tool="${tool//\"/}"
            selected_tools+=("$tool")
        done
    fi

    if [[ ${#selected_tools[@]} -eq 0 ]]; then
        log_warn "No tools selected. Nothing to do."
        exit 0
    fi

    printf "%s\n" "${selected_tools[@]}"
}

SELECTED_TOOLS=()
while IFS= read -r tool; do
    SELECTED_TOOLS+=("$tool")
done < <(select_tools)

log_info "Selected ${#SELECTED_TOOLS[@]} tool(s): ${SELECTED_TOOLS[*]}"

# ---------------------------------------------------------------------------
# Conflict strategy
# ---------------------------------------------------------------------------
select_conflict_strategy() {
    if [[ -n "$CONFLICT_STRATEGY" ]]; then
        echo "$CONFLICT_STRATEGY"
        return
    fi

    # Interactive whiptail radiolist
    local result
    result=$(whiptail --title "Conflict Strategy" \
        --radiolist "How should existing files at target locations be handled?" \
        15 60 3 \
        "backup"    "Create .bak backup, then symlink" ON \
        "overwrite" "Overwrite (creates .bak first)"   OFF \
        "skip"      "Skip conflicting files"            OFF \
        3>&1 1>&2 2>&3) || {
        log_warn "Strategy selection cancelled."
        exit 0
    }

    echo "$result"
}

CONFLICT_STRATEGY=$(select_conflict_strategy)
log_info "Conflict strategy: $CONFLICT_STRATEGY"

# ---------------------------------------------------------------------------
# Per-tool prerequisite check
# ---------------------------------------------------------------------------
check_tool_prerequisites() {
    local missing=()

    for tool in "${SELECTED_TOOLS[@]}"; do
        local check_cmd
        check_cmd=$(get_tool_check "$tool")
        if [[ "$check_cmd" != "true" ]] && ! eval "$check_cmd" &>/dev/null; then
            local desc
            desc=$(get_tool_description "$tool")
            missing+=("  - $tool: $desc (check: $check_cmd)")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing prerequisites for selected tools:"
        for m in "${missing[@]}"; do
            printf "%s\n" "$m" >&2
        done
        exit 1
    fi
}

check_tool_prerequisites

# ---------------------------------------------------------------------------
# Symlink creation helpers
# ---------------------------------------------------------------------------
expand_tilde() {
    echo "${1/#\~/$HOME}"
}

handle_conflict() {
    local target="$1"

    case "$CONFLICT_STRATEGY" in
        overwrite|backup)
            local backup="${target}.bak"
            if [[ "$DRY_RUN" -eq 1 ]]; then
                log_dry "Would back up: $target -> $backup"
            else
                mv "$target" "$backup"
                log_info "Backed up: $target -> $backup"
            fi
            ((COUNT_BACKED_UP++)) || true
            return 0
            ;;
        skip)
            if [[ "$DRY_RUN" -eq 1 ]]; then
                log_dry "Would skip: $target (conflict)"
            else
                log_warn "Skipped: $target (exists, conflict strategy: skip)"
            fi
            ((COUNT_SKIPPED++)) || true
            return 1
            ;;
    esac
}

create_symlink() {
    local src="$1"
    local dest="$2"
    local abs_src="${SCRIPT_DIR}/${src}"

    # Verify source exists
    if [[ ! -e "$abs_src" ]]; then
        log_warn "Source does not exist, skipping: $abs_src"
        ((COUNT_ERRORED++)) || true
        return
    fi

    local dest_expanded
    dest_expanded=$(expand_tilde "$dest")

    # Create parent directory
    local parent_dir
    parent_dir=$(dirname "$dest_expanded")
    if [[ ! -d "$parent_dir" ]]; then
        if [[ "$DRY_RUN" -eq 1 ]]; then
            log_dry "Would create directory: $parent_dir"
        else
            mkdir -p "$parent_dir"
        fi
    fi

    # Check current state of target
    if [[ -L "$dest_expanded" ]]; then
        local current_target
        current_target=$(readlink -f "$dest_expanded" 2>/dev/null || echo "")
        local expected_target
        expected_target=$(readlink -f "$abs_src" 2>/dev/null || echo "$abs_src")

        if [[ "$current_target" == "$expected_target" ]]; then
            if [[ "$DRY_RUN" -eq 1 ]]; then
                log_dry "Already linked: $dest_expanded -> $abs_src"
            else
                log_info "Already linked: $dest_expanded"
            fi
            ((COUNT_SKIPPED++)) || true
            return
        else
            # Symlink to wrong target — treat as conflict
            if ! handle_conflict "$dest_expanded"; then
                return
            fi
        fi
    elif [[ -e "$dest_expanded" ]]; then
        # Regular file or directory exists — apply conflict strategy
        if ! handle_conflict "$dest_expanded"; then
            return
        fi
    fi

    # Create symlink
    local ln_flags="-sf"
    if [[ -d "$abs_src" ]]; then
        ln_flags="-snf"
    fi

    if [[ "$DRY_RUN" -eq 1 ]]; then
        log_dry "Would link: $dest_expanded -> $abs_src"
    else
        ln $ln_flags "$abs_src" "$dest_expanded"
        log_info "Linked: $dest_expanded -> $abs_src"
    fi
    ((COUNT_LINKED++)) || true
}

# ---------------------------------------------------------------------------
# Symlink creation loop
# ---------------------------------------------------------------------------
create_symlinks_for_tool() {
    local tool="$1"

    local symlink_type
    symlink_type=$(jq -r ".tools.\"$tool\".symlinks.type" "$PREREQ_FILE")

    local mapping_count
    mapping_count=$(jq ".tools.\"$tool\".symlinks.mappings | length" "$PREREQ_FILE")

    for (( i=0; i<mapping_count; i++ )); do
        local src dest
        src=$(jq -r ".tools.\"$tool\".symlinks.mappings[$i].src" "$PREREQ_FILE")
        dest=$(jq -r ".tools.\"$tool\".symlinks.mappings[$i].dest" "$PREREQ_FILE")

        # Handle glob patterns (nested type with *)
        if [[ "$src" == *'*' ]]; then
            local src_pattern="${SCRIPT_DIR}/${src}"
            local dest_dir
            dest_dir=$(expand_tilde "$dest")

            # Create destination directory if needed
            if [[ ! -d "$dest_dir" ]] && [[ "$DRY_RUN" -eq 0 ]]; then
                mkdir -p "$dest_dir"
            elif [[ "$DRY_RUN" -eq 1 ]] && [[ ! -d "$dest_dir" ]]; then
                log_dry "Would create directory: $dest_dir"
            fi

            # Expand glob
            local glob_files=()
            # Use nullglob to handle no matches
            local old_nullglob
            old_nullglob=$(shopt -p nullglob 2>/dev/null || echo "shopt -u nullglob")
            shopt -s nullglob
            glob_files=($src_pattern)
            eval "$old_nullglob"

            if [[ ${#glob_files[@]} -eq 0 ]]; then
                log_warn "No files match pattern: $src"
                continue
            fi

            for file in "${glob_files[@]}"; do
                local filename
                filename=$(basename "$file")
                local file_rel="${src%\*}${filename}"
                local file_dest="${dest}${filename}"
                create_symlink "$file_rel" "$file_dest"
            done
        else
            create_symlink "$src" "$dest"
        fi
    done
}

log_info "Creating symlinks..."
echo ""

for tool in "${SELECTED_TOOLS[@]}"; do
    printf -- "${_BOLD}--- %s ---${_RESET}\n" "$tool"
    create_symlinks_for_tool "$tool"
    echo ""
done

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
printf "${_BOLD}========== Summary ==========${_RESET}\n"
if [[ "$DRY_RUN" -eq 1 ]]; then
    printf "${_BLUE}(Dry run — no changes were made)${_RESET}\n"
fi
printf "  Linked:    %d\n" "$COUNT_LINKED"
printf "  Skipped:   %d\n" "$COUNT_SKIPPED"
printf "  Backed up: %d\n" "$COUNT_BACKED_UP"
printf "  Errors:    %d\n" "$COUNT_ERRORED"
echo ""

# ---------------------------------------------------------------------------
# Verification (skip in dry-run mode)
# ---------------------------------------------------------------------------
if [[ "$DRY_RUN" -eq 0 ]]; then
    log_info "Verifying symlinks..."
    verify_errors=0

    for tool in "${SELECTED_TOOLS[@]}"; do
        local mapping_count
        mapping_count=$(jq ".tools.\"$tool\".symlinks.mappings | length" "$PREREQ_FILE")

        for (( i=0; i<mapping_count; i++ )); do
            local src dest
            src=$(jq -r ".tools.\"$tool\".symlinks.mappings[$i].src" "$PREREQ_FILE")
            dest=$(jq -r ".tools.\"$tool\".symlinks.mappings[$i].dest" "$PREREQ_FILE")

            # Skip glob patterns for verification (individual files were verified during creation)
            if [[ "$src" == *'*' ]]; then
                continue
            fi

            local dest_expanded
            dest_expanded=$(expand_tilde "$dest")
            local abs_src="${SCRIPT_DIR}/${src}"

            if [[ -L "$dest_expanded" ]]; then
                local actual
                actual=$(readlink -f "$dest_expanded" 2>/dev/null || echo "")
                local expected
                expected=$(readlink -f "$abs_src" 2>/dev/null || echo "$abs_src")

                if [[ "$actual" != "$expected" ]]; then
                    log_error "Verification failed: $dest_expanded -> $actual (expected $expected)"
                    ((verify_errors++)) || true
                fi
            elif [[ "$CONFLICT_STRATEGY" != "skip" ]]; then
                log_error "Verification failed: $dest_expanded is not a symlink"
                ((verify_errors++)) || true
            fi
        done
    done

    if [[ "$verify_errors" -eq 0 ]]; then
        log_info "All symlinks verified successfully."
    else
        log_error "$verify_errors symlink(s) failed verification."
    fi
fi

log_info "Bootstrap complete."
