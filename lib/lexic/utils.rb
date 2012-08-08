module Lexic
  module Utils
    private
    def require_root!
      unless Process.uid == 0
        raise RuntimeError, 'must be run as root'
      end
    end
  end
end
