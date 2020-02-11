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
          stub_request(:post, "https://ezid.cdlib.org/shoulder/ark:/99999/fk4").
              with(
                  body: "_profile: dc\n_export: no\n_status: reserved",
                  headers: {
                      'Accept'=>'*/*',
                      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                      'Authorization'=>'Basic YXBpdGVzdDphcGl0ZXN0',
                      'Content-Type'=>'text/plain; charset=UTF-8',
                      'Host'=>'ezid.cdlib.org',
                      'User-Agent'=>'Ruby'
                  }).
              to_return(status: 201, body: "success: ark:/99999/fk4b86j23c", headers: {})
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
