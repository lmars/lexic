module Lexic
  class Config
    attr_reader :path

    def initialize(path)
      @path = path
    end

    def write
      File.open(path, 'w') do |file|
        file.puts 'lxc.network.type=veth'
        file.puts 'lxc.network.link=lxcbr0'
        file.puts 'lxc.network.flags=up'
        file.puts 'lxc.network.ipv4=10.0.100.2'
      end
    end

    def read
      File.read(path)
    end

    def ip
      unless File.exists?(path)
        raise ConfigFileDoesntExist, "#{path} doesn't exist"
      end

      read.match /ipv4=(.*)/
      $1
    end
  end
end
