class Ability
  include Hydra::Ability

  include Hyrax::Ability
  # commented out to restrict the ability of who can create works
  # self.ability_logic += [:everyone_can_create_curation_concerns]

  # Define any customized permissions here.
  def custom_permissions

    # Limits deleting objects to a the admin user
    #
    # if current_user.admin?
    #   can [:destroy], ActiveFedora::Base
    # end

    # Limits creating new objects to a specific group
    #
    # if user_groups.include? 'special_group'
    #   can [:create], ActiveFedora::Base
    # end

    if registered_user?
      can [ :create ], Collection
    end

    if current_user.admin?
      can [:create, :show, :add_user, :remove_user, :index, :edit, :update, :destroy], Role
    end

    if current_user.curator?
      can [ :create ], BatchImport
      can [ :create ], Dataset
    end

    can [ :assign_register_doi ], Dataset do |ds|
      current_user.curator? &&
          current_user.can?(:edit, ds) &&
          ds.doi_assignable? &&
          ds.doi_required_metadata_present?
    end

    can [ :assign_register_doi ], SolrDocument do |doc|
      current_user.curator? &&
          current_user.can?(:edit, doc) &&
          doc.doi_assignable? &&
          doc.doi_required_metadata_present?
    end

  end

end
