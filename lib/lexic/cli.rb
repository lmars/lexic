module Lexic
  class Cli
    def initialize(argv)
      @argv = argv
    end

    def execute
      if @argv[1].nil?
        raise CliNameNotSpecified
      end

      case @argv[0]
      when 'create'
        Container.create @argv[1]
      when 'start'
        Container.new(@argv[1]).start
      when 'stop'
        Container.new(@argv[1]).stop
      when 'destroy'
        Container.new(@argv[1]).destroy
      when 'status'
        puts Container.new(@argv[1]).status
      end
    end
  end
end
