# frozen_string_literal: true
class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include BlacklightRangeLimit::RangeLimitBuilder

  # Add a filter query to restrict the search to documents the current user has access to
  include Hydra::AccessControlsEnforcement
  include Hyrax::SearchFilters

  self.default_processor_chain += [:latest_version_filter]
  self.default_processor_chain += [:top_level_filter]

  def latest_version_filter(solr_parameters)
    solr_parameters[:fq] ||= []
    if blacklight_params["latest_version"] == 'true'
      solr_parameters[:fq] << "-#{Rdr::Index::Fields::IS_REPLACED_BY}:*"
    end
  end

  def top_level_filter(solr_parameters)
    solr_parameters[:fq] ||= []
    if blacklight_params["top_level"] == 'true'
      # Amended to include Collections as well as top-level Datasets -- https://duldev.atlassian.net/browse/RDR-431
      solr_parameters[:fq] << "(#{Rdr::Index::Fields::TOP_LEVEL}:True OR has_model_ssim:Collection)"
    end
  end

end
