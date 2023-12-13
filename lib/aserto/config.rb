# frozen_string_literal: true

require "logger"

module Aserto
  class Config
    class << self
      def default_logger
        logger = Logger.new($stdout)
        logger.progname = "aserto"
        logger
      end

      def validate!
        error_message = ""
        REQUIRED_OPTIONS.each do |option|
          if !instance_variable_defined?(:"@#{option}") ||
             instance_variable_get(:"@#{option}") == ""
            error_message += "Missing required option: #{option}\n"
          end
        end
        raise error_message if error_message != ""
      end
    end

    DEFAULT_ATTRS = {
      authorizer_api_key: "",
      tenant_id: "",
      client: nil,
      service_url: "localhost:8282",
      decision: "allowed",
      disabled_for: [{}],
      enabled: true,
      identity_mapping: {
        type: :none
      },
      logger: Config.default_logger,
      policy_name: "",
      instance_label: "",
      policy_root: "",
      cert_path: "",
      on_unauthorized: lambda do |_env|
        [403, {}, ["Forbidden"]]
      end
    }.freeze

    OPTIONS = DEFAULT_ATTRS.keys.freeze

    REQUIRED_OPTIONS = OPTIONS - %i[
      service_url decision disabled_for identity_mapping enabled logger
    ].freeze

    private_constant :DEFAULT_ATTRS, :OPTIONS, :REQUIRED_OPTIONS

    attr_accessor(*OPTIONS)

    def initialize(options)
      OPTIONS.each do |key|
        send("#{key}=", options[key] || DEFAULT_ATTRS[key])
      end
    end
  end
end
