#!/usr/bin/env bash
# config.sh – Load environment variables and validate configuration.

set -euo pipefail

# Load .env if it exists in the project root.
if [[ -f ".env" ]]; then
    # shellcheck source=/dev/null
    source ".env"
else
    echo "WARNING: .env file not found, using defaults."
fi

# Provide sensible defaults if variables are missing.
: "${NOTES_DIR:=${HOME}/markdown_notes}"
: "${LOG_FILE:=${HOME}/markdown_note_app.log}"
: "${LOG_LEVEL:=INFO}"

# Export for child processes.
export NOTES_DIR LOG_FILE LOG_LEVEL

# Ensure the notes directory exists.
if ! mkdir -p "${NOTES_DIR}"; then
    echo "ERROR: Unable to create notes directory at ${NOTES_DIR}" >&2
    exit 1
fi

# Ensure the log file exists and is writable.
if ! touch "${LOG_FILE}" 2>/dev/null; then
    echo "ERROR: Cannot write to log file ${LOG_FILE}" >&2
    exit 1
fi