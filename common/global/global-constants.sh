#!/usr/bin/env bash
#
# Source      : common/global/global-constants.sh
# Dependencies: None
# Description : Global constants used in cross-projects.
#

[[ -n "${G__GLOBAL_CONSTANTS_SH_LOADED:-}" ]] && return 0
export G__GLOBAL_CONSTANTS_SH_LOADED=1

# =============================================================================
# Global Constants
# =============================================================================
# ----- Terminal & UI Styling -----
# ANSI escape sequences for terminal output colors
export G__BLACK=$'\033[0;30m'
export G__RED=$'\033[0;31m'
export G__GREEN=$'\033[0;32m'
export G__YELLOW=$'\033[0;33m'
export G__BLUE=$'\033[0;34m'
export G__MAGENTA=$'\033[0;35m'
export G__CYAN=$'\033[0;36m'
export G__WHITE=$'\033[0;37m'
export G__BOLD=$'\033[1m'
export G__NC=$'\033[0m' # No Color

# ----- Layout & Table Formatting -----
# Terminal heading dividers and line width
export G__DIVIDER_WIDTH=80

printf -v _divider_padding '%*s' "$G__DIVIDER_WIDTH" ''
export G__DIVIDER_H0="${_divider_padding// /@}"
export G__DIVIDER_H1="${_divider_padding// /#}"
export G__DIVIDER_H2="${_divider_padding// /=}"
export G__DIVIDER_H3="${_divider_padding// /-}"
export G__DIVIDER_H4="${_divider_padding// /.}"
unset _divider_padding

# Table formatting manifest
export G__ROW_PREFIX="| "
export G__ROW_PREFIX_LEN=${#G__ROW_PREFIX}
export G__ROW_SUFFIX=" |"
export G__ROW_SUFFIX_LEN=${#G__ROW_SUFFIX}
export G__HEADER_SEPARATOR=" | "
export G__HEADER_SEPARATOR_LEN=${#G__HEADER_SEPARATOR}
export G__COL_SEPARATOR=" : "
export G__COL_SEPARATOR_LEN=${#G__COL_SEPARATOR}
export G__TABLE_WIDTH=$((G__DIVIDER_WIDTH - G__ROW_PREFIX_LEN - G__ROW_SUFFIX_LEN))

# ----- Error Codes -----
export G__ERR_OK=0

# Arguments error codes
export G__ERR_MISSING_ARG=10
export G__ERR_INVALID_ARG=11

# ----- Logging level -----
export G__LOG_LEVEL_DEBUG=0
export G__LOG_LEVEL_INFO=1
export G__LOG_LEVEL_WARN=2
export G__LOG_LEVEL_ERROR=3
# =============================================================================
# Global Variables
# =============================================================================

# =============================================================================
# Private Functions
# =============================================================================

# =============================================================================
# Public Functions
# =============================================================================
