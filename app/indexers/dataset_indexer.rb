# Generated via
#  `rails generate hyrax:work Dataset`
class DatasetIndexer < Hyrax::WorkIndexer
  # This indexes the default metadata. You can remove it if you want to
  # provide your own metadata and indexing.
  include Hyrax::IndexesBasicMetadata

  # Fetch remote labels for based_near. You can remove this if you don't want
  # this behavior
  include Hyrax::IndexesLinkedMetadata

  # Add custom indexing behavior:
  # Enable queries to distinguish top-level vs. nested datasets
  def generate_solr_document
   super.tap do |solr_doc|
     solr_doc['top_level_bsi'] = object.in_works_ids.blank?
     solr_doc[Rdr::Index::Fields.in_works_ids] = object.in_works_ids
   end
  end
end
