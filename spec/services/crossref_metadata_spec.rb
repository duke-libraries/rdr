require 'rails_helper'

RSpec.describe CrossrefMetadata, crossref: true do

  let(:work) { FactoryBot.build(:dataset,
                                title: ['Crossref Metadata Test'],
                                creator: ["Public, Jane Q."],
                                contributor: ["Potter, Harry", "Malfoy, Draco"],
                                available: ['2018-04-11'],
                                ark: 'ark:/99999/fk4zzzzz',
                                doi: '10.7924/fk4zzzzz'
                               ) }

  describe ".call" do
    subject { described_class.call(work) }

    before do
      allow_any_instance_of(described_class).to receive(:generate_doi_batch_id) { "foo" }
      allow_any_instance_of(described_class).to receive(:generate_timestamp) { 123456789 }
    end

    it "sets doi_batch_id" do
      expect(subject.at_css('doi_batch_id').content).to eq "foo"
    end
    it "sets timestamp" do
      expect(subject.at_css('timestamp').content).to eq "123456789"
    end
    it "sets title" do
      expect(subject.at_css('dataset title').content).to eq 'Crossref Metadata Test'
    end
    it "sets contributors for the creator(s)" do
      author = subject.at_css('contributors person_name[sequence="first"]')
      expect(author.at_css('given_name').content).to eq "Jane Q."
      expect(author.at_css('surname').content).to eq "Public"
    end
    it "set contributors for the contributor(s)" do
      surnames = subject.css('contributors person_name[sequence="additional"] surname')
      expect(surnames.map(&:text)).to contain_exactly("Potter", "Malfoy")
      given_names = subject.css('contributors person_name[sequence="additional"] given_name')
      expect(given_names.map(&:text)).to contain_exactly("Harry", "Draco")
    end
    it "sets publication_date" do
      expect(subject.at_css('publication_date month').content).to eq "04"
      expect(subject.at_css('publication_date day').content).to eq "11"
      expect(subject.at_css('publication_date year').content).to eq "2018"
    end
    it "sets doi" do
      expect(subject.at_css('doi').content).to eq '10.7924/fk4zzzzz'
    end
    it "sets resource" do
      expect(subject.at_css('resource').content).to eq 'https://idn.duke.edu/ark:/99999/fk4zzzzz'
    end
  end

end
