require "immutable_record/version"

module ImmutableRecord
  def self.new (*attributes)
    unless attributes.all? { |attr| attr.is_a?(Symbol) }
      raise ArgumentError, "attributes should be symbols!"
    end

    Class.new(Value) do
      attr_reader(*attributes)
      const_set("ATTRIBUTES", attributes.dup.freeze)
    end
  end

  class Value < Object
    def initialize (opts)
      missing_keys = self.class::ATTRIBUTES - opts.keys
      if missing_keys.any?
        raise ArgumentError, "Missing attribute(s): #{missing_keys.inspect}"
      end

      extra_keys = opts.keys - self.class::ATTRIBUTES
      if extra_keys.any?
        raise ArgumentError, "Unknown attribute(s): #{extra_keys.inspect}"
      end

      self.class::ATTRIBUTES.each do |attr|
        instance_variable_set("@#{attr}", opts.fetch(attr))
      end
      freeze
    end

    def self.name
      super || to_s
    end

    def self.[] (opts)
      new(opts)
    end

    def clone (opts={}, &block)
      opts = __attributes__.merge(opts)
      opts = opts.merge(block.call(opts)) if block_given?
      self.class.new(opts)
    end

    def to_s
      "#{self.class.name}[#{__attributes__.inspect}]"
    end

    def inspect
      to_s
    end

    def == (other)
      other.is_a?(self.class) && __values__ == other.send(:__values__)
    end

    def eql? (other)
      hash == other.hash
    end

    def hash
      self.class.hash ^ __attributes__.hash
    end

    def pretty_print (q)
      name = self.class.name
      size = name.length + 1
      q.group(size, "#{name}[", "]") { q.pp __attributes__ }
    end

    private

    def __values__
      self.class::ATTRIBUTES.map(&method(:public_send))
    end

    def __attributes__
      Hash[self.class::ATTRIBUTES.zip(__values__)]
    end
  end
end
