module RdrHelper

  def readable_date(value)
    Rdr.readable_date(value)
  end

  def render_on_behalf_of(value)
    if value.blank?
      'Yourself'
    else
      User.find_by_user_key(value).display_name || value
    end
  end

  # Blacklight rendering helper method
  #
  # First, truncates each entry in an array of description strings at whitespace such that each truncated entry does
  # not exceed `Rdr.description_truncation_length_index_view` in length.  An ellipsis mark ('...') is added to the
  # end of each truncated entry.
  #
  # Then, passes the resulting truncated (as needed) description values in a modified `field` `Hash` to
  # `Hyrax::HyraxHelperBehavior#iconify_auto_link`.
  #
  # @param field [Hash] hash as per Blacklight helper_method
  # @option field [SolrDocument] :document
  # @option field [String] :field name of the solr field
  # @option field [Blacklight::Configuration::IndexField, Blacklight::Configuration::ShowField] :config
  # @option field [Array] :value array of values for the field
  # @return [ActiveSupport::SafeBuffer]
  def truncate_description_and_iconify_auto_link(field)
    field[:value] = truncate_field_values(field[:value])
    iconify_auto_link(field)
  end

  private

  # Truncates each entry in an array of description strings at whitespace such that each truncated entry does not
  # exceed `Rdr.description_truncation_length_index_view` in length.  An ellipsis mark ('...') is added to the end of
  # each truncated entry.
  #
  # @param values [Array<String>] the list of description strings
  # @return [Array<String>] a list of truncated (as needed) description strings
  def truncate_field_values(values)
    values.map { |value| value.truncate(Rdr.description_truncation_length_index_view, separator: /\s/) }
  end

end
