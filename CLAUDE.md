# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About

Ambito is a Ruby gem that fetches real-time USD exchange rates from Argentina's Ambito Financiero (mercados.ambito.com). Supports Oficial, Informal (Blue), MEP, CCL, Cripto, and Turista rates.

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

- `lib/ambito.rb` — Public API: `Ambito.rates` (threaded fetch all) and `Ambito.rate(dollar)`
- `lib/ambito/dollar.rb` — Dollar types loaded from `config/dollars.yml`; `Dollar.all` / `Dollar.find(name)`
- `lib/ambito/gateway.rb` — HTTP client (Net::HTTP) hitting `mercados.ambito.com` JSON endpoints
- `lib/ambito/rate.rb` — Aggregates buy/sell Price + Variation; includes trend emoji (📈📉📊)
- `lib/ambito/price.rb` — Parses currency values (comma→dot conversion)
- `lib/ambito/variation.rb` — Percentage change with trend direction
- `lib/ambito/cli.rb` — OptionParser-based CLI
- `config/dollars.yml` — YAML config defining dollar types and their API endpoints

## Testing

- Minitest + WebMock for HTTP stubbing
- `test/test_helper.rb` provides `TestHelper` module with fixtures and stubs
- Fixtures in `test/fixtures/`

## Style

- Linter: Standard (Ruby 3.3.0 target, configured in `.standard.yml`)
- No runtime dependencies beyond Ruby stdlib
