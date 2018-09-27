require 'rails_helper'

RSpec.describe AssignRegisterDoiJob do

  let(:work) { FactoryBot.build(:dataset) }

  describe '#perform' do
    before do
      allow(work).to receive(:reload) { work }
    end
    describe 'DOI assignment' do
      before do
        allow(CrossrefRegistration).to receive(:call).with(work)
      end
      it 'calls the service to assign a DOI' do
        expect(AssignDoi).to receive(:call).with(work)
        subject.perform(work)
      end
    end
    describe 'DOI registration' do
      before do
        allow(AssignDoi).to receive(:call).with(work)
      end
      describe 'DOI is registerable' do
        before do
          allow(work).to receive(:doi_registerable?) { true }
        end
        it 'calls the service to register the DOI' do
          expect(CrossrefRegistration).to receive(:call).with(work)
          subject.perform(work)
        end
      end
      describe 'DOI is not registerable' do
        before do
          allow(work).to receive(:doi_registerable?) { false }
        end
        it 'does not call the service to register the DOI' do
          expect(CrossrefRegistration).to_not receive(:call).with(work)
          subject.perform(work)
        end
      end
    end
  end

end
