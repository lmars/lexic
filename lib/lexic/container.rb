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
      if created?
        raise ContainerAlreadyExists, "#{name} already exists"
      end

      require_root!

      Dir.mkdir path

      Config.new("#{path}/config").write

      Template['ubuntu'].run(self)
    end

    def created?
      File.directory?(path)
    end
    alias :exists? created?

    def destroy
      unless exists?
        raise ContainerDoesntExist, "#{name} doesnt exist"
      end

      require_root!

      FileUtils.rm_r path
    end

    def start
      unless exists?
        raise ContainerDoesntExist, "#{name} doesnt exist"
      end

      require_root!

      system("lxc-start --name=#{name} --daemon")
    end

    def stop
      unless exists?
        raise ContainerDoesntExist, "#{name} doesnt exist"
      end

      require_root!

      system("lxc-stop --name=#{name}")
    end

    def ip
      unless exists?
        raise ContainerDoesntExist, "#{name} doesnt exist"
      end

      lease = File.
        readlines('/var/lib/misc/dnsmasq.leases').
        grep(/\b#{name}\b/).
        first

      lease.split(' ')[2]
    end

    def status
      unless exists?
        raise ContainerDoesntExist, "#{name} doesnt exist"
      end

      io = IO.popen("lxc-info --name=#{name}")
      io.gets.match(/^state:\s+(.*)$/)
      $1
    end

    private
    def require_root!
      unless Process.uid == 0
        raise RuntimeError, 'must be run as root'
      end
    end
  end
end
