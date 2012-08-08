module Lexic
  class Config
    def initialize(path)
      @path = path
    end

    def write
      File.open(@path, 'w') do |file|
        file.puts 'lxc.network.type=veth'
        file.puts 'lxc.network.link=lxcbr0'
        file.puts 'lxc.network.flags=up'
      end
    end
  end
end
