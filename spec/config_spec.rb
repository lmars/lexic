require 'spec_helper'

describe Lexic::Config do
  describe '#write' do
    let(:path) { 'path/to/config' }

    subject { Lexic::Config.new(path) }

    it 'opens the correct file in append mode' do
      File.
        should_receive(:open).
        with(path, 'a')

      subject.write
    end

    it 'writes the default config into the file' do
      file = double('file')

      File.stub(:open).and_yield(file)

      file.should_receive(:puts).with('lxc.network.type=veth')
      file.should_receive(:puts).with('lxc.network.link=lxcbr0')
      file.should_receive(:puts).with('lxc.network.flags=up')

      subject.write
    end
  end
end
