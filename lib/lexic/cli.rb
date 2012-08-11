module Lexic
  class Cli
    def initialize(argv)
      @argv = argv
    end

    def execute
      if @argv[1].nil?
        raise CliNameNotSpecified
      end

      Container.create @argv[1]
    end
  end
end
