#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

bash "$PROJECT_ROOT/scripts/translate-solx.sh" \
    "$PROJECT_ROOT/contracts/Shieldcoin.solx" \
    "$PROJECT_ROOT/contracts/Shieldcoin.sol"
