require 'spec_helper'

describe Lexic::Cli do
  let(:name) { 'test' }

  subject { Lexic::Cli.new(argv) }

  context 'create' do
    context 'when no name is specified' do
      let(:argv) { ['create'] }

      it 'should raise a CliNameNotSpecified error' do
        expect { subject.execute }.to \
          raise_error(Lexic::CliNameNotSpecified)
      end
    end

    context 'when a name is specified' do
      let(:argv) { ['create',  name] }

      it 'should create a container with the specified name' do
        Lexic::Container.should_receive(:create).with(name)

        subject.execute
      end
    end
  end

  context 'start' do
    context 'when no name is specified' do
      let(:argv) { ['start'] }

      it 'should raise a CliNameNotSpecified error' do
        expect { subject.execute }.to \
          raise_error(Lexic::CliNameNotSpecified)
      end
    end

    context 'when a name is specified' do
      let(:argv) { ['start',  name] }
      let(:container) { double 'container' }

      it 'should start the container with the specified name' do
        Lexic::Container.should_receive(:new).with(name).and_return(container)
        container.should_receive(:start)

        subject.execute
      end
    end
  end

  context 'stop' do
    context 'when no name is specified' do
      let(:argv) { ['stop'] }

      it 'should raise a CliNameNotSpecified error' do
        expect { subject.execute }.to \
          raise_error(Lexic::CliNameNotSpecified)
      end
    end

    context 'when a name is specified' do
      let(:argv) { ['stop',  name] }
      let(:container) { double 'container' }

      it 'should stop the container with the specified name' do
        Lexic::Container.should_receive(:new).with(name).and_return(container)
        container.should_receive(:stop)

        subject.execute
      end
    end
  end

  context 'destroy' do
    context 'when no name is specified' do
      let(:argv) { ['destroy'] }

      it 'should raise a CliNameNotSpecified error' do
        expect { subject.execute }.to \
          raise_error(Lexic::CliNameNotSpecified)
      end
    end

    context 'when a name is specified' do
      let(:argv) { ['destroy',  name] }
      let(:container) { double 'container' }

      it 'should destroy the container with the specified name' do
        Lexic::Container.should_receive(:new).with(name).and_return(container)
        container.should_receive(:destroy)

        subject.execute
      end
    end
  end

  context 'status' do
    context 'when no name is specified' do
      let(:argv) { ['status'] }

      it 'should raise a CliNameNotSpecified error' do
        expect { subject.execute }.to \
          raise_error(Lexic::CliNameNotSpecified)
      end
    end

    context 'when a name is specified' do
      let(:argv) { ['status',  name] }
      let(:container) { double 'container' }

      it 'should status the container with the specified name' do
        Lexic::Container.should_receive(:new).with(name).and_return(container)
        container.should_receive(:status)

        subject.execute
      end
    end
  end
end
