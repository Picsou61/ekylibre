module Aggeratio
  class Parameter
    TYPES = [:record_list, :record, :string, :decimal, :integer, :date, :datetime]
    attr_reader :name, :type, :options, :default, :foreign_class

    def initialize(name, type, options = {})
      @name = name.to_s
      @type = type
      @options = options
      fail ArgumentError.new("Type is unknown: #{@type.inspect}") unless TYPES.include?(@type)
      @default = @options[:default]
      fail ArgumentError.new("Default value must be given for #{@name}") unless @default
      @foreign_class = @options[:of].to_s.camelcase.constantize if @options[:of]
    end

    # Import parameter form an XML node
    def self.import(element)
      options = element.attributes.inject({}) do |hash, pair|
        hash[pair[0].to_sym] = pair[1].to_s
        hash
      end
      name = options.delete(:name).to_s
      type = options.delete(:type).to_s.tr('-', '_').to_sym
      new(name, type, options)
    end

    def human_name
      ::I18n.t("aggregator_parameters.#{name}", default: [:"labels.#{name}", :"attributes.#{name}", name.to_s.humanize])
    end

    for type in TYPES
      class_eval "def #{type}?\n" \
                 "  !!(self.type == :#{type})\n" \
                 'end'
    end
  end
end
