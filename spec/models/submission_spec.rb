require 'rails_helper'

RSpec.describe Submission, type: :model do

  subject { Submission.new(args) }

  describe 'validation' do

    describe '#past_screening?' do
      describe 'deposit agreement accepted' do
        let(:args) { { deposit_agreement: 'I agree' } }
        specify { expect(subject.past_screening?).to be true }
      end
      describe 'deposit agreement not accepted' do
        let(:args) { { } }
        specify { expect(subject.past_screening?).to be false }
      end
    end

    describe 'valid submission' do
      describe 'past screening' do
        let(:args) do
          { deposit_agreement: 'I agree',
            title: 'Submission Title',
            authors: 'Spade, Sam',
            description: 'Description of my research',
            keywords: 'awesome',
            doi_exists: 'no',
            using_cco: 'will use cco'
          }
        end
        specify { expect(subject.valid?).to be true }
      end
      describe 'not past screening' do
        let(:args) { { } }
        specify { expect(subject.valid?).to be true }
      end
    end

    describe 'invalid submission' do
      describe 'DOI exists but not provided' do
        let(:args) do
          { deposit_agreement: 'I agree',
            title: 'Submission Title',
            authors: 'Spade, Sam',
            description: 'Description of my research',
            keywords: 'awesome',
            doi_exists: 'yes',
            using_cco: 'yes'
          }
        end
        specify { expect(subject.valid?).to be false }
      end
      describe 'not using CC0 but license to use not provided' do
        let(:args) do
          { deposit_agreement: 'I agree',
            title: 'Submission Title',
            authors: 'Spade, Sam',
            description: 'Description of my research',
            keywords: 'awesome',
            doi_exists: 'no',
            using_cco: 'no'
          }
        end
        specify { expect(subject.valid?).to be false }
      end
    end

  end

end
