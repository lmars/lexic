require 'spec_helper'

describe Lexic::Template do
  let(:name) { 'test' }
  let(:path) { "/usr/lib/lxc/templates/lxc-#{name}" }

  describe '.[]' do
    context 'when the template script doesnt exist' do
      before(:each) do
        File.stub(:exists?).with(path).and_return(false)
      end

      it 'should raise an ArgumentError' do
        expect { Lexic::Template[name] }.to \
          raise_error(ArgumentError, "unknown template #{name}")
      end
    end

    context 'when the template script does exist' do
      before(:each) do
        File.stub(:exists?).with(path).and_return(true)
      end

      subject { Lexic::Template[name] }

      its(:path) { should == path }
    end
  end

  describe '#run' do
    subject { Lexic::Template.new(name) }

    let(:container) do
      double('container',
        :path => container_path,
        :name => container_name
      )
    end

    let(:container_path) { 'path/to/container' }
    let(:container_name) { 'my-container' }

    context 'when not run as root' do
      before(:each) do
        Process.stub(:uid => 1000)
      end

      it 'should raise a RuntimeError' do
        expect { subject.run(container) }.to \
          raise_error(RuntimeError, 'must be run as root')
      end
    end

    context 'when run as root' do
      before(:each) do
        Process.stub(:uid => 0)
      end

      it "should run the template script with the container's name and path" do
        template_command = "#{path}"
        template_command << " --path=#{container_path}"
        template_command << " --name=#{container_name}"

        subject.should_receive(:system).with(template_command)

        subject.run(container)
      end
    end
  end
end
