module Rdr
  module Index
    extend ActiveSupport::Autoload

    autoload :Field
    autoload :Fields

    # :stored_searchable, :facetable
    STORED_SEARCHABLE_FACETABLE_FIELDS = (
      Hyrax::BasicMetadataIndexer.stored_and_facetable_fields +
      %i[ affiliation format title ]
    ).freeze

    STORED_SEARCHABLE_FIELDS = (
      Hyrax::BasicMetadataIndexer.stored_fields +
      %i[ alternative depositor provenance ]
    ).freeze

    STORED_SORTABLE_FIELDS = %i[ ark doi ].freeze

    DATEABLE_FACETABLE_FIELDS = %i[ available temporal ].freeze

    # :stored_sortable, type: :date
    SORTABLE_DATE_FIELDS = %i[ date_modified date_uploaded ].freeze

    SYMBOL_FIELDS = Hyrax::BasicMetadataIndexer.symbol_fields

  end
end
