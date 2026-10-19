#!/usr/bin/env bash
#
# Collection of tool locations that are required by scripts.
#

# =====================================
# Global constants & variables
# =====================================
CSPELL_EXEC="$(which cspell)"
export CSPELL_EXEC

CSPELL_VERSION_NO="$($CSPELL_EXEC --version)"
CSPELL_VERSION="$CSPELL_EXEC ($CSPELL_VERSION_NO)"
export CSPELL_VERSION

CLANG_FORMAT_EXEC=$(which clang-format)
export CLANG_FORMAT_EXEC

CLANG_FORMAT_VERSION="$($CLANG_FORMAT_EXEC --version | awk '{print $4}')"
export CLANG_FORMAT_VERSION

# =====================================
# Private functions
# =====================================

# =====================================
# Public functions
# =====================================
