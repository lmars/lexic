require 'fileutils'
require 'ipaddr'

module Lexic
  class Container
    include Utils

    attr_reader :name, :config

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

    def self.available_ip
      ip_low  = IPAddr.new '10.0.100.2'
      ip_high = IPAddr.new '10.0.100.254'

      (ip_low..ip_high).detect { |ip|
        !all.map(&:ip).include?(ip.to_s)
      }.to_s
    end

    def initialize(name)
      @name   = name
      @config = Config.new("#{path}/config")
    end

    def path
      "#{self.class.base_path}/#{name}"
    end

    def ==(other)
      path == other.path
    end

    def create
      if created?
        raise ContainerAlreadyExists, name
      end

      require_root!

      # Grab the IP before creating the directory, as creating the
      # directory will include this container in Container.all
      config.ip = self.class.available_ip

      FileUtils.mkdir_p path

      config.write

      Template['ubuntu'].run(self)

      self
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

      system("lxc-start --name=#{name} --rcfile=#{config.path} --daemon")
    end

    def stop
      require_existing_container!

      require_root!

      system("lxc-stop --name=#{name}")
    end

    def ip
      require_existing_container!

      config.ip
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
        raise ContainerDoesntExist, name
      end
    end
  end
end
