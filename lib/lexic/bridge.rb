module Lexic
  module Bridge
    class << self
      include Utils

      def exists?
        File.directory? sysfs_dir
      end

      def name
        'lexic-br0'
      end

      def network
        '10.0.100.0/24'
      end

      def ip
        '10.0.100.1'
      end

      def netmask
        '255.255.255.0'
      end

      def setup
        require_root!

        system("brctl addbr #{name}")
        system("ifconfig #{name} #{ip} netmask #{netmask} up")
        system("iptables -A POSTROUTING -s #{network} -t nat -j MASQUERADE")
      end

      private
      def sysfs_dir
        "/sys/class/net/#{name}"
      end
    end
  end
end
