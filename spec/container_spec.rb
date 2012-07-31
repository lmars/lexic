require 'spec_helper'

describe Lexic::Container do
  let(:name) { 'test' }
  let(:path) { "/var/lib/lxc/#{name}" }

  subject { Lexic::Container.new(name) }

  its(:path) { should == path }

  describe '.create' do
    before(:each) do
      Dir.stub(:mkdir)
      FileUtils.stub(:cp)
      Lexic::Template.stub(:[] => double(:run => true))
    end

    let(:default_config) { '/etc/lxc/lxc.conf' }

    it 'should create a directory for the container' do
      Dir.should_receive(:mkdir).with(path)

      Lexic::Container.create name
    end

    it 'should copy the default config into the containers directory' do
      FileUtils.
        should_receive(:cp).
        with(default_config, "#{path}/config")

      Lexic::Container.create name
    end

    it 'should initialise an ubuntu Template object with the correct name' do
      template = double('template')

      Lexic::Template.
        should_receive(:[]).
        with('ubuntu').
        and_return(template)

      template.should_receive(:run).with(name)

      Lexic::Container.create name
    end
  end
end
