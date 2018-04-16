module RdrHelper

  def render_on_behalf_of(value)
    if value.blank?
      'Yourself'
    else
      User.find_by_user_key(value).display_name || value
    end
  end

end
