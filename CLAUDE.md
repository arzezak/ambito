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
exe/ambito     # CLI: -d <dollar_type> for a 30-day chart of one rate (--from and --to set the dates), no args for the table of all
```

Run a single test by name:
```bash
ruby -Ilib:test test/test_ambito.rb -n test_method_name
```

## Architecture

- `lib/ambito.rb` — Public API: `Ambito.rates` (threaded fetch all), `Ambito.rate(dollar)` and `Ambito.history(dollar, from:, to:)`; all raise `Ambito::Error`
- `lib/ambito/dollar.rb` — Dollar types loaded from `config/dollars.yml`; `Dollar.all` / `Dollar.find(name)`
- `lib/ambito/gateway.rb` — The only module that knows the wire format: fetches a Dollar's endpoint on `mercados.ambito.com` (Net::HTTP), parses field names, comma decimals and the `fecha` timestamp (Argentina time), returns a Rate; `history` fetches `<endpoint dir>/grafico/<from>/<to>` (rows of `["dd/mm/yyyy", number]` after a title row), keeps the last quote of a repeated day and returns a History
- `lib/ambito/rate.rb` — Value object: `dollar`, `buy`, `sell`, `value` (published, or nil), `variation`, `updated_at`; plain data, no formatting (Table does that)
- `lib/ambito/history.rb` — Value object: `dollar` and `points` (one `date` and `price` per day, oldest first), plus `opening`, `closing`, `high`, `low`, `change` and `variation`
- `lib/ambito/price.rb` — Numeric quote with currency formatting
- `lib/ambito/variation.rb` — Percentage change, printed with its sign
- `lib/ambito/age.rb` — Seconds since a rate's `updated_at`, printed as `12 min`, `2 h` or `1 d`
- `lib/ambito/table.rb` — Draws the bordered table the CLI prints: `Compra`, `Venta`, `Cambio`, `Actualización`; a Rate with a published value merges the `Compra` and `Venta` cells. Layout and colours: left-aligned, dim borders, yellow titles, cyan names and prices, green or red variation; colour only when `color:` is true
- `lib/ambito/chart.rb` — Draws a History as a braille line chart: a heading, the highest and lowest price above and below the plot, and `Inicio`, `Fin`, `Máximo`, `Mínimo` and `Cambio` lines. Each braille cell is 2 dots wide and 4 high; days with no quote are joined with a straight line
- `lib/ambito/paint.rb` — The ANSI styles and the `paint` method that Table and Chart share
- `lib/ambito/cli.rb` — OptionParser-based CLI; prints a Table of all rates, or with `-d` a Chart of the last 30 days, or of the days between `--from` and `--to`; coloured when stdout is a terminal
- `config/dollars.yml` — YAML config defining dollar types and their API endpoints

## Testing

- Minitest + WebMock for HTTP stubbing
- `test/test_helper.rb` provides `TestHelper` module with fixtures and stubs
- Fixtures in `test/fixtures/`

## Style

- Linter: Standard (Ruby 3.3.0 target, configured in `.standard.yml`)
- No runtime dependencies beyond Ruby stdlib
