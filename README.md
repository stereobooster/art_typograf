# ArtTypograf

Universal tool for preparing russian text for web publishing. Ruby wrapper for typograf.artlebedev.ru webservice

## Installation

Add this line to your application's Gemfile:

    gem 'art_typograf'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install art_typograf

## Usage

```ruby
require "art_typograf"

ArtTypograf.process('text')
```

You can pass second argument - hash of options.

### Default options

```ruby
{
  :entity_type => :no, # :html, :xml, :no, :mixed
  :use_br => true,
  :use_p => true,
  :max_nobr => 3
}
```

## TODO
 - support ruby 1.8 (`force_encoding` missing)
 - implement missing specs

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
