#!/usr/bin/env bash
# main.sh – Entry point for MarkdownNoteApp.

set -euo pipefail

# Load configuration and utilities.
source "./config.sh"
source "./notes.sh"
source "./logger.sh"

print_help() {
    cat <<'EOF'
MarkdownNoteApp – Manage Markdown notes from the command line.

Usage:
  ./main.sh <command> [arguments]

Commands:
  create <title>      Create a new note (opens $EDITOR)
  list                List all notes
  view <title>        View a note (rendered if pandoc is installed)
  delete <title>      Delete a note (asks for confirmation)
  search <query>      Full‑text search notes
  help                Show this help message
EOF
}

# Ensure a command is supplied.
if [[ $# -lt 1 ]]; then
    echo "Error: No command supplied."
    print_help
    exit 1
fi

cmd="${1}"
shift || true

case "${cmd}" in
    create)
        if [[ $# -lt 1 ]]; then
            echo "Error: 'create' requires a note title."
            exit 1
        fi
        create_note "$*"
        ;;
    list)
        list_notes
        ;;
    view)
        if [[ $# -lt 1 ]]; then
            echo "Error: 'view' requires a note title."
            exit 1
        fi
        view_note "$*"
        ;;
    delete)
        if [[ $# -lt 1 ]]; then
            echo "Error: 'delete' requires a note title."
            exit 1
        fi
        delete_note "$*"
        ;;
    search)
        if [[ $# -lt 1 ]]; then
            echo "Error: 'search' requires a query string."
            exit 1
        fi
        search_notes "$*"
        ;;
    help|--help|-h)
        print_help
        ;;
    *)
        echo "Error: Unknown command '${cmd}'."
        print_help
        exit 1
        ;;
esac