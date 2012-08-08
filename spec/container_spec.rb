require 'spec_helper'

describe Lexic::Container do
  extend Assertions

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
    let(:paths) { names.map { |n| "#{base_path}/#{n}" } }

    before(:each) do
      Dir.stub(:glob).with("#{base_path}/*").and_return(paths)
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

  describe '.available_ip' do
    let(:containers) do
      [
        double(:ip => '10.0.100.2'),
        double(:ip => '10.0.100.3'),
        double(:ip => '10.0.100.5')
      ]
    end

    before(:each) do
      Lexic::Container.stub(:all => containers)
    end

    it 'should return the lowest ip in the Lexic network not used by any container' do
      Lexic::Container.available_ip.should == '10.0.100.4'
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

    let(:config) { double('config', :ip= => true, :write => true) }
    let(:available_ip) { '10.0.100.4' }

    before(:each) do
      # Assume the container is not created
      subject.stub(:created? => false)

      subject.stub(:config => config)

      FileUtils.stub(:mkdir_p)
      Lexic::Container.stub(:available_ip => available_ip)
      Lexic::Config.any_instance.stub(:write => true)
      Lexic::Template.stub(:[] => double(:run => true))
    end

    it 'should create a directory for the container' do
      FileUtils.should_receive(:mkdir_p).with(path)

      subject.create
    end

    it 'should get an available ip for the container' do
      Lexic::Container.should_receive(:available_ip)

      subject.create
    end

    it "should assign the ip to the container's config object" do
      config.should_receive(:ip=).with(available_ip)

      subject.create
    end

    it "should call write on the container's config object" do
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

  describe '#config' do
    it 'returns a Config with the correct path' do
      subject.config.path.should == "#{path}/config"
    end
  end

  describe '#ip' do
    let(:ip) { double('ip') }
    let(:config) { double('config', :ip => ip) }

    before(:each) do
      subject.stub(:config => config)
    end

    it "should delegate to the container's config" do
      config.should_receive(:ip)
      subject.ip
    end

    it "should return the ip of the container's config" do
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
