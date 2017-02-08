module Isa
  module Attributes

    class << self
      ATTRIB_HASH = {}
      private_constant :ATTRIB_HASH

      def attrib_hash
        ATTRIB_HASH
      end

      def included(base)
        unless base.instance_variable_defined?(:@_attributes)
          base.instance_variable_set(:@_attributes, {})
        end
      end

      def attribute(property, type, options = {})
        attrib_hash.merge!({property => {options: options, type: type}})
      end

      def from(hash)
        validate!(hash)

        new hash
      end

      private :new

      def validate!(provided)
        invalid_properties = []
        provided&.map do |key, value|
          unless attrib_hash.has_key?(key)
            invalid_properties << {property: :key, value: key}
            next
          end

          unless attrib_hash[:type].is_a?(value.class)
            invalid_properties << {property: :value, value: value}
            next
          end
        end

        unless invalid_properties.empty?
          errors = ''
          invalid_properties.each do |error|
            errors << "invalid #{error[:property]} #{error[:value]}\n"
          end

          raise RuntimeError.new(errors)
        end
      end
    end

    def initialize(attributes)
      @_attributes = attributes
    end

    def attributes
      @_attributes
    end

    def method_missing(method_symbol)
      if @_attributes[method_symbol]
        @_attributes[method_symbol]
      else
        super
      end
    end
  end
end
