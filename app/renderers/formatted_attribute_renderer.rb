# Patterned after 'Hyrax::Renderers::DateAttributeRenderer'

# This renderer applies several formatting rules to a metadata value
# including auto-linking URLs, converting linebreaks to <br>
# tags, and truncating long text into an expand/collapse section

class FormattedAttributeRenderer < Hyrax::Renderers::AttributeRenderer
  private

  def li_value(value)
    value_with_br_links = auto_link(convert_linebreaks(value))
    truncate_and_expand(value_with_br_links)
  end

  # NOTE: this gsub is used instead of Rails simple_format, which would sometimes
  # create <p></p> tags that don't play nicely with the truncate + collapse/expand

  def convert_linebreaks(value)
    value.gsub(/(?:\n\r?|\r\n?)/, '<br/>').html_safe
  end

  def truncate_and_expand(value)
    words = value.split
    word_count = words.length
    word_limit = Rdr.expandable_text_word_cutoff

    formatted_text = words[0..word_limit].join(" ")
    collapsed_text = words[(word_limit+1)..word_count]&.join(" ")

    if collapsed_text.present?
      formatted_text << [
        " ",
        content_tag(:span, collapsed_text.html_safe, class: "expandable-extended-text"),
        " ",
        link_to("... [Read More]", "#", class: "toggle-extended-text")
      ].join
    end

    sanitized_text = sanitize(formatted_text, tags: %w(a br span strong em sup sub))
    sanitized_text.html_safe
  end
end
