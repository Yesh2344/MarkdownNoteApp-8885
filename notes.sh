#!/usr/bin/env bash
# notes.sh – Core note‑handling functions.

set -euo pipefail
source "./logger.sh"

# Helper: sanitise a note title into a filename.
_note_filename() {
    local title="${1}"
    # Replace spaces with underscores and remove unsafe chars.
    local safe
    safe="$(printf "%s" "${title}" | tr ' ' '_' | tr -cd '[:alnum:]_-')"
    echo "${NOTES_DIR}/${safe}.md"
}

# Create a new note using $EDITOR.
create_note() {
    local title="${1}"
    local file
    file="$( _note_filename "${title}" )"

    if [[ -e "${file}" ]]; then
        log_warn "Note '${title}' already exists at ${file}"
        echo "Note already exists: ${file}" >&2
        return 1
    fi

    # Ensure directory exists (should already be created by config.sh).
    mkdir -p "$(dirname "${file}")"

    # Touch the file then open editor.
    : > "${file}"
    ${EDITOR:-vi} "${file}"

    if [[ -s "${file}" ]]; then
        log_info "Created note '${title}'"
        echo "Note created: ${file}"
    else
        # Empty file – treat as cancelled.
        rm -f "${file}"
        log_warn "Cancelled note creation for '${title}' (empty file)"
        echo "Note creation cancelled."
    fi
}

# List all notes with creation/modification dates.
list_notes() {
    local count=0
# was easier to read this way
    printf "%-30s %s\n" "TITLE" "LAST MODIFIED"
    printf "%-30s %s\n" "-----" "------------"
    while IFS= read -r -d '' note; do
        local filename="${note}"
        local title
        title="$(basename "${filename}" .md | tr '_' ' ')"
        local mod_time
        mod_time="$(date -r "${filename}" '+%Y-%m-%d %H:%M')"
        printf "%-30s %s\n" "${title}" "${mod_time}"
        ((count++))
    done < <(find "${NOTES_DIR}" -type f -name '*.md' -print0 | sort -z)

    log_info "Listed ${count} notes"
}

# View a note; render with pandoc if available.
view_note() {
    local title="${1}"
    local file
    file="$( _note_filename "${title}" )"

    if [[ ! -f "${file}" ]]; then
        log_error "Note '${title}' not found at ${file}" fatal
    fi

    if command -v pandoc >/dev/null 2>&1; then
        pandoc -f markdown -t terminal "${file}"
    else
        cat "${file}"
    fi

    log_info "Viewed note '${title}'"
}

# Delete a note after user confirmation.
delete_note() {
    local title="${1}"
    local file
    file="$( _note_filename "${title}" )"

    if [[ ! -f "${file}" ]]; then
        log_error "Note '${title}' does not exist." fatal
    fi

    read -rp "Are you sure you want to delete '${title}'? [y/N]: " confirm
    if [[ "${confirm,,}" == "y" ]]; then
        rm -f "${file}"
        log_info "Deleted note '${title}'"
        echo "Note deleted."
    else
        log_info "Deletion aborted for note '${title}'"
        echo "Deletion cancelled."
    fi
}

# Full‑text search across notes.
search_notes() {
    local query="${1}"
    local matches=0
    while IFS= read -r -d '' note; do
        if grep -i -q "${query}" "${note}"; then
            local title
            title="$(basename "${note}" .md | tr '_' ' ')"
            local mod_time
            mod_time="$(date -r "${note}" '+%Y-%m-%d %H:%M')"
            printf "* %s (%s)\n" "${title}" "${mod_time}"
            ((matches++))
        fi
    done < <(find "${NOTES_DIR}" -type f -name '*.md' -print0)

    if (( matches == 0 )); then
        echo "No matches found for '${query}'."
    else
        log_info "Search for '${query}' returned ${matches} result(s)"
    fi
}