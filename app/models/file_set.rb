# Generated by hyrax:models:install
class FileSet < ActiveFedora::Base

  # Define before including FileSetBehavior since FileSetBehavior loads Hyrax BasicMetadata, which needs to be
  # loaded last (because it finalizes the metadata schema by adding accepts_nested_attributes)
  property :ark,
           predicate: ::RDF::URI.new("http://repository.lib.duke.edu/vocab/asset/ark"),
           multiple: false do |index|
    index.as :stored_sortable
  end

  include ::Hyrax::FileSetBehavior

end
