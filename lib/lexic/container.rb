require 'fileutils'

module Lexic
  class Container
    attr_reader :name

    def self.create(name)
      new(name).create
    end

    def initialize(name)
      @name = name
    end

    def path
      "/var/lib/lxc/#{name}"
    end

    def create
      unless Process.uid == 0
        raise RuntimeError, 'must be run as root'
      end

      Dir.mkdir path

      Config.new("#{path}/config").write

      Template['ubuntu'].run(self)
    end

    def destroy
      unless Process.uid == 0
        raise RuntimeError, 'must be run as root'
      end

      FileUtils.rm_r path
    end

    def start
      unless Process.uid == 0
        raise RuntimeError, 'must be run as root'
      end

      system("lxc-start --name=#{name} --daemon")
    end

    def stop
      unless Process.uid == 0
        raise RuntimeError, 'must be run as root'
      end

      system("lxc-stop --name=#{name}")
    end

    def ip
      lease = File.
        readlines('/var/lib/misc/dnsmasq.leases').
        grep(/\b#{name}\b/).
        first

      lease.split(' ')[2]
    end
  end
end
