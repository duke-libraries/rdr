module Rdr::Index
  module Fields

    #
    # EXAMPLE
    #
    # register :alternative, :stored_searchable
    #
    # > Rdr::Index::Fields.alternative
    #   => "alternative_tesim"
    #
    # > Rdr::Index::Fields::ALTERNATIVE
    #   => "alternative_tesim"
    #
    def self.register(field_name, indexer, opts={})
      const_name = field_name.to_s.upcase
      base = opts.delete(:prefix) || field_name
      field = Field.new(base, indexer, opts)
      const_set(const_name, field)
      define_singleton_method(field_name) { const_get(const_name) }
    end

    STORED_SEARCHABLE_FACETABLE_FIELDS.each do |field|
      register field, :stored_searchable
      register "#{field}_facet", :facetable, prefix: field
    end

    STORED_SEARCHABLE_FIELDS.each do |field|
      register field, :stored_searchable
    end

    STORED_SORTABLE_FIELDS.each do |field|
      register field, :stored_sortable
    end

    SYMBOL_FIELDS.each do |field|
      register field, :symbol
    end

    SORTABLE_DATE_FIELDS.each do |field|
      register field, :stored_sortable, type: :date
    end

    DATEABLE_FACETABLE_FIELDS.each do |field|
      register field, :dateable
      register "#{field}_facet", :facetable, prefix: field
    end

    # This is an outlier ...
    register :depositor_symbol, :symbol, prefix: :depositor

  end
end
