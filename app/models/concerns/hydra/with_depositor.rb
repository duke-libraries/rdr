module Hydra::WithDepositor
  # Overrides Hydra::WithDepositor#apply_depositor_metadata to grant edit permissions to +depositor+ if and only if
  # +depositor+ is a curator; otherwise, the +depositor+ is granted read access.
  #
  # The comments immediately below apply to the overridden method, whose behavior is modified by this override.
  #
  # Adds metadata about the depositor to the asset and
  # grants edit permissions to the +depositor+
  # @param [String, #user_key] depositor
  def apply_depositor_metadata(depositor)
    depositor_id = depositor.respond_to?(:user_key) ? depositor.user_key : depositor

    if respond_to? :depositor
      self.depositor = depositor_id
    end
    if User.curators.include?(depositor_id)
      self.edit_users += [depositor_id]
    else
      self.read_users += [depositor_id]
    end
    true
  end
end
