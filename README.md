# Ambito

Real-time USD exchange rates from Argentina's [Ambito Financiero](https://mercados.ambito.com).

## Installation

```
gem install ambito
```

Or add to your Gemfile:

```ruby
gem "ambito"
```

## Usage

### Ruby

```ruby
# Fetch all rates (threaded)
Ambito.rates

# Fetch a single rate
rate = Ambito.rate("oficial")

rate.buy.quote        # => 355.38
rate.buy.to_s         # => "$ 355.38"
rate.sell.quote       # => 375.38
rate.value            # => nil
rate.variation.value  # => 0.23
rate.variation.to_s   # => "+0.23%"
rate.updated_at       # => 2026-11-25 13:48:00 -0300

# Fetch the daily quotes between two dates
history = Ambito.history("bna", from: Date.new(2026, 10, 27), to: Date.new(2026, 11, 26))

history.opening.date         # => #<Date: 2026-10-27>
history.closing.price.quote  # => 1625.0
history.high.price.to_s      # => "$ 1630.00"
history.change               # => 65.0
history.variation.to_s       # => "+4.17%"
```

`value` is the single value Ámbito publishes for a rate with no buy and sell, such as MEP or Turista, as a price like `buy` and `sell`; it is `nil` for the rest. To print rates, pass them to `Ambito::Table.new(rates)`, which is what the CLI does.

Both methods raise `Ambito::Error` for an unknown dollar, an HTTP error or a response that cannot be read. `Ambito.rates` raises if any one rate fails.

A `History` holds one quote per day, the one Ámbito charts: the sell price for a rate with buy and sell. `points` has every day, each with a `date` and a `price`. To print it, pass it to `Ambito::Chart.new(history)`.

### CLI

```
ambito              # all rates
ambito -d bna       # chart of the last 30 days of one rate
```

The CLI prints a table, in colour when the output is a terminal. A rate with no buy and sell shows the value Ámbito publishes across both columns. `Actualización` is the time since Ámbito last updated the rate.

```
┌─────────┬───────────┬───────────┬────────┬───────────────┐
│         │ Compra    │ Venta     │ Cambio │ Actualización │
├─────────┼───────────┼───────────┼────────┼───────────────┤
│ BNA     │ $ 1580.00 │ $ 1630.00 │ +0.93% │ hace 2 min    │
├─────────┼───────────┴───────────┼────────┼───────────────┤
│ CCL     │       $ 1728.79       │ -3.70% │ hace 2 h      │
├─────────┼───────────────────────┼────────┼───────────────┤
│ Turista │       $ 2119.00       │ +0.93% │ hace 1 d      │
└─────────┴───────────────────────┴────────┴───────────────┘
```

With `-d`, the CLI prints a chart of the last 30 days.

```
BNA  27/10/2026 – 26/11/2026  +4.17%

  │ $ 1630.00
  │                                                                     ⢠⠓⠤⡀
  │                                                                    ⢀⠇  ⠈
  │                                                                    ⡜
  │                                                                  ⡠⠜
  │                                                               ⢀⠔⠊
  │                                                            ⢀⡠⠊⠁
  │                                                          ⡠⠔⠁
  │                                                         ⢰⠁
  │                                                         ⡇
  │                                                        ⡸
  │                                                      ⢀⠔⠁
  │                                                    ⣀⠔⠁
  │                                             ⣀⡠⠤⠒⠒⠒⠊
  │                 ⡠⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠔⠒⠉
  │             ⢀⣀⠤⠊
  │ ⣀⣀⣀⣀⣀⣀⣀⣀⠤⠔⠒⠉⠁
  │ $ 1560.00
  └─────────────────────────────────────────────────────────────────────────

Inicio: $ 1560.00 (27/10)  //  Fin: $ 1625.00 (26/11)
Máximo: $ 1630.00 (25/11)  //  Mínimo: $ 1560.00 (27/10)
Cambio: +65.00 (+4.17%)
```

## Supported Dollar Types

| Name | Key |
|------|-----|
| Oficial | `oficial` |
| BNA (Banco Nación) | `bna` |
| Informal (Blue) | `informal` |
| MEP | `mep` |
| CCL | `ccl` |
| Cripto | `cripto` |
| Turista | `turista` |

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Ambito project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/arzezak/ambito/blob/main/CODE_OF_CONDUCT.md).
