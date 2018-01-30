require 'delegate'

module Rdr::Index
  class Field < SimpleDelegator

    attr_reader :base

    def initialize(base, indexer, opts={})
      @base = base.to_s
      solr_name = opts.delete(:solr_name)
      solrizer_args = opts.present? ? [indexer, opts] : [indexer]
      field_name = solr_name || Solrizer.solr_name(base, *solrizer_args)
      super(field_name)
    end

    def label
      I18n.t "#{i18n_base}.label", default: base.titleize
    end

    def heading
      I18n.t "#{i18n_base}.heading", default: base
    end

    private

    def i18n_base
      "rdr.index.fields.#{base}"
    end

  end
end
