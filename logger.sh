#!/usr/bin/env bash
# logger.sh – Simple structured logger with levels.

set -euo pipefail

# Expected LOG_LEVEL values: INFO, WARN, ERROR
# Lower index = more verbose.
declare -A LOG_LEVELS=([INFO]=0 [WARN]=1 [ERROR]=2)

# Internal helper to get numeric level.
_get_level() {
    local level="${1}"
    echo "${LOG_LEVELS[${level}]}"
}

# Core logging function.
_log() {
    local level="${1}"
    shift
    local message="${*}"
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"

    # Compare requested level with configured LOG_LEVEL.
    if [[ $(_get_level "${level}") -ge $(_get_level "${LOG_LEVEL}") ]]; then
        printf "[%s] [%s] %s\n" "${timestamp}" "${level}" "${message}" >> "${LOG_FILE}"
    fi
}

log_info() {
    _log "INFO" "$@"
}

log_warn() {
    _log "WARN" "$@"
}

log_error() {
    _log "ERROR" "$@"
    # If the error is fatal, exit with non‑zero status.
    if [[ "${2:-}" == "fatal" ]]; then
        exit 1
    fi
}