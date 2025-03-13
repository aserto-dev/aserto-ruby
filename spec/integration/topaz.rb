# frozen_string_literal: true

require "timeout"

class Topaz
  class << self
    # 2 minutes
    WAIT_FOR_TOPAZ = 2 * 60

    def run
      stop

      if File.exist?(File.join(db_dir, "todo.db"))
        File.rename(File.join(db_dir, "todo.db"), File.join(db_dir, "todo.bak"))
      end

      if File.exist?(File.join(config_dir, "todo.yaml"))
        File.rename(File.join(config_dir, "todo.yaml"), File.join(config_dir, "todo.bak"))
      end

      configure
      start
    end

    def start
      system "topaz start"

      Timeout.timeout(WAIT_FOR_TOPAZ) do
        wait_for_certs

        client = Aserto::Directory::V3::Client.new(
          {
            url: "localhost:9292",
            cert_path: cert_file
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
      system "topaz templates install todo -f --no-console -i"
    end

    def cleanup
      stop
      if File.exist?(File.join(db_dir, "todo.bak"))
        File.rename(File.join(db_dir, "todo.bak"), File.join(db_dir, "todo.db"))
      end

      return unless File.exist?(File.join(config_dir, "todo.bak"))

      File.rename(File.join(config_dir, "todo.bak"), File.join(config_dir, "todo.yaml"))
    end

    def wait_for_certs
      sleep(2) until File.exist?(cert_file)
    end

    def config
      require "json"

      @config ||= JSON.parse(`topaz config info`)
      @config["config"] || {}
    rescue StandardError
      {}
    end

    def cert_file
      File.join(config.fetch("topaz_certs_dir"), "grpc-ca.crt")
    end

    def config_dir
      config.fetch("topaz_cfg_dir")
    end

    def db_dir
      config.fetch("topaz_db_dir")
    end
  end
end
