require 'fileutils'

module Lexic
  class Container
    attr_reader :name

    def self.create(name)
      unless Process.uid == 0
        raise RuntimeError, 'must be run as root'
      end

      container = new(name)

      Dir.mkdir container.path
      FileUtils.cp '/etc/lxc/lxc.conf', "#{container.path}/config"

      Template['ubuntu'].run(container)
    end

    def initialize(name)
      @name = name
    end

    def path
      "/var/lib/lxc/#{name}"
    end
  end
end
