require 'nokogiri'
require 'securerandom'

class CrossrefMetadata

  METADATA_TEMPLATE = File.join(Rails.root, 'config', 'crossref_metadata_template.xml')

  BASE_RESOURCE_URL = "https://idn.duke.edu/".freeze

  PUBLICATION_DATE_TAGS = <<-XML
<publication_date>
  <month>%{month}</month>
  <day>%{day}</day>
  <year>%{year}</year>
</publication_date>
  XML

  def self.call(work)
    new(work).call
  end

  attr_reader :work

  def initialize(work)
    @work = work
  end

  def call
    set_doi_batch_id
    set_timestamp
    set_title
    set_authors
    set_contributors
    set_publication_date
    set_doi
    set_resource
    document
  end

  def document
    @document ||= Nokogiri::XML(File.read(METADATA_TEMPLATE))
  end

  def contributors
    document.at_css('contributors')
  end

  def set_title
    title = document.at_css('dataset title')
    title.content = work.title.first
  end

  def set_authors
    work.creator.each do |creator|
      contributors << person_name_node(creator, "first")
    end
  end

  def set_contributors
    work.contributor.each do |contrib|
      contributors << person_name_node(contrib, "additional")
    end
  end

  def person_name_node(person_name, sequence)
    surname, given_name = person_name.split(",", 2)
    pn_node = Nokogiri::XML::Node.new('person_name', document)
    pn_node['sequence'] = sequence
    pn_node['contributor_role'] = 'author'
    given_name_node = Nokogiri::XML::Node.new('given_name', document)
    given_name_node.content = given_name.strip
    pn_node << given_name_node
    surname_node = Nokogiri::XML::Node.new('surname', document)
    surname_node.content = surname.strip
    pn_node << surname_node
  end

  def set_publication_date
    return if work.available.empty?
    pubdate = Date.parse(work.available.first) # raises ArgumentError
    database_date = document.at_css('database_date')
    tags = PUBLICATION_DATE_TAGS % {
      month: "%02d" % pubdate.month,
      day: "%02d" % pubdate.day,
      year: pubdate.year
    }
    database_date << tags
  end

  def set_doi
    doi_node = document.at_css('doi')
    doi_node.content = work.doi
  end

  def set_resource
    resource_node = document.at_css('resource')
    resource_node.content = resource_url
  end

  def resource_url
    BASE_RESOURCE_URL + work.ark
  end

  def set_doi_batch_id
    doi_batch_id_node = document.at_css('doi_batch_id')
    doi_batch_id_node.content = generate_doi_batch_id
  end

  def generate_doi_batch_id
    SecureRandom.uuid
  end

  def set_timestamp
    timestamp_node = document.at_css('timestamp')
    timestamp_node.content = generate_timestamp
  end

  def generate_timestamp
    Time.now.to_i
  end

end
