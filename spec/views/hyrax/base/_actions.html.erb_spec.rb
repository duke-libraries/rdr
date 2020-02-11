# frozen_string_literal: true

# NOTE: We may be able to remove this test and its associated partial
# in the future if https://github.com/samvera/hyrax/issues/147 gets fixed
# in Hyrax core.

require 'rails_helper'

RSpec.describe "hyrax/base/_actions.html.erb", type: :view do
  let(:ability)  { Ability.new(user) }
  let(:user) { FactoryBot.build(:user) }
  let(:solr_document) {
    SolrDocument.new( id: "bn999672v",
                      has_model_ssim: ['FileSet'],
                      active_fedora_model_ssi: 'FileSet', 
    )
  }
  let(:member) { Hyrax::FileSetPresenter.new(solr_document, ability) }

  subject { Capybara::Node::Simple.new(rendered) }

  before do
    allow(view).to receive(:current_user).and_return(user)
    allow(controller).to receive(:current_ability).and_return(ability)
  end

  context "when the user can downlad but cannot edit" do
    before do
      allow(ability).to receive(:can?).with(:download, member.id).and_return(true)
      allow(ability).to receive(:can?).with(:edit, member.id).and_return(false)
      allow(ability).to receive(:can?).with(:destroy, member.id).and_return(false)
      render("hyrax/base/actions", member: member)
    end
    it "displays only a Download button (no dropdown)" do
      expect(subject).to have_selector('a.btn', text: "Download")
      expect(subject).to have_selector('a#file_download_bn999672v', text: "Download")
    end
  end

  context "when the user has edit permissions" do
    before do
      allow(ability).to receive(:can?).with(:download, member.id).and_return(true)
      allow(ability).to receive(:can?).with(:edit, member.id).and_return(true)
      allow(ability).to receive(:can?).with(:destroy, member.id).and_return(true)
      render("hyrax/base/actions", member: member)
    end
    it "displays a dropdown menu including a link to download" do
      expect(subject).to have_selector("button#dropdownMenu_bn999672v")
    end
  end

  context "when the user has no permissions" do
    before do
      allow(ability).to receive(:can?).with(:download, member.id).and_return(false)
      allow(ability).to receive(:can?).with(:edit, member.id).and_return(false)
      allow(ability).to receive(:can?).with(:destroy, member.id).and_return(false)
      render("hyrax/base/actions", member: member)
    end
    it "displays no links nor buttons" do
      expect(subject).not_to have_selector('a')
      expect(subject).not_to have_selector('button')
    end
  end
end