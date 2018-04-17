require 'rails_helper'

RSpec.describe ActiveFedora::Base do

  describe '.find_by_ark' do
    let(:ark) { 'ark:/99999/fk45156v36' }
    describe 'one object found' do
      let!(:dataset) { FactoryBot.create(:dataset, ark: ark) }
      it 'returns the object' do
        expect(described_class.find_by_ark(ark)).to eq(dataset)
      end
    end
    describe 'no objects found' do
      it 'raises an error' do
        expect{ described_class.find_by_ark(ark) }.to raise_error(Rdr::NotFoundError,
                                                                  I18n.t('rdr.not_found', target: ark))
      end
    end
    describe 'more than one object found' do
      before do
        FactoryBot.create(:dataset, ark: ark)
        FactoryBot.create(:dataset, ark: ark)
      end
      it 'raises an error' do
        expect{ described_class.find_by_ark(ark) }.to raise_error(Rdr::UnexpectedMultipleResultsError,
                                                                  I18n.t('rdr.unexpected_multiple_results',
                                                                         identifier: ark))

      end
    end
  end

end
