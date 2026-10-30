#!/usr/bin/env bash
#
# Source      : common/project/project-constants.sh
# Dependencies: None
# Description : Project-level constants.
#

# =============================================================================
# Global Constants
# =============================================================================
G__GIT_EXEC="git -C ${G__COMMON_PROJECT_DIR}/../../.."
export G__GIT_EXEC

G__ROOT_PROJECT_DIR="$($G__GIT_EXEC rev-parse --show-toplevel 2>/dev/null)"
g_assert__not_empty G__ROOT_PROJECT_DIR
export G__ROOT_PROJECT_DIR

G__ROOT_PROJECT_NAME="$(basename "$G__ROOT_PROJECT_DIR")"
g_assert__not_empty G__ROOT_PROJECT_NAME
export G__ROOT_PROJECT_NAME

G__ROOT_REMOTE_NAME="$($G__GIT_EXEC ls-remote --get-url origin | xargs basename | cut -d'.' -f1)"
g_assert__not_empty G__ROOT_REMOTE_NAME
export G__ROOT_REMOTE_NAME

G__ROOT_BRANCH_NAME="$($G__GIT_EXEC rev-parse --abbrev-ref HEAD)"
g_assert__not_empty G__ROOT_BRANCH_NAME
export G__ROOT_BRANCH_NAME

G__ROOT_COMMIT_HASH="$($G__GIT_EXEC rev-parse HEAD)"
g_assert__not_empty G__ROOT_COMMIT_HASH
export G__ROOT_COMMIT_HASH

COMMON_PROJECT_DIR="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"

G__CI_PROJECT_DIR="$(realpath "${COMMON_PROJECT_DIR}/../..")"
export G__CI_PROJECT_DIR

G__DEFAULT_CONFIG_FILE="${G__CI_PROJECT_DIR}/conf/pipeline.conf"
export G__DEFAULT_CONFIG_FILE

# =============================================================================
# Global Variables
# =============================================================================

# =============================================================================
# Private Functions
# =============================================================================

# =============================================================================
# Public Functions
# =============================================================================
