# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About

Ambito is a Ruby gem that fetches real-time USD exchange rates from Argentina's Ambito Financiero (mercados.ambito.com). Supports Oficial, BNA, Informal (Blue), MEP, CCL, Cripto, and Turista rates.

## Commands

```bash
rake           # default: runs tests + linter
rake test      # minitest suite
rake standard  # Standard (RuboCop-based) linter
bin/console    # IRB with gem loaded
exe/ambito     # CLI: -d <dollar_type> for single rate, no args for all
```

Run a single test by name:
```bash
ruby -Ilib:test test/test_ambito.rb -n test_method_name
```

## Architecture

- `lib/ambito.rb` — Public API: `Ambito.rates` (threaded fetch all) and `Ambito.rate(dollar)`; both raise `Ambito::Error`
- `lib/ambito/dollar.rb` — Dollar types loaded from `config/dollars.yml`; `Dollar.all` / `Dollar.find(name)`
- `lib/ambito/gateway.rb` — The only module that knows the wire format: fetches a Dollar's endpoint on `mercados.ambito.com` (Net::HTTP), parses field names, comma decimals and the `fecha` timestamp (Argentina time), returns a Rate
- `lib/ambito/rate.rb` — Value object: `dollar`, `buy`, `sell`, `value` (published, or nil), `price`, `variation`, `updated_at`; `to_s` prints name, trend emoji (📈📉📊) and variation, then the published value or `Compra` and `Venta` lines below
- `lib/ambito/price.rb` — Numeric quote with `+`, `/` and currency formatting
- `lib/ambito/variation.rb` — Percentage change with trend direction
- `lib/ambito/age.rb` — Seconds since a rate's `updated_at`, printed as `12 min`, `2 h` or `1 d`
- `lib/ambito/table.rb` — Draws the bordered table the CLI prints: `Compra`, `Venta`, `Cambio`, `Actualización`; a Rate with a published value merges the `Compra` and `Venta` cells. Layout and colours follow rate.sx: left-aligned, dim borders, yellow titles, cyan names and prices, green or red variation; colour only when `color:` is true
- `lib/ambito/cli.rb` — OptionParser-based CLI; prints a Table, coloured when stdout is a terminal
- `config/dollars.yml` — YAML config defining dollar types and their API endpoints

## Testing

- Minitest + WebMock for HTTP stubbing
- `test/test_helper.rb` provides `TestHelper` module with fixtures and stubs
- Fixtures in `test/fixtures/`

## Style

- Linter: Standard (Ruby 3.3.0 target, configured in `.standard.yml`)
- No runtime dependencies beyond Ruby stdlib
