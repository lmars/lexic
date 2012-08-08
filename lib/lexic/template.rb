module Lexic
  class Template
    include Utils

    def self.[](name)
      template = new(name)

      unless File.exists?(template.path)
        raise ArgumentError, "unknown template #{name}"
      end

      template
    end

    def initialize(name)
      @name = name
    end

    def path
      "/usr/lib/lxc/templates/lxc-#{@name}"
    end

    def run(container)
      require_root!

      system("#{path} --path=#{container.path} --name=#{container.name}")
    end
  end
end
