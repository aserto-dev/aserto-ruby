# frozen_string_literal: true

class Topaz
  class << self
    def run
      stop

      db_dir = File.join(ENV.fetch("HOME", ""), ".config/topaz/db")
      if File.exist?(File.join(db_dir, "directory.db"))
        File.rename(File.join(db_dir, "directory.db"), File.join(db_dir, "directory.bak"))
      end
      configure
      start
    end

    def start
      system "topaz start"

      client = Aserto::Directory::V3::Client.new(
        {
          url: "localhost:9292",
          cert_path: File.join(ENV.fetch("HOME", ""), ".config/topaz/certs/grpc-ca.crt")
        }
      )
      begin
        GrpcMock.allow_net_connect!
        client.get_objects(object_type: "user")
      rescue GRPC::Unavailable => e
        puts e.message
        puts "sleep 1"
        sleep 1
        puts "retry..."
        retry
      end

      GrpcMock.disable_net_connect!
      "server is running"
    end

    def stop
      system "topaz stop"
    end

    def configure
      system "topaz configure -r ghcr.io/aserto-policies/policy-todo:2.1.0 -n todo -d -s"
    end

    def cleanup
      stop
      db_dir = File.join(ENV.fetch("HOME", ""), ".config/topaz/db")
      return unless File.exist?(File.join(db_dir, "directory.bak"))

      File.rename(File.join(db_dir, "directory.bak"), File.join(db_dir, "directory.db"))
    end
  end
end
