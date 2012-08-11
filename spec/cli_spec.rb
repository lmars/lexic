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
end
