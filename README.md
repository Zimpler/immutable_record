# ImmutableRecord

ImmutableRecord provides simple immutable data structures with accessor
methods and keyword argument initialization.

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

# ImmutableRecord.new returns the class object of the new ImmutableRecord.
Item = ImmutableRecord.new(:foo, :bar)
item = Item.new(foo:1, bar:2)
#=> Item[{:foo=>1, :bar=>2}]

Item.new(foo:1, bar:2).eql?(Item.new(foo:1, bar:2))
#=> true
Item.new(foo:1, bar:2).eql?(Item.new(foo:1, bar:3))
#=> false

item.foo
#=> 1

# ImmutableRecords are hashable.
{
  Item.new(foo: 1, bar: 2) => "yay!"
}.fetch(Item.new(foo: 1, bar: 2))
#=> "yay!"

# To create a new record with a changed value use #clone.
# It can take values or closures.
item.clone(foo: "changed")
#=> Item[{:foo=>"changed", :bar=>2}]

item.clone {|bar:,**| {bar: bar + 1}}
#=> Item[{:foo=>1, :bar=>3}]

# The original item didn't change!
item
#=> Item[{:foo=>1, :bar=>2}]

# You can also inherit from the ImmutableRecord.
class AwesomeRecord < ImmutableRecord.new(:foo, :bar)
end
ar = AwesomeRecord.new(foo: 1, bar: 3)
#=> AwesomeRecord[{:foo=>1, :bar=>3}]
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/immutable_record/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
