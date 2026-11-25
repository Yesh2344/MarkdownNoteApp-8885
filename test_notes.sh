#!/usr/bin/env bash
# test_notes.sh – Simple integration tests for MarkdownNoteApp.

set -euo pipefail

# Load the same config used by the app, but redirect to a temporary directory.
TEST_DIR="$(mktemp -d)"
export NOTES_DIR="${TEST_DIR}/notes"
export LOG_FILE="${TEST_DIR}/app.log"
export LOG_LEVEL="ERROR"   # silence INFO/WARN during tests

mkdir -p "${NOTES_DIR}"
source "./logger.sh"
source "./notes.sh"

# Helper to capture output.
capture() {
    "$@" 2>&1
}

# 1. Test note creation.
title="Test Note"
create_note "${title}"
if [[ ! -f "$(printf "%s/%s.md" "${NOTES_DIR}" "$(printf "%s" "${title}" | tr ' ' '_' )")" ]]; then
    echo "FAIL: create_note did not create the file"
    exit 1
fi
echo "PASS: create_note"

# 2. Test listing.
list_output=$(capture list_notes)
if ! grep -q "Test Note" <<<"${list_output}"; then
    echo "FAIL: list_notes did not list the created note"
    exit 1
fi
echo "PASS: list_notes"

# 3. Test view (fallback to cat).
view_output=$(capture view_note "${title}")
if [[ -z "${view_output}" ]]; then
    echo "FAIL: view_note produced no output"
    exit 1
fi
echo "PASS: view_note"

# 4. Test search.
search_output=$(capture search_notes "Test")
if ! grep -q "Test Note" <<<"${search_output}"; then
    echo "FAIL: search_notes did not find the note"
    exit 1
fi
echo "PASS: search_notes"

# 5. Test delete.
delete_note "${title}" <<< $'y'
if [[ -f "$(printf "%s/%s.md" "${NOTES_DIR}" "$(printf "%s" "${title}" | tr ' ' '_' )")" ]]; then
    echo "FAIL: delete_note did not remove the file"
    exit 1
fi
echo "PASS: delete_note"

# Clean up
rm -rf "${TEST_DIR}"
echo "All tests passed."