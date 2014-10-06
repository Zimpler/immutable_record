require 'spec_helper'
require 'pp'

describe ImmutableRecord do
  Item = ImmutableRecord.new(:foo, :bar)
  SimilarItem = ImmutableRecord.new(:foo, :bar)

  describe "#new" do
    it "creates a new class with the given attributes" do
      klass = ImmutableRecord.new(:attr1)
      expect(klass::ATTRIBUTES).to eq([:attr1])
      expect(
        klass.instance_methods - Object.instance_methods
      ).to eq([:attr1])
      value = klass.new(attr1: "foo")
      expect(value.attr1).to eq("foo")

      klass = ImmutableRecord.new(:attr1, :attr2)
      expect(klass::ATTRIBUTES).to eq([:attr1, :attr2])
      expect(
        klass.instance_methods - Object.instance_methods
      ).to eq([:attr1, :attr2])
      value = klass.new(attr1: "foo", attr2: "bar")
      expect(value.attr1).to eq("foo")
      expect(value.attr2).to eq("bar")
    end

    it "raises error if non-symbol attributes" do
      expect {
        ImmutableRecord.new("foo")
      }.to raise_error(
        ArgumentError, "attributes should be symbols!"
      )
    end
  end

  describe ImmutableRecord::Value do
    let(:item) { Item.new(foo:1, bar:2) }
    it "has working readers" do
      expect(item.foo).to eq(1)
      expect(item.bar).to eq(2)
    end

    describe "#initialize" do
      it "raises argument error on missing key" do
        expect { Item.new(bar:2) }.to raise_error(
          ArgumentError, "Missing attribute(s): [:foo]"
        )
        expect { Item.new(foo:2) }.to raise_error(
          ArgumentError, "Missing attribute(s): [:bar]"
        )
        expect { Item.new({}) }.to raise_error(
          ArgumentError, "Missing attribute(s): [:foo, :bar]"
        )
      end
      it "raises argument error on extra keys" do
        expect { Item.new(foo:1, bar:2, baz:3) }.to raise_error(
          ArgumentError, "Unknown attribute(s): [:baz]"
        )
        expect {
          Item.new(foo:1, bar:2,"foo"=>1)
        }.to raise_error(
          ArgumentError, 'Unknown attribute(s): ["foo"]'
        )
      end
    end

    describe ".[]" do
      it "works as a shorthand for new" do
        expect(Item[foo:1, bar:2]).to eq(item)
      end
    end

    describe "#clone" do
      it "can work as normal clone" do
        expect(item.clone).to_not be(item)
        expect(item.clone).to eq(item)
      end
      it "can replace attributes given as params" do
        expect(item.clone(foo: "changed")).to eq(
          Item.new(foo: "changed", bar: 2)
        )
        expect(item.clone(bar: "changed")).to eq(
          Item.new(foo: 1, bar: "changed")
        )
        expect(item.clone(foo: "changed", bar: "changed")).to eq(
          Item.new(foo: "changed", bar: "changed")
        )
      end
      it "can replace attributes with a proc" do
        expect(
          item.clone { |foo:,**| {foo: foo + 1} }
        ).to eq(Item.new(foo: 2, bar: 2))
        expect(
          item.clone { |bar:,**| {bar: bar + 1} }
        ).to eq(Item.new(foo: 1, bar: 3))
        expect(
          item.clone { |foo:, bar:| {foo: foo + bar} }
        ).to eq(Item.new(foo: 3, bar: 2))
      end
      it "can take both a hash and a proc" do
        expect(
          item.clone(foo: 10) { |bar:,**| {bar: bar * 2} }
        ).to eq(Item.new(foo: 10, bar: 4))
      end
    end

    describe "#==" do
      it "works as expected" do
        expect(item).to be == Item.new(foo:1, bar:2)
        expect(item).to_not be == SimilarItem.new(foo:1, bar:2)
      end
    end

    describe "#hash" do
      it "can be used as a hash key" do
        hash = {
          Item.new(foo: 1, bar: 2) => "success",
          Item.new(foo: 2, bar: 2) => "failure"
        }
        expect(hash.fetch(item)).to eq("success")
      end
    end

    describe "#inspect" do
      it "can be nicely inspected" do
        expect(item.to_s).to eq("Item[{:foo=>1, :bar=>2}]")
        expect(item.inspect).to eq(item.to_s)
      end

      it "works with anonymous classes" do
        klass = ImmutableRecord.new(:foo, :bar)
        value = klass.new(foo:1, bar: 2)
        expect(value.to_s).to match(
          /#<Class:.*>\[\{:foo=>1, :bar=>2\}\]/
        )
      end
    end

    describe "#pretty_print" do
      let(:printer) { PP.new }
      it "works for normal classes" do
        item.pretty_print(printer)
        printer.flush
        expect(printer.output).to eq("Item[{:foo=>1, :bar=>2}]")
      end
      it "line breaks as expected" do
        item = Item.new(
          foo: "x"*60,
          bar: "y"*65
        )
        item.pretty_print(printer)
        printer.flush
        expect(printer.output).to eq(<<-PP.chomp)
Item[{:foo=>"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
      :bar=>
       "yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy"}]
        PP
      end
      it "works for anonymous classes" do
        klass = ImmutableRecord.new(:foo, :bar)
        value = klass.new(foo:1, bar: 2)
        value.pretty_print(printer)
        printer.flush
        expect(printer.output).to match(
          /#<Class:.*>\[\{:foo=>1, :bar=>2\}\]/
        )
      end
    end
  end
end
