require 'lexic/container'
require 'lexic/template'
require 'lexic/config'

module Lexic
  class ContainerAlreadyExists < StandardError; end
  class ContainerDoesntExist < StandardError; end
end
