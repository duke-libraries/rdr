# Patterned after 'Hyrax::Renderers::DateAttributeRenderer' and `Hyrax::Renderers::FacetedAttributeRenderer`
class FacetedDateAttributeRenderer < Hyrax::Renderers::AttributeRenderer
  private

  def li_value(value)
    link_to(ERB::Util.h(Rdr.readable_date(value)), search_path(value))
  end

  def search_path(value)
    Rails.application.routes.url_helpers.search_catalog_path(:"f[#{search_field}][]" => value)
  end

  def search_field
    ERB::Util.h(Solrizer.solr_name(options.fetch(:search_field, field), :dateable, type: :string))
  end
end
