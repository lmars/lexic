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
  end
end
