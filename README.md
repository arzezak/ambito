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

rate.to_s             # => "Oficial: $ 365.38 📈 0.23%"
rate.buy.quote        # => 355.38
rate.sell.quote       # => 375.38
rate.price.quote      # => 365.38
rate.variation.value  # => 0.23
```

`price` is the value Ámbito publishes for the rate, or the average of buy and sell when it publishes none.

Both methods raise `Ambito::Error` for an unknown dollar, an HTTP error or a response that cannot be read. `Ambito.rates` raises if any one rate fails.

### CLI

```
ambito              # all rates
ambito -d oficial   # single rate
```

## Supported Dollar Types

| Name | Key |
|------|-----|
| Oficial | `oficial` |
| Informal (Blue) | `informal` |
| MEP | `mep` |
| CCL | `ccl` |
| Cripto | `cripto` |
| Turista | `turista` |

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Ambito project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/arzezak/ambito/blob/main/CODE_OF_CONDUCT.md).
