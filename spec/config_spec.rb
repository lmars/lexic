require 'spec_helper'

describe Lexic::Config do
  let(:path) { 'path/to/config' }
  let(:ip) { '1.2.3.4' }

  subject { Lexic::Config.new(path) }

  its(:path) { should == path }

  describe '#write' do

    before(:each) do
      subject.stub(:ip => ip)
    end

    it 'opens the correct file in write mode' do
      File.
        should_receive(:open).
        with(path, 'w')

      subject.write
    end

    it 'writes the default config into the file' do
      file = double('file')

      File.stub(:open).and_yield(file)

      file.should_receive(:puts).with('lxc.network.type=veth')
      file.should_receive(:puts).with('lxc.network.link=lexic-br0')
      file.should_receive(:puts).with('lxc.network.flags=up')
      file.should_receive(:puts).with("lxc.network.ipv4=#{ip}")

      subject.write
    end
  end

  describe '#read' do
    let(:contents) { double('contents') }

    before(:each) do
      File.stub(:read).with(path).and_return(contents)
    end

    it 'should read the underlying file' do
      File.should_receive(:read).with(path)

      subject.read
    end

    it 'should return the contents of the file' do
      subject.read.should == contents
    end
  end

  describe '#ip' do
    context 'when an ip has been assigned' do
      before(:each) do
        subject.ip = ip
      end

      its(:ip) { should == ip }
    end

    context 'when the ip has not been assigned' do
      context "when the underlying file doesn't exist" do
        before(:each) do
          File.stub(:exists?).with(path).and_return(false)
        end

        it 'should raise a ConfigFileDoesntExist error' do
          expect { subject.ip }.to \
            raise_error(Lexic::ConfigFileDoesntExist, "#{path} doesn't exist")
        end
      end

      context 'when the underlying file does exist' do
        let(:contents) do
          <<-EOS
            lxc.network.type=veth
            lxc.network.link=lexic-br0
            lxc.network.flags=up
            lxc.network.ipv4=#{ip}
          EOS
        end

        before(:each) do
          File.stub(:exists?).with(path).and_return(true)

          subject.stub(:read => contents)
        end

        its(:ip) { should == ip }
      end
    end
  end
end
