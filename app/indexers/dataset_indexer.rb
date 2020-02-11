# Generated via
#  `rails generate hyrax:work Dataset`
class DatasetIndexer < Hyrax::WorkIndexer
  # This indexes the default metadata. You can remove it if you want to
  # provide your own metadata and indexing.
  include Hyrax::IndexesBasicMetadata

  # Fetch remote labels for based_near. You can remove this if you don't want
  # this behavior
  include Hyrax::IndexesLinkedMetadata

  # Extract years out of date fields for faceting
  include EdtfYearIndexer

  # Add custom indexing behavior:
  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc[Rdr::Index::Fields.top_level] = object.in_works_ids.blank?
      solr_doc[Rdr::Index::Fields.in_works_ids] = object.in_works_ids
      solr_doc[Rdr::Index::Fields.pub_year] = Array(object.available)&.map do |date|
        EdtfYearIndexer.edtf_years(date)
      end.flatten.uniq
    end
  end
end
