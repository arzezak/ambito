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
rate.price.quote      # => 365.38
rate.variation.value  # => 0.23
rate.variation.to_s   # => "+0.23%"
rate.updated_at       # => 2026-11-25 13:48:00 -0300
```

`price` is the value Ámbito publishes for the rate, or the average of buy and sell when it publishes none. `value` is that published value, or `nil`. To print rates, pass them to `Ambito::Table.new(rates)`, which is what the CLI does.

Both methods raise `Ambito::Error` for an unknown dollar, an HTTP error or a response that cannot be read. `Ambito.rates` raises if any one rate fails.

### CLI

```
ambito              # all rates
ambito -d oficial   # single rate
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
