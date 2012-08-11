require 'lexic/utils'
require 'lexic/container'
require 'lexic/template'
require 'lexic/config'
require 'lexic/bridge'
require 'lexic/cli'

module Lexic
  class ContainerAlreadyExists < StandardError; end
  class ContainerDoesntExist < StandardError; end
  class ConfigFileDoesntExist < StandardError; end
  class BridgeCommandNotFound < StandardError; end
  class CliNameNotSpecified < StandardError; end
end
