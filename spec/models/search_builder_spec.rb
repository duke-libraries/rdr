require 'rails_helper'

RSpec.describe SearchBuilder do
  let(:me) { create(:user) }
  let(:config) { CatalogController.blacklight_config }
  let(:scope) do
    double('The scope',
           blacklight_config: config,
           current_ability: Ability.new(me),
           current_user: me)
  end
  let(:builder) { described_class.new(scope).with(params) }

  describe "#query" do
    subject { builder.query }

    context "adds the correct query filter" do
      context 'latest version param' do
        context "param latest_version is present" do
          let(:params) { { "latest_version" => 'true' } }
          it "adds latest version filter" do
            expect(subject[:fq]).to include("-#{Rdr::Index::Fields::IS_REPLACED_BY}:*")
          end
        end
        context "param latest_version is not present" do
          let(:params) { { } }
          it "does not add latest version filter" do
            expect(subject[:fq]).to_not include("-#{Rdr::Index::Fields::IS_REPLACED_BY}:*")
          end
        end
      end
      context 'top level param' do
        let(:top_level_or_collection_filter) do
          "(#{Rdr::Index::Fields::TOP_LEVEL}:True OR has_model_ssim:Collection)"
        end
        context "param top_level is present" do
          let(:params) { { "top_level" => 'true' } }
          it "adds top level or collection filter" do
            expect(subject[:fq]).to include(top_level_or_collection_filter)
          end
        end
        context "param top_level is not present" do
          let(:params) { { } }
          it "does not add top level or collection filter" do
            expect(subject[:fq]).to_not include(top_level_or_collection_filter)
          end
        end
      end
    end
  end
end
