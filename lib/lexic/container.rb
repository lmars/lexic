require 'fileutils'

module Lexic
  class Container
    def self.create(name)
      container = new(name)

      Dir.mkdir container.path
      FileUtils.cp '/etc/lxc/lxc.conf', "#{container.path}/config"

      Template['ubuntu'].run(name)
    end

    def initialize(name)
      @name = name
    end

    def path
      "/var/lib/lxc/#{@name}"
    end
  end
end
