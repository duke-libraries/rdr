require 'rails_helper'

RSpec.describe AssignDoi do

  let(:work) { FactoryBot.build(:dataset) }

  subject { described_class.new(work) }

  describe '#assign!' do

    describe 'DOI is assignable to work' do
      before do
        allow(work).to receive(:ark) { "ark:/99999/fk4zzzzz" }
        allow(work).to receive(:doi_assignable?) { true }
      end

      let(:expected_doi) { "#{AssignDoi::DOI_PREFIX}/fk4zzzzz" }
      it 'assigns a DOI' do
        subject.assign!
        expect(work.doi).to eq(expected_doi)
      end
    end

    describe 'DOI is not assignable to work' do
      before do
        allow(work).to receive(:doi_assignable?) { false }
      end
      it 'throws exception' do
        expect{subject.assign!}.to raise_error(Rdr::DoiAssignmentError, I18n.t('rdr.doi.not_assignable'))
      end
    end
  end
end

