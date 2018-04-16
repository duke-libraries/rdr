# Generated via
#  `rails generate hyrax:work Dataset`
require 'rails_helper'

RSpec.describe Hyrax::DatasetForm do

  describe "terms and fields" do
    subject { described_class.new(dataset, nil, nil) }
    let(:dataset) { FactoryBot.build(:dataset) }

    its(:required_fields) { is_expected.to eq [:title] }
    its(:primary_terms) { is_expected.to include(:creator,
                                                 :publisher,
                                                 :available,
                                                 :description,
                                                 :resource_type,
                                                 :license,
                                                 :rights_note,
                                                 :bibliographic_citation) }
    its(:secondary_terms) { is_expected.to include(:affiliation,
                                                   :alternative,
                                                   :ark,
                                                   :doi,
                                                   :format,
                                                   :provenance,
                                                   :replaces,
                                                   :is_replaced_by,
                                                   :temporal) }
  end

  describe ".model_attributes" do
    subject { described_class.model_attributes(params) }
    let(:params) do
      ActionController::Parameters.new(
        title: ['Foo Bar'],
        description: [''],
        doi: '')
    end

    its(['description']) { is_expected.to be_empty }
    its(['doi']) { is_expected.to be_nil }
  end

end
