require 'spec_helper'

describe Lexic::Container do
  let(:name) { 'test' }
  let(:path) { "/var/lib/lxc/#{name}" }

  subject { Lexic::Container.new(name) }

  its(:name) { should == name }
  its(:path) { should == path }

  describe '.create' do
    let(:container) { double('container', :create => true) }

    it 'should create a new object' do
      Lexic::Container.
        should_receive(:new).
        with(name).
        and_return(container)

      Lexic::Container.create(name)
    end

    it 'should call create on the new object' do
      Lexic::Container.
        stub(:new).
        with(name).
        and_return(container)

      container.should_receive :create

      Lexic::Container.create(name)
    end
  end

  describe '#create' do
    context 'when not run as root' do
      before(:each) do
        Process.stub(:uid => 1000)
      end

      it 'should raise a RuntimeError' do
        expect { subject.create }.to \
          raise_error(RuntimeError, 'must be run as root')
      end
    end

    context 'when run as root' do
      before(:each) do
        Process.stub(:uid => 0)

        Dir.stub(:mkdir)
        FileUtils.stub(:cp)
        Lexic::Template.stub(:[] => double(:run => true))
      end

      let(:default_config) { '/etc/lxc/lxc.conf' }

      it 'should create a directory for the container' do
        Dir.should_receive(:mkdir).with(path)

        subject.create
      end

      it 'should copy the default config into the containers directory' do
        FileUtils.
          should_receive(:cp).
          with(default_config, "#{path}/config")

        subject.create
      end

      it 'should run an ubuntu Template passing in a container object' do
        Lexic::Container.stub(:new => subject)

        template = double('template')

        Lexic::Template.
          should_receive(:[]).
          with('ubuntu').
          and_return(template)

        template.should_receive(:run).with(subject)

        subject.create
      end
    end
  end
end