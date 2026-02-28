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
Ambito.rate("informal")
Ambito.rate("oficial")
```

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
