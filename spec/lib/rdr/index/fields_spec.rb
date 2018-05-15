require 'rails_helper'

module Rdr::Index
  RSpec.describe Fields do
    describe "class methods" do
      subject { described_class }

      shared_examples "a stored_searchable and facetable field" do |field|
        it_behaves_like "a stored_searchable field", field
        it_behaves_like "a facetable field", field
      end

      shared_examples "a stored_searchable field" do |field|
        its(field) { is_expected.to eq "#{field}_tesim" }
        specify { expect(subject.const_get(field.to_s.upcase)).to eq "#{field}_tesim" }
      end

      shared_examples "a stored_sortable field" do |field|
        its(field) { is_expected.to eq "#{field}_ssi" }
        specify { expect(subject.const_get(field.to_s.upcase)).to eq "#{field}_ssi" }
      end

      shared_examples "a facetable field" do |field|
        its("#{field}_facet") { is_expected.to eq "#{field}_sim" }
        specify { expect(subject.const_get("#{field.to_s.upcase}_FACET")).to eq "#{field}_sim" }
      end

      shared_examples "a dateable field" do |field|
        its(field) { is_expected.to eq "#{field}_dtsim" }
        specify { expect(subject.const_get(field.to_s.upcase)).to eq "#{field}_dtsim" }
      end

      shared_examples "a sortable date field" do |field|
        its(field) { is_expected.to eq "#{field}_dtsi" }
        specify { expect(subject.const_get(field.to_s.upcase)).to eq "#{field}_dtsi" }
      end

      shared_examples "a boolean field" do |field|
        its(field) { is_expected.to eq "#{field}_bsi" }
        specify { expect(subject.const_get(field.to_s.upcase)).to eq "#{field}_bsi" }
      end

      shared_examples "a symbol field" do |field|
        its(field) { is_expected.to eq "#{field}_ssim" }
        specify { expect(subject.const_get(field.to_s.upcase)).to eq "#{field}_ssim" }
      end

      STORED_SEARCHABLE_FIELDS.each do |field|
        it_behaves_like "a stored_searchable field", field
      end

      STORED_SEARCHABLE_FACETABLE_FIELDS.each do |field|
        it_behaves_like "a stored_searchable and facetable field", field
      end

      SYMBOL_FIELDS.each do |field|
        it_behaves_like "a symbol field", field
      end

      STORED_SORTABLE_FIELDS.each do |field|
        it_behaves_like "a stored_sortable field", field
      end

      DATEABLE_FIELDS.each do |field|
        it_behaves_like "a dateable field", field
      end

      SORTABLE_DATE_FIELDS.each do |field|
        it_behaves_like "a sortable date field", field
      end

      BOOLEAN_FIELDS.each do |field|
        it_behaves_like "a boolean field", field
      end

      its(:depositor_symbol) { is_expected.to eq "depositor_ssim" }
      specify { expect(subject::DEPOSITOR_SYMBOL).to eq "depositor_ssim" }

    end
  end
end
