# Provide services for adding a proxy to a user, removing a proxy from a user, and listing the
# proxy information for a specific user or all users.  The proxy information for a user includes
# the list of users who are proxies for that user and the list of users for whom that user is a proxy.
class ProxyService

  # Lists proxy information for a given user or for all users
  #
  # @param user [String, User] the user for whom proxy information is to be provided
  # @return [Hash] if a user is provided, the users who are proxies for the provided user (`proxies:`) and
  #   the users for whom the provided user is a proxy (`proxy_for:`)
  # @return [Array<Hash>] if a user is not provided, an Array containing a Hash for each user, indicating the
  #   user (`user:`) and the proxy information for that user (`proxy_info:`).  The proxy information
  #   contains the users who are proxies for the user (`proxies:`) and the users for whom the user  is a
  #   proxy (`proxy_for:`)
  def self.list(user = nil)
    if user.present?
      user_proxy_info(cast(user))
    else
      all_proxy_info
    end
  end

  # Adds a proxy to a user
  #
  # @param user [String, User] the user_key or User for whom the proxy is being added
  # @param proxy [String, User] the user_key or User representing the proxy being added
  # @return [TrueClass] if the user was successfully saved after the proxy was added
  # @return [FalseClass] if proxy is already a proxy for the user or if the user was not successfully
  #   saved after the proxy was added
  def self.add(user:, proxy:)
    proxied_user = cast(user)
    proxy_user = cast(proxy)
    if proxied_user.can_receive_deposits_from.include?(proxy_user)
      return false
    else
      proxied_user.can_receive_deposits_from << proxy_user
      proxied_user.save
    end
  end

  # Removes a proxy from a user
  #
  # @param user [String, User] the user_key or User for whom the proxy is being removed
  # @param proxy [String, User] the user_key or User representing the proxy being removed
  # @return [TrueClass] if the user was successfully saved after the proxy was removed
  # @return [FalseClass] if proxy is not a proxy for the user or if the user was not successfully
  #   saved after the proxy was removed
  def self.remove(user:, proxy:)
    proxied_user = cast(user)
    proxy_user = cast(proxy)
    if proxied_user.can_receive_deposits_from.include?(proxy_user)
      proxied_user.can_receive_deposits_from.delete(proxy_user)
      proxied_user.save
    else
      return false
    end
  end

  private

  def self.cast(user)
    return user if user.is_a?(User)
    if usr = User.find_by_user_key(user)
      usr
    else
      raise ArgumentError, I18n.t('rdr.user_not_found', user_key: user)
    end
  end

  def self.user_proxy_info(user)
    { proxies: proxies(user), proxy_for: proxy_fors(user) }
  end

  def self.proxies(user)
    user.can_receive_deposits_from
  end

  def self.proxy_fors(user)
    user.can_make_deposits_for
  end

  def self.all_proxy_info
    User.all.map { |user| { user: user, proxy_info: user_proxy_info(user) } }
  end

end
