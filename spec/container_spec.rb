require 'spec_helper'
require 'support/container_helper'

describe Lexic::Container do
  extend ContainerHelper

  let(:name) { 'test' }
  let(:home_path) { '/home/test' }
  let(:base_path) { "#{home_path}/.lexic" }
  let(:path) { "#{base_path}/#{name}" }

  subject { Lexic::Container.new(name) }

  before(:each) do
    @__home = ENV['HOME']
    ENV['HOME'] = home_path
  end

  after(:each) do
    ENV['HOME'] = @__home
  end

  its(:name) { should == name }
  its(:path) { should == path }

  assert_methods_require_existing_container(
    :destroy, :start, :stop, :ip, :status
  )

  assert_methods_require_root(
    :create, :destroy, :start, :stop
  )

  describe '.all' do
    let(:names) { %w(test1 test2 test3) }

    before(:each) do
      Dir.stub(:glob).with("#{base_path}/*").and_return(names)
    end

    it 'should return three Containers' do
      Lexic::Container.all.should == names.map { |n| Lexic::Container.new(n) }
    end
  end

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
    context 'when the container has already been created' do
      before(:each) do
        subject.stub(:created? => true)
      end

      it 'should raise a ContainerAlreadyExists error' do
        expect { subject.create }.to \
          raise_error(Lexic::ContainerAlreadyExists, "#{name} already exists")
      end
    end

    before(:each) do
      # Assume the container is not created
      subject.stub(:created? => false)

      FileUtils.stub(:mkdir_p)
      Lexic::Config.stub(:new => double(:write => true))
      Lexic::Template.stub(:[] => double(:run => true))
    end

    it 'should create a directory for the container' do
      FileUtils.should_receive(:mkdir_p).with(path)

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

  describe '#created?' do
    context "when the container's directory doesn't exist" do
      before(:each) do
        File.stub(:directory?).with(path).and_return(false)
      end

      it { should_not be_created }
    end

    context "when the container's directory does exist" do
      before(:each) do
        File.stub(:directory?).with(path).and_return(true)
      end

      it { should be_created }
    end
  end

  describe '#destroy' do
    it "remove the container's directory" do
      FileUtils.should_receive(:rm_r).with(path)

      subject.destroy
    end
  end

  describe '#start' do
    context "when the bridge interface doesn't exist" do
      before(:each) do
        Lexic::Bridge.stub(:exists? => false)
      end

      it 'should setup the bridge interface' do
        Lexic::Bridge.should_receive(:setup)

        subject.start
      end
    end

    # Assume the bridge interface exists
    before(:each) do
      Lexic::Bridge.stub(:exists? => true)
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

  describe '#stop' do
    it 'should run lxc-stop with the correct arguments' do
      subject.
        should_receive(:system).
        with("lxc-stop --name=#{name}")

      subject.stop
    end
  end

  describe '#ip' do
    let(:ip) { '10.0.3.3' }
    let(:leases) do
      [
        "1343944392 00:11:22:33:44:55 10.0.3.2 foo     *",
        "1343944592 00:11:22:33:44:56 #{ip}    #{name} *",
        "1343944892 00:11:22:33:44:57 10.0.3.4 bar     *"
      ]
    end

    it 'should find the ip in the leases database' do
      File.
        should_receive(:readlines).
        with('/var/lib/misc/dnsmasq.leases').
        and_return(leases)

      subject.ip.should == ip
    end
  end

  describe '#status' do
    before(:each) do
      IO.stub(:popen).with("lxc-info --name=#{name}").and_return(io)
    end

    context 'when the container is not running' do
      let(:io) { double('io', :gets => 'state:   STOPPED') }

      its(:status) { should == 'STOPPED' }
    end

    context 'when the container is running' do
      let(:io) { double('io', :gets => 'state:   RUNNING') }

      its(:status) { should == 'RUNNING' }
    end
  end
end
