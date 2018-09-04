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

  # For long text (e.g., work description field): after a number of words, wrap the content
  # in a span allowing that section to be expanded/collapsed via a "more" link, while
  # preserving the existing icon + link rendering for URLs.

  def expandable_iconify_auto_link(value)
    words = value.split
    word_count = words.length
    word_limit = Rdr.expandable_text_word_cutoff
    fullmarkup = iconify_auto_link(words[0..word_limit].join(" "))
    if(word_count > word_limit)
      fullmarkup << " "
      fullmarkup << content_tag(:span, iconify_auto_link(words[(word_limit+1)..word_count].join(" ")),
                class: "expandable-extended-text")
      fullmarkup << " "
      fullmarkup << link_to("... [Read More]","#", class: "toggle-extended-text")
    end
    fullmarkup
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

end
