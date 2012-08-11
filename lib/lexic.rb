require 'lexic/utils'
require 'lexic/container'
require 'lexic/template'
require 'lexic/config'
require 'lexic/bridge'

module Lexic
  class ContainerAlreadyExists < StandardError; end
  class ContainerDoesntExist < StandardError; end
  class ConfigFileDoesntExist < StandardError; end
  class BridgeCommandNotFound < StandardError; end
end
