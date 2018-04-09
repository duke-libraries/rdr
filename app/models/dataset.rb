# Generated via
#  `rails generate hyrax:work Dataset`
class Dataset < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  self.indexer = DatasetIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  self.human_readable_type = 'Dataset'

  include Rdr::Metadata

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata

  include Rdr::DatasetVersioning

  def doi_assignable?
    ark.present? && doi.blank?
  end

  def previous_dataset_version_query
    Dataset.where(Rdr::Index::Fields.doi => replaces)
  end

  def next_dataset_version_query
    Dataset.where(Rdr::Index::Fields.doi => is_replaced_by)
  end

  def reload
    super.tap { |_| @dataset_versions = nil }
  end

end
