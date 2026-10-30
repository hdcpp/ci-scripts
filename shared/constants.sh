#!/usr/bin/env bash
#
# Shared constants that are widely used in scripts.
#

# =====================================
# Global constants & variables
# =====================================

# Colors for terminal output
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[0;33m'
export BLUE='\033[0;34m'
export CYAN='\033[0;36m'
export BOLD='\033[1m'
export NC='\033[0m' # No Color

export DEFAULT_CONFIG_FILE="${SCRIPTS_DIR}/pipeline.conf"

# Heading separators
export SEPARATOR_WIDTH=80
SEPARATOR_H0="$(printf "%0.s@" $(seq 1 $SEPARATOR_WIDTH))"
export SEPARATOR_H0
SEPARATOR_H1="$(printf "%0.s#" $(seq 1 $SEPARATOR_WIDTH))"
export SEPARATOR_H1
SEPARATOR_H2="$(printf "%0.s=" $(seq 1 $SEPARATOR_WIDTH))"
export SEPARATOR_H2
SEPARATOR_H3="$(printf "%0.s-" $(seq 1 $SEPARATOR_WIDTH))"
export SEPARATOR_H3
SEPARATOR_H4="$(printf "%0.s." $(seq 1 $SEPARATOR_WIDTH))"
export SEPARATOR_H4

# Table manifest
export ROW_PREFIX="| "
export ROW_SUFFIX=" |"
export COL_SEPARATOR=" : "
export TABLE_WIDTH=$((SEPARATOR_WIDTH - ${#ROW_PREFIX} - ${#ROW_SUFFIX}))

# =====================================
# Private functions
# =====================================

# =====================================
# Public functions
# =====================================
