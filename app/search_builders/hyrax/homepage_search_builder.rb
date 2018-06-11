# Override Hyrax::HomepageSearchBuilder to add filter for only top-level works
class Hyrax::HomepageSearchBuilder < Hyrax::SearchBuilder
  include Hyrax::FilterByType
  self.default_processor_chain += [ :add_access_controls_to_solr_params, :only_top_level_works_filter ]

  def only_works?
    true
  end

  def only_top_level_works_filter(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "#{Rdr::Index::Fields.top_level}:True"
  end

end
