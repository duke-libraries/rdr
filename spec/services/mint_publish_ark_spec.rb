require 'rails_helper'

RSpec.describe MintPublishArk do

  let(:work) { FactoryBot.create(:dataset) }

  subject { described_class.new(work) }

  describe '#call' do
    describe 'ARK assignment' do
      describe 'no ARK assigned' do
        it 'assigns an ARK' do
          expect(subject.ark).to receive(:assign!)
          subject.call
        end
      end
      describe 'ARK already assigned' do
        before do
          allow(subject.ark).to receive(:assigned?) { true }
          allow(subject.ark).to receive(:identifier) { double(public?: true) }
        end
        it 'does not assign an ARK' do
          expect(subject.ark).to_not receive(:assign!)
          subject.call
        end
      end
    end
    describe 'ARK publication' do
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
            allow(subject.ark).to receive(:identifier) { double(public?: false) }
          end
          it 'publishes the ARK' do
            expect(subject.ark).to receive(:publish!)
            subject.call
          end
        end
        describe 'ARK is public' do
          before do
            allow(subject.ark).to receive(:assigned?) { true }
            allow(subject.ark).to receive(:identifier) { double(public?: true) }
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
