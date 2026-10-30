#!/usr/bin/env bash
#
# Source      : common/global/global-entry.sh
# Dependencies: common/global/global-constants.sh
#               common/global/global-logging.sh
#               common/global/global-assert.sh
#               common/global/global-utils.sh
#               common/global/global-tests.sh
# Description : Entry point to access shared global scripts.
#

# =============================================================================
# Global Constants
# =============================================================================
G__COMMON_GLOBAL_DIR="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"
export G__COMMON_GLOBAL_DIR

# =============================================================================
# Global Variables
# =============================================================================

# =============================================================================
# Private Functions
# =============================================================================

# =============================================================================
# Entry Point
# =============================================================================
# shellcheck disable=SC1091
source "${G__COMMON_GLOBAL_DIR}/global-constants.sh"

# shellcheck disable=SC1091
source "${G__COMMON_GLOBAL_DIR}/global-logging.sh"

# shellcheck disable=SC1091
source "${G__COMMON_GLOBAL_DIR}/global-assert.sh"

# shellcheck disable=SC1091
source "${G__COMMON_GLOBAL_DIR}/global-utils.sh"

if [[ -n "${FOR_TESTS:-}" ]]; then
    # shellcheck disable=SC1091
    source "${G__COMMON_GLOBAL_DIR}/global-tests.sh"
fi
