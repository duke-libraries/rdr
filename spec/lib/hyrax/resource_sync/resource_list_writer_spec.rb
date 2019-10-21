require 'rails_helper'

# Tests monkey-patched Hyrax core ResourceSync list writer
# to ensure RDR sitemaps include all works but don't include files
# https://github.com/samvera/hyrax/blob/master/spec/lib/hyrax/resource_sync/resource_list_writer_spec.rb
RSpec.describe Hyrax::ResourceSync::ResourceListWriter, :clean_repo do
  let(:sitemap) { 'http://www.sitemaps.org/schemas/sitemap/0.9' }

  let!(:dataset_one) { FactoryBot.create(:public_dataset) }
  let!(:dataset_two) { FactoryBot.create(:dataset_with_two_public_children, :public) }
  let!(:dataset_three) { FactoryBot.create(:public_dataset_with_public_files) }
  let!(:dataset_four) { FactoryBot.create(:dataset) } # not public

  let(:xml) { Nokogiri::XML.parse(subject) }

  subject { described_class.new(resource_host: 'research.repository.duke.edu', capability_list_url: 'https://research.repository.duke.edu/capabilitylist').write }

  it "lists public top-level work URLs" do
    expect(subject).to match(/research.repository.duke.edu\/concern\/datasets\/#{dataset_one.id}/)
    expect(subject).to match(/research.repository.duke.edu\/concern\/datasets\/#{dataset_two.id}/)
    expect(subject).to match(/research.repository.duke.edu\/concern\/datasets\/#{dataset_three.id}/)
  end

  it "lists public work URLs even if nested" do
    expect(subject).to match(/research.repository.duke.edu\/concern\/datasets\/BlahBlah3/)
    expect(subject).to match(/research.repository.duke.edu\/concern\/datasets\/BlahBlah4/)
  end

  it "omits non-public work URLs" do
    expect(subject).not_to match(/research.repository.duke.edu\/concern\/datasets\/#{dataset_four.id}/)
  end

  it "omits file_set URLs" do
    expect(subject).not_to match(/research.repository.duke.edu\/concern\/file_sets\//)
  end
end
