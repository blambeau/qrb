module Finitio
  #
  # Helper class for tuple and relation types.
  #
  # A heading is a set of attributes, with the constraint that no two
  # attributes have the same name.
  #
  class Heading
    include Enumerable

    DEFAULT_OPTIONS = { allow_extra: false }.freeze

    def initialize(attributes, options = nil)
      @attributes = normalize_attributes(attributes)
      @options    = normalize_options(options)
    end

    def [](attrname)
      @attributes[attrname]
    end

    def fetch(attrname)
      @attributes.fetch(attrname) do
        raise Error, "No such attribute `#{attrname}`"
      end
    end

    def size
      @attributes.size
    end

    def empty?
      size == 0
    end

    def multi?
      allow_extra? || any?{|attr| not(attr.required?) }
    end

    def allow_extra?
      !!options[:allow_extra]
    end

    def allow_extra
      options[:allow_extra]
    end
    alias :extra_type :allow_extra

    def each(&bl)
      return to_enum unless bl
      @attributes.values.each(&bl)
    end

    def to_name
      name = map(&:to_name).join(', ')
      if allow_extra?
        name << ", " unless empty?
        name << "..."
        name << ": #{allow_extra.name}" unless allow_extra == ANY_TYPE
      end
      name
    end

    def ==(other)
      return nil unless other.is_a?(Heading)
      attributes == other.attributes && options == other.options
    end

    def hash
      self.class.hash ^ attributes.hash ^ options.hash
    end

    attr_reader :attributes, :options
    protected   :attributes, :options

  private

    def normalize_attributes(attrs)
      unless attrs.respond_to?(:each)
        raise ArgumentError, "Enumerable[Attribute] expected"
      end

      attributes = {}
      attrs.each do |attr|
        unless attr.is_a?(Attribute)
          raise ArgumentError, "Enumerable[Attribute] expected"
        end
        if attributes[attr.name]
          raise ArgumentError, "Attribute names must be unique"
        end
        attributes[attr.name] = attr
      end
      attributes.freeze
    end

    def normalize_options(opts)
      options = DEFAULT_OPTIONS.dup
      options = options.merge(opts) if opts
      options[:allow_extra] = case extra = options[:allow_extra]
      when TrueClass            then ANY_TYPE
      when NilClass, FalseClass then nil
      when Type                 then extra
      else
        raise ArgumentError, "Unrecognized allow_extra: #{extra}"
      end
      options.freeze
    end

  end # class Heading
end # class Finitio
