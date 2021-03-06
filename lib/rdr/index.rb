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
      %i[ alternative contact depositor funding_agency provenance rights_note temporal ]
    ).freeze

    STORED_SORTABLE_FIELDS = %i[ ark doi is_replaced_by replaces ].freeze

    DATEABLE_FIELDS = %i[ available ].freeze

    # :stored_sortable, type: :date
    SORTABLE_DATE_FIELDS = %i[ date_modified date_uploaded ].freeze

    # :searchable, type: :integer (_iim)
    SEARCHABLE_INTEGER_FIELDS = %i[ pub_year ].freeze

    SYMBOL_FIELDS = (
      Hyrax::BasicMetadataIndexer.symbol_fields +
      %i[ grant_number in_works_ids ]
    ).freeze

    BOOLEAN_FIELDS = %i[ top_level ].freeze

  end
end
