# bean-server

This repository builds a Fava image with Beancount-related extensions and an in-container daily price updater.

## Ledger layout

The container expects the ledger to be mounted at `/ledger` and starts Fava with:

```sh
fava /ledger/main.bean
```

The container also runs `update-prices` in the background by default. Mount `/ledger` read-write if you want generated prices to be appended to `prices.bean`.

Generated prices are kept in a dedicated `prices.bean` file. Include it from `main.bean`:

```beancount
include "commodity.bean"
include "prices.bean"
```

## Commodity price sources

Define `bean-price` sources on commodity directives with `price:` metadata in `commodity.bean`.

```beancount
2024-01-01 commodity AAPL
  price: "USD:yahoo/AAPL"

2024-01-01 commodity CN_600519
  name: "Kweichow Moutai"
  price: "CNY:yahoo/600519.SS"

2024-01-01 commodity CN_000001
  name: "Ping An Bank"
  price: "CNY:yahoo/000001.SZ"
```

For A shares, keep the Beancount commodity name stable, such as `CN_600519`, and put the exchange-specific Yahoo symbol in `price:`, such as `600519.SS` or `000001.SZ`.

## Update prices

Run the updater with the repository mounted as `/ledger`:

```sh
docker run --rm -v "$PWD/test:/ledger" bean-server:latest update-prices
```

The container runs `update-prices` once at startup and then once every 24 hours by default. Failed individual fetches are logged by `bean-price` and successful prices are still appended.

The schedule can be configured with environment variables:

```sh
AUTO_UPDATE_PRICES=true
PRICE_UPDATE_ON_START=true
PRICE_UPDATE_INTERVAL_SECONDS=86400
```

Set `AUTO_UPDATE_PRICES=false` to run Fava without the background updater.

To backfill from the latest existing price up to today, run with `BACKFILL=true`:

```sh
docker run --rm -v "$PWD/test:/ledger" -e BACKFILL=true bean-server:latest update-prices
```
