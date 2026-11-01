#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ -z "${SOLX_BIN:-}" ]]; then
    case "$(uname -s):$(uname -m)" in
        Darwin:arm64)
            SOLX_BIN="$PROJECT_ROOT/node_modules/.bin/solx-darwin-arm64"
            ;;
        Linux:x86_64)
            SOLX_BIN="$PROJECT_ROOT/node_modules/.bin/solx-linux-x64"
            ;;
        *)
            echo "Unsupported Solx platform: $(uname -s) $(uname -m)" >&2
            exit 1
            ;;
    esac
fi

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <input.solx> <output.sol>" >&2
    exit 2
fi

if [[ ! -x "$SOLX_BIN" ]]; then
    echo "Solx translator is not executable: $SOLX_BIN" >&2
    echo "Install dependencies or set SOLX_BIN." >&2
    exit 1
fi

"$SOLX_BIN" translate "$1" --output "$2"
