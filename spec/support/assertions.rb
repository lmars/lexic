module Assertions
  def assert_methods_require_existing_container(*methods)
    methods.each do |method|
      describe "##{method}" do
        context 'when the container does not exist' do
          before(:each) do
            subject.stub(:exists? => false)
          end

          it 'raises a ContainerDoesntExist error' do
            expect { subject.public_send(method) }.to \
              raise_error(Lexic::ContainerDoesntExist, name)
          end
        end
      end
    end

    # Assume the container exists for the rest of the tests
    before(:each) do
      subject.stub(:exists? => true)
    end
  end

  def assert_methods_require_root(*methods)
    methods.each do |method|
      describe "##{method}" do
        context 'when not run as root' do
          before(:each) do
            Process.stub(:uid => 1000)
          end

          it 'should raise a RuntimeError' do
            expect { subject.public_send(method) }.to \
              raise_error(RuntimeError, 'must be run as root')
          end
        end
      end
    end

    # Assume root for the rest of the tests
    before(:each) do
      Process.stub(:uid => 0)
    end
  end
end
