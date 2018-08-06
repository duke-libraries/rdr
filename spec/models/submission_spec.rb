require 'rails_helper'

RSpec.describe Submission, type: :model do

  subject { Submission.new(args) }

  describe 'validation' do

    describe '#passed_screening?' do
      describe 'deposit agreement accepted' do
        let(:args) { { deposit_agreement: Submission::AGREE } }
        specify { expect(subject.passed_screening?).to be true }
      end
      describe 'deposit agreement not accepted' do
        let(:args) { { } }
        specify { expect(subject.passed_screening?).to be false }
      end
    end

    describe 'valid submission' do
      describe 'passed screening' do
        let(:args) do
          { deposit_agreement: Submission::AGREE,
            title: 'Submission Title',
            creator: 'Spade, Sam',
            description: 'Description of my research',
            subject: 'awesome',
            doi_exists: 'no',
            using_cc0: Submission::USE_CC0
          }
        end
        specify { expect(subject.valid?).to be true }
      end
      describe 'did not pass screening' do
        let(:args) { { } }
        specify { expect(subject.valid?).to be true }
      end
    end

    describe 'invalid submission' do
      describe 'DOI exists but not provided' do
        let(:args) do
          { deposit_agreement: Submission::AGREE,
            title: 'Submission Title',
            creator: 'Spade, Sam',
            description: 'Description of my research',
            subject: 'awesome',
            doi_exists: 'yes',
            using_cc0: Submission::USE_CC0
          }
        end
        specify { expect(subject.valid?).to be false }
      end
      describe 'not using CC0 but license to use not provided' do
        let(:args) do
          { deposit_agreement: Submission::AGREE,
            title: 'Submission Title',
            creator: 'Spade, Sam',
            description: 'Description of my research',
            subject: 'awesome',
            doi_exists: 'no',
            using_cc0: Submission::NOT_USE_CC0
          }
        end
        specify { expect(subject.valid?).to be false }
      end
    end

  end

end
