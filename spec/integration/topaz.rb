# frozen_string_literal: true

require "timeout"

class Topaz
  class << self
    # 2 minutes
    WAIT_FOR_TOPAZ = 2 * 60
    CERT_FILE = File.join(ENV.fetch("HOME", ""), ".config/topaz/certs/grpc-ca.crt")
    DB_DIR = File.join(ENV.fetch("HOME", ""), ".config/topaz/db")
    CONFIG_DIR = File.join(ENV.fetch("HOME", ""), ".config/topaz/cfg")

    def run
      stop

      if File.exist?(File.join(DB_DIR, "directory.db"))
        File.rename(File.join(DB_DIR, "directory.db"), File.join(DB_DIR, "directory.bak"))
      end

      if File.exist?(File.join(CONFIG_DIR, "config.yaml"))
        File.rename(File.join(CONFIG_DIR, "config.yaml"), File.join(CONFIG_DIR, "config.bak"))
      end

      configure
      start
    end

    def start
      system "topaz start --container-version=model-v2.3"

      Timeout.timeout(WAIT_FOR_TOPAZ) do
        wait_for_certs

        client = Aserto::Directory::V3::Client.new(
          {
            url: "localhost:9292",
            cert_path: CERT_FILE
          }
        )

        client.get_objects(object_type: "user")
      rescue GRPC::Unavailable => e
        puts e.message
        puts "sleep 2"
        sleep 2
        puts "retry..."

        retry
      end

      puts "server is running"
    end

    def stop
      system "topaz stop"
    end

    def configure
      system "topaz configure -r ghcr.io/aserto-policies/policy-todo:2.1.0 -n todo -d -f"
    end

    def cleanup
      stop
      if File.exist?(File.join(DB_DIR, "directory.bak"))
        File.rename(File.join(DB_DIR, "directory.bak"), File.join(DB_DIR, "directory.db"))
      end

      return unless File.exist?(File.join(CONFIG_DIR, "config.bak"))

      File.rename(File.join(CONFIG_DIR, "config.bak"), File.join(CONFIG_DIR, "config.yaml"))
    end

    def wait_for_certs
      sleep(2) until File.exist?(CERT_FILE)
    end
  end
end
