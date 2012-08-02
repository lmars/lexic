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
        Lexic::Config.stub(:new => double(:write => true))
        Lexic::Template.stub(:[] => double(:run => true))
      end

      it 'should create a directory for the container' do
        Dir.should_receive(:mkdir).with(path)

        subject.create
      end

      it 'should write a config file into the containers directory' do
        config = double('config')

        Lexic::Config.
          should_receive(:new).
          with("#{path}/config").
          and_return(config)

        config.should_receive(:write)

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

  describe '#destroy' do
    context 'when not run as root' do
      before(:each) do
        Process.stub(:uid => 1000)
      end

      it 'should raise a RuntimeError' do
        expect { subject.destroy }.to \
          raise_error(RuntimeError, 'must be run as root')
      end
    end

    context 'when run as root' do
      before(:each) do
        Process.stub(:uid => 0)
      end

      it "remove the container's directory" do
        FileUtils.should_receive(:rm_r).with(path)

        subject.destroy
      end
    end
  end

  describe '#start' do
    context 'when not run as root' do
      before(:each) do
        Process.stub(:uid => 1000)
      end

      it 'should raise a RuntimeError' do
        expect { subject.start }.to \
          raise_error(RuntimeError, 'must be run as root')
      end
    end

    context 'when run as root' do
      before(:each) do
        Process.stub(:uid => 0)
      end

      it 'should run lxc-start with the correct arguments' do
        subject.should_receive(:system) do |command|
          command.should match /lxc-start/
          command.should match /--name=#{name}/
          command.should match /--daemon/
        end

        subject.start
      end
    end
  end
end
