require 'rails_helper'

RSpec.describe DeactivateArk do

  let(:ark) { 'foo' }

  subject { described_class.new(ark) }

  describe '#call' do
    describe 'ARK deactivation' do
      describe 'ARK is reserved' do
        before do
          allow(subject.ark).to receive(:assigned?) { true }
          allow(subject.ark).to receive(:identifier) { double(reserved?: true) }
        end
        it 'deletes the ARK' do
          expect(subject.ark).to receive(:delete!)
          subject.call
        end
      end
      describe 'ARK is public' do
        before do
          allow(subject.ark).to receive(:assigned?) { true }
          allow(subject.ark).to receive(:identifier) { double(public?: true, reserved?: false) }
        end
        it 'does not deactivate the ARK' do
          expect(subject.ark).to receive(:deactivate!)
          subject.call
        end
      end
    end
  end

end
