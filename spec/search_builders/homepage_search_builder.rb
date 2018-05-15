require 'rails_helper'

RSpec.describe Hyrax::HomepageSearchBuilder do
  let(:me) { create(:user) }
  let(:config) { CatalogController.blacklight_config }
  let(:scope) do
    double('The scope',
           blacklight_config: config,
           current_ability: Ability.new(me),
           current_user: me)
  end
  let(:builder) { described_class.new(scope) }

  describe "#query" do
    subject { builder.query }

    describe "top level works only" do
      it "adds top level query filter" do
        expect(subject[:fq]).to include("#{Rdr::Index::Fields.top_level}:True")
      end
    end
  end

end
