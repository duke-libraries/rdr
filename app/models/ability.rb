class Ability
  include Hydra::Ability

  include Hyrax::Ability
  self.ability_logic += [:everyone_can_create_curation_concerns]

  # Define any customized permissions here.
  def custom_permissions
    if current_user.curator?
      can [ :create ], BatchImport
    end
  end

end
