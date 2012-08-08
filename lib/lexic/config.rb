module Lexic
  class Config
    attr_reader :path
    attr_writer :ip

    def initialize(path)
      @path = path
    end

    def write
      File.open(path, 'w') do |file|
        file.puts 'lxc.network.type=veth'
        file.puts "lxc.network.link=#{Bridge.name}"
        file.puts 'lxc.network.flags=up'
        file.puts "lxc.network.ipv4=#{ip}"
      end
    end

    def read
      File.read(path)
    end

    def ip
      return @ip unless @ip.nil?

      unless File.exists?(path)
        raise ConfigFileDoesntExist, "#{path} doesn't exist"
      end

      read.match /ipv4=(.*)/
      $1
    end
  end
end
