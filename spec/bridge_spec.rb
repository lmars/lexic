require 'spec_helper'

describe Lexic::Bridge do
  extend Assertions

  let(:name) { 'test-br0' }
  let(:network) { '10.0.100.0/24' }
  let(:ip) { '10.0.100.1' }
  let(:netmask) { '255.255.255.0' }
  let(:sysfs_dir) { "/sys/class/net/#{name}" }

  before(:each) do
    subject.stub(:name => name)
  end

  assert_methods_require_root(:setup)

  describe '#exists?' do
    context "when the bridge's sysfs directory exists" do
      before(:each) do
        File.stub(:directory?).with(sysfs_dir).and_return(true)
      end

      it { should exist }
    end

    context "when the bridge's sysfs directory doesn't exist" do
      before(:each) do
        File.stub(:directory?).with(sysfs_dir).and_return(false)
      end

      it { should_not exist }
    end
  end

  describe '#setup' do
    before(:each) do
      subject.stub(:system)
    end

    it 'should create a bridge interface with the correct name' do
      subject.should_receive(:system).
        with("brctl addbr #{name}")

      subject.setup
    end

    it 'should bring the interface up' do
      subject.should_receive(:system).
        with("ifconfig #{name} #{ip} netmask #{netmask} up")

      subject.setup
    end

    it 'should set up routing for the interface' do
      subject.should_receive(:system).
        with("iptables -A POSTROUTING -s #{network} -t nat -j MASQUERADE")

      subject.setup
    end
  end
end
