# ImmutableRecord

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'immutable_record'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install immutable_record

## Usage

Example:
```ruby

Item = ImmutableRecord.new(:foo, :bar)
item = Item.new(foo:1, bar:2)
#=> Item[{:foo=>1, :bar=>2}]

Item.new(foo:1, bar:2).eql?(Item.new(foo:1, bar:2))
#=> true

Item.new(foo:1, bar:2).eql?(Item.new(foo:1, bar:3))
#=> true

{
  Item.new(foo: 1, bar: 2) => "yay!"
}.fetch(Item.new(foo: 1, bar: 2))
#=> "yay!"

item.clone(foo: "changed")
#=> Item[{:foo=>"changed", :bar=>2}]

item.clone {|bar:,**| {bar: bar + 1}}
#=> Item[{:foo=>1, :bar=>3}]
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/immutable_record/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
