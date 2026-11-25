# Changelog

## [Unreleased]

### Added

- `bna` dollar, the Banco Nación rate
- `Rate#value`, the value Ámbito publishes for the rate, or `nil`
- `Rate#updated_at`, the time Ámbito last updated the rate, or `nil`
- `Ambito::Table`, which the CLI prints: one row per rate with `Compra`, `Venta`, `Cambio` and `Actualización` (time since the last update) columns, and the published value across `Compra` and `Venta` for a rate that has one; coloured when the output is a terminal

### Changed

- `Variation#to_s` puts a `+` before a positive change, as `+0.23%`
- `Rate#to_s` prints the name and variation on one line and the prices below it: the published value, or `Compra` and `Venta` on their own lines when there is none, instead of their average

## [0.4.0] - 2026-11-20

### Added

- `Rate` exposes `dollar`, `buy`, `sell`, `price` and `variation`
- `Ambito::Error`, raised for an unknown dollar, an HTTP error or a response that cannot be read
- The CLI prints the error message and exits with status 1
- `Price#/`

### Changed

- `Gateway.new` takes a `Dollar`, and `Gateway#rate` returns a `Rate`; `Gateway#get` is removed
- `Price.new` and `Variation.new` take numbers instead of strings
- `Price#+` returns a `Price` instead of a `Float`
- `Ambito.rates` raises `Ambito::Error` if any rate fails

### Removed

- `Dollar#rate`; use `Ambito.rate` or `Gateway#rate`
- `Price.[]` and `Variation.[]`; use `.new`

### Fixed

- A response with a missing field no longer prints `$ 0.00`

## [0.3.0] - 2023-11-27

### Added

- Multi-threaded requests

## [0.2.1] - 2023-11-27

### Fixed

- Correct path when loading configuration

## [0.2.0] - 2023-11-24

### Added

- Option to fetch a single rate

## [0.1.0] - 2023-11-22

- Initial release
