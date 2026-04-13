#!/bin/sh
set -e

LEDGER_DIR="${LEDGER_DIR:-/ledger}"
LEDGER_FILE="${LEDGER_FILE:-${LEDGER_DIR}/main.bean}"
AUTO_UPDATE_PRICES="${AUTO_UPDATE_PRICES:-true}"
PRICE_UPDATE_INTERVAL_SECONDS="${PRICE_UPDATE_INTERVAL_SECONDS:-86400}"
PRICE_UPDATE_ON_START="${PRICE_UPDATE_ON_START:-true}"

run_price_update() {
    echo "Running price update..."
    if update-prices; then
        echo "Price update finished."
    else
        echo "Price update failed; Fava will keep running." >&2
    fi
}

run_price_update_loop() {
    if [ "$PRICE_UPDATE_ON_START" = "true" ]; then
        run_price_update
    fi

    while :; do
        sleep "$PRICE_UPDATE_INTERVAL_SECONDS"
        run_price_update
    done
}

if [ "$AUTO_UPDATE_PRICES" = "true" ]; then
    run_price_update_loop &
fi

exec fava "$LEDGER_FILE" "$@"
