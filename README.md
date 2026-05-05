# OrdinalizeFull

Turns an integer into an ordinal string in several locales and styles:

- `1.ordinalize` → `"1st"` (short form)
- `1.ordinalize_in_full` → `"first"` (fully written)
- `1.ordinalize_in_precedence` → `"primary"` (precedence terminology)

## Installation

```ruby
gem "ordinalize_full"
```

```ruby
require "ordinalize_full/integer"
```

`require "ordinalize_full/integer"` prepends the module into `Integer`, exposing the methods on every integer. If you would rather mix it into a specific class only, `require "ordinalize_full"` and `prepend OrdinalizeFull` yourself.

## Locale support

| Locale | Short (`ordinalize`) | Full (`ordinalize_in_full`) | Precedence |
| ------ | -------------------- | --------------------------- | ---------- |
| `:en`  | ✅ all integers       | ✅ 1–100                     | ✅ 1–12     |
| `:fr`  | ✅ all integers       | ✅ 1–100 (with `gender:`)    | —          |
| `:it`  | ✅ all integers       | ✅ 1–100                     | —          |
| `:nl`  | ✅ all integers       | ✅ 1–100                     | —          |
| `:de`  | ✅ all integers       | ✅ 1–100 (with `gender:`)    | —          |
| `:es`  | ✅ all integers       | ✅ 1–99 via composition      | —          |

Set the active locale through `I18n.locale = :fr` before calling. Numbers outside the supported range raise `NotImplementedError`; unknown locales also raise `NotImplementedError`.

## Spanish gender and plurality

Spanish ordinals inflect for grammatical gender and number:

```ruby
I18n.locale = :es
1.ordinalize_in_full                                              # => "primer"
1.ordinalize_in_full(gender: :feminine)                           # => "primera"
1.ordinalize_in_full(gender: :feminine, plurality: :plural)       # => "primeras"
22.ordinalize_in_full(gender: :feminine)                          # => "vigésima segunda"
55.ordinalize_in_full                                             # => "quincuagésimo quinto"

1.ordinalize                                                      # => "1.ᵉʳ"
1.ordinalize(gender: :feminine, plurality: :plural)               # => "1.ᵃˢ"
```

`gender:` accepts `:masculine` (default) or `:feminine`; `plurality:` accepts `:singular` (default) or `:plural`. The same options are accepted in `:fr` and `:de` where the underlying translations vary by gender.

## API

```ruby
n.ordinalize(in_full: false, gender: :masculine, plurality: :singular)
n.ordinalize_in_full(gender: :masculine, plurality: :singular)
n.ordinalize_in_precedence(gender: :masculine, plurality: :singular)
```

Aliases are provided for ergonomics: `ordinalize_full` and `ordinalize_precedence`.

`gender:` and `plurality:` are validated; passing anything other than `:masculine`/`:feminine` or `:singular`/`:plural` raises `ArgumentError`.

## Development

```sh
bundle install
bundle exec rake          # runs rspec and rubocop
```

## License

MIT — see `LICENSE.txt`.
