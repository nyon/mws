# This module contains a collection of generally useful methods that (currently) have no better place to live. They can
# either be referenced directly as module methods or be mixed in.
module Mws::Utils
  extend self

  # This method will derive a camelized name from the provided underscored name.
  #
  # @param [#to_s] name The underscored name to be camelized.
  # @param [Boolean] uc_first True if and only if the first letter of the resulting camelized name should be
  #  capitalized.
  #
  # @return [String] The camelized name corresponding to the provided underscored name.
  def camelize(name, uc_first=true)
    return nil if name.nil?
    name = name.to_s.strip
    return name if name.empty?
    parts = name.split '_'
    assemble = lambda { |head, tail| head + tail.capitalize }
    parts[0] = uc_first ? parts[0].capitalize : parts[0].downcase
    parts.inject(&assemble)
  end

  def underscore(name)
    return nil if name.nil?
    name = name.to_s.strip
    return name if name.empty?
    name.gsub(/::/, '/')
      .gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
      .gsub(/([a-z\d])([A-Z])/,'\1_\2')
      .tr("-", "_")
      .downcase
  end

  def uri_escape(value)
    value.gsub /([^a-zA-Z0-9_.~-]+)/ do
      '%' + $1.unpack('H2' * $1.bytesize).join('%').upcase
    end
  end

  def alias(to, from, *constants)
    constants.each do | name |
      constant = from.const_get(name)
      to.singleton_class.send(:define_method, name) do | *args, &block |
        constant.new *args, &block
      end
      to.const_set(name, constant)
    end
  end

  def normalize_key key
    camelize(key).sub(/^Asin/, 'ASIN').sub(/^Aws/, 'AWS')
  end

  def normalize_val value
    uri_escape(value.respond_to?(:iso8601) ? value.iso8601 : value.to_s)
  end

  def format_params options
    results = []

    options.each do |pair|
      key = normalize_key pair.first

      if pair.last.respond_to? :each_with_index
        pair.last.each_with_index do |value, index|
          results << if key == "ASINList"
            ["#{key}.ASIN.#{index + 1}", normalize_val(value)]
          else
            ["#{key}.Id.#{index + 1}", normalize_val(value)]
          end
        end
      else
        results << [key, normalize_val(pair.last)]
      end
    end

    Hash[results.sort]
  end
end
