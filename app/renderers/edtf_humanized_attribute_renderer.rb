# Patterned after 'Hyrax::Renderers::DateAttributeRenderer'
class EdtfHumanizedAttributeRenderer < Hyrax::Renderers::AttributeRenderer
  private

  def li_value(value)
    Date.edtf(value)&.humanize || value
  end
end
