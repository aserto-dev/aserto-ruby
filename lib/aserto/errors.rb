# frozen_string_literal: true

module Aserto
  class Error < StandardError; end
  class InvalidResourceMapping < Error; end
  class InvalidIdentityType < Error; end

  class AccessDenied < Error
    attr_reader :action, :conditions
    attr_writer :default_message

    def initialize(message = nil, action = nil, conditions = nil)
      @message = message
      @action = action
      @conditions = conditions
      @default_message = I18n.t(:"unauthorized.default", default: "You are not authorized to access this page.")
      super()
    end

    def to_s
      @message || @default_message
    end

    def inspect
      details = %i[action conditions message].filter_map do |attribute|
        value = instance_variable_get "@#{attribute}"
        "#{attribute}: #{value.inspect}" if value.present?
      end.join(", ")
      "#<#{self.class.name} #{details}>"
    end
  end
end
