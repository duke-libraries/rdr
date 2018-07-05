module RdrHelper

  def readable_date(value)
    Rdr.readable_date(value)
  end

  def recent_dataset_entry(document)
    if document.bibliographic_citation.present?
      document.bibliographic_citation.first
    else
      document.title.first
    end
  end

  def render_on_behalf_of(value)
    if value.blank?
      'Yourself'
    else
      User.find_by_user_key(value).display_name || value
    end
  end

end
