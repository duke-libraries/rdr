require 'rails_helper'

RSpec.describe MintPublishArk do

  let(:work) { FactoryBot.create(:dataset) }

  subject { described_class.new(work) }

  describe '#call' do
    describe 'ARK assignment' do
      before do
        allow(subject.ark).to receive(:target!) { true }
      end
      describe 'no ARK assigned' do
        it 'assigns an ARK' do
          expect(subject.ark).to receive(:assign!)
          subject.call
        end
      end
      describe 'ARK already assigned' do
        before do
          allow(subject.ark).to receive(:assigned?) { true }
          allow(subject.ark).to receive(:identifier) { double(reserved?: false, public?: true) }
        end
        it 'does not assign an ARK' do
          expect(subject.ark).to_not receive(:assign!)
          subject.call
        end
      end
    end
    describe 'set ARK target' do
      describe 'when no ARK assigned' do
        before do
          allow(subject.ark).to receive(:assigned?) { false }
        end
        it 'does not call the method to set a target' do
          expect(subject.ark).to_not receive(:target!)
          subject.call
        end
      end
      describe 'when ARK is assigned' do
        before do
          allow(subject.ark).to receive(:assigned?) { true }
        end
        describe 'when the ARK is reserved' do
          before do
            allow(subject.ark).to receive(:identifier) { double(public?: false, reserved?: true) }
            allow(subject.ark).to receive(:publish!)
          end
          it 'calls the method to set a target' do
            expect(subject.ark).to receive(:target!)
            subject.call
          end
        end
        describe 'when the ARK is not reserved' do
          before do
            allow(subject.ark).to receive(:identifier) { double(public?: true, reserved?: false) }
          end
          it 'does not call the method to set a target' do
            expect(subject.ark).to_not receive(:target!)
            subject.call
          end
        end
      end
    end
    describe 'ARK publication' do
      before do
        allow(subject.ark).to receive(:target!) { true }
      end
      describe 'no ARK assigned' do
        before do
          allow(subject.ark).to receive(:assign!)
        end
        it 'does not publish the ARK' do
          expect(subject.ark).to_not receive(:publish!)
          subject.call
        end
      end
      describe 'ARK assigned' do
        describe 'ARK not public' do
          before do
            allow(subject.ark).to receive(:assigned?) { true }
            allow(subject.ark).to receive(:identifier) { double(reserved?: true, public?: false) }
          end
          it 'publishes the ARK' do
            expect(subject.ark).to receive(:publish!)
            subject.call
          end
        end
        describe 'ARK is public' do
          before do
            allow(subject.ark).to receive(:assigned?) { true }
            allow(subject.ark).to receive(:identifier) { double(reserved?: false, public?: true) }
          end
          it 'does not publish the ARK' do
            expect(subject.ark).to_not receive(:publish!)
            subject.call
          end
        end
      end
    end
  end

end
