# frozen_string_literal: true
class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
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
      solr_parameters[:fq] << "#{Rdr::Index::Fields::TOP_LEVEL}:True"
    end
  end

end
