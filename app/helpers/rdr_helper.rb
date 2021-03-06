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

  # For nested works, characterize each node in the vertical/hierarchical breadcrumb trail to drive
  # collapse/expand behavior and presentation (e.g,. always show top-level work and direct parent work).
  def vertical_breadcrumb_node_position(pos,total_nodes)
    case
    when (total_nodes <= 3) || (pos == total_nodes)
      'close-ancestor'
    when pos == 1 && total_nodes > 3
      'top-of-many-ancestors'
    else
      'middle-ancestor'
    end
  end

  # Adapted from Hyrax homepage controller in order to by used globally in UI:
  # hyrax/app/controllers/hyrax/homepage_controller.rb
  def announcement
    ContentBlock.for(:announcement)
  end

  # @return the email address to display on the export files create page, which is the email address that will be
  # notified when the export package is ready for download
  # If 'provided_email' is present, that is the email address that is returned
  # If 'provided_email' is not present, the email address of the 'user' is returned
  # (If neither 'provided_email' nor 'user' is provided, `nil` is returned.  This is not an expected scenario.)
  def export_package_ready_email_address(provided_email, user)
    provided_email.present? ? provided_email : user&.email
  end

end
