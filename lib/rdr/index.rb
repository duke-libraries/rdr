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
      %i[ alternative depositor provenance rights_note ]
    ).freeze

    STORED_SORTABLE_FIELDS = %i[ ark doi ].freeze

    DATEABLE_FIELDS = %i[ available temporal ].freeze

    # :stored_sortable, type: :date
    SORTABLE_DATE_FIELDS = %i[ date_modified date_uploaded ].freeze

    SYMBOL_FIELDS = (
      Hyrax::BasicMetadataIndexer.symbol_fields +
          %i[ is_replaced_by replaces  ]
    ).freeze

  end
end