require 'fileutils'

module Lexic
  class Container
    attr_reader :name

    def self.base_path
      "#{ENV['HOME']}/.lexic"
    end

    def self.all
      Dir.glob("#{base_path}/*").map do |path|
        name = File.basename(path)
        new(name)
      end
    end

    def self.create(name)
      new(name).create
    end

    def initialize(name)
      @name = name
    end

    def path
      "#{self.class.base_path}/#{name}"
    end

    def ==(other)
      path == other.path
    end

    def create
      if created?
        raise ContainerAlreadyExists, "#{name} already exists"
      end

      require_root!

      FileUtils.mkdir_p path

      Config.new("#{path}/config").write

      Template['ubuntu'].run(self)
    end

    def created?
      File.directory?(path)
    end
    alias :exists? created?

    def destroy
      require_existing_container!

      require_root!

      FileUtils.rm_r path
    end

    def start
      require_existing_container!

      require_root!

      Bridge.setup unless Bridge.exists?

      system("lxc-start --name=#{name} --daemon")
    end

    def stop
      require_existing_container!

      require_root!

      system("lxc-stop --name=#{name}")
    end

    def ip
      require_existing_container!

      lease = File.
        readlines('/var/lib/misc/dnsmasq.leases').
        grep(/\b#{name}\b/).
        first

      lease.split(' ')[2]
    end

    def status
      require_existing_container!

      io = IO.popen("lxc-info --name=#{name}")
      io.gets.match(/^state:\s+(.*)$/)
      $1
    end

    private
    def require_existing_container!
      unless exists?
        raise ContainerDoesntExist, "#{name} doesnt exist"
      end
    end

    def require_root!
      unless Process.uid == 0
        raise RuntimeError, 'must be run as root'
      end
    end
  end
end
