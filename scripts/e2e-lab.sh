#!/usr/bin/env bash
# RHCL program E2E lab wrapper — delegates to GateForge orchestrator.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GATEFORGE_ROOT="${GATEFORGE_ROOT:-$(cd "${SCRIPT_DIR}/../../gateforge" 2>/dev/null && pwd || true)}"
TARGET="${GATEFORGE_ROOT}/scripts/e2e-seed-export-analyze.sh"

if [[ ! -x "${TARGET}" ]]; then
	echo "GateForge E2E script not found at ${TARGET}" >&2
	echo "Set GATEFORGE_ROOT to your gateforge checkout." >&2
	exit 1
fi

exec "${TARGET}" "$@"
